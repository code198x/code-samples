;══════════════════════════════════════════════════════════════════════════════
; SIGNAL - A Frogger-style game for the Commodore Amiga
; Unit 3: Understanding What We Built
;
; This is the same code as Unit 2, with extensive comments explaining
; every aspect of how the Amiga's custom chipset creates our game display.
;══════════════════════════════════════════════════════════════════════════════

;══════════════════════════════════════════════════════════════════════════════
; TWEAKABLE VALUES
;══════════════════════════════════════════════════════════════════════════════
; These constants let you experiment without understanding the code.
; Change them, rebuild, see results.

FROG_START_X    equ 160         ; Horizontal: 0=left edge, 320=right edge
FROG_START_Y    equ 180         ; Vertical: 0=top, 256=bottom (PAL)

MOVE_SPEED      equ 2           ; Pixels moved per frame (at 50fps PAL)

; Screen boundaries for the frog
MIN_X           equ 48          ; Sprites can't go left of ~44
MAX_X           equ 280         ; Or right of ~304
MIN_Y           equ 44          ; Top of playfield (home zone)
MAX_Y           equ 196         ; Bottom of playfield (start zone)

FROG_HEIGHT     equ 16          ; Sprite is 16 pixels tall

; Colours in $0RGB format (0-15 for each component)
; Example: $0F00 = red, $00F0 = green, $000F = blue, $0FFF = white
COLOUR_HOME     equ $0080       ; Home zone: dark green
COLOUR_WATER    equ $0048       ; Water: dark blue
COLOUR_WAVE     equ $006b       ; Water highlight: lighter blue
COLOUR_MEDIAN   equ $0080       ; Safe median: dark green
COLOUR_ROAD     equ $0444       ; Road: dark grey
COLOUR_MARKER   equ $0666       ; Lane markings: lighter grey
COLOUR_START    equ $0080       ; Start zone: dark green
COLOUR_BORDER   equ $0070       ; Border: slightly different green

; Sprite palette (colours 17-19 in the Amiga palette)
; Sprites use a separate palette from the playfield
COLOUR_FROG     equ $00f0       ; Bright green body
COLOUR_EYES     equ $0ff0       ; Yellow eyes
COLOUR_OUTLINE  equ $0000       ; Black outline

;══════════════════════════════════════════════════════════════════════════════
; HARDWARE REGISTER DEFINITIONS
;══════════════════════════════════════════════════════════════════════════════
; The Amiga's custom chipset is memory-mapped starting at $DFF000.
; Each register is accessed as an offset from this base address.

CUSTOM      equ $dff000         ; Custom chip base address

; DMA and interrupt control
DMACONR     equ $002            ; DMA control read (tells us what's enabled)
DMACON      equ $096            ; DMA control write (enables/disables DMA channels)
INTENA      equ $09a            ; Interrupt enable (which interrupts are active)
INTREQ      equ $09c            ; Interrupt request (which interrupts are pending)

; Timing
VPOSR       equ $004            ; Vertical beam position (high bits)
                                ; Used with VHPOSR ($006) for full position

; Input
JOY1DAT     equ $00c            ; Joystick port 2 data register

; Copper (display co-processor)
COP1LC      equ $080            ; Copper list 1 location (32-bit address)
COPJMP1     equ $088            ; Copper jump strobe (writing here starts copper)

; Colours
COLOR00     equ $180            ; Background colour (colour 0)
                                ; COLOR01-COLOR31 follow at $182, $184, etc.

; Sprite registers
SPR0PTH     equ $120            ; Sprite 0 pointer high word
SPR0PTL     equ $122            ; Sprite 0 pointer low word
                                ; SPR1PTH/L at $124/$126, and so on up to SPR7

;══════════════════════════════════════════════════════════════════════════════
; CODE SECTION
;══════════════════════════════════════════════════════════════════════════════
; The section directive tells the assembler how to organise the output.
;
; "code_c" means "code in Chip RAM". Chip RAM is the first 512K (or more)
; that the custom chipset can access. The Copper and sprites MUST be in
; Chip RAM - they can't see Fast RAM.
;
; Without "_c", data would go to Fast RAM, which is faster for the CPU
; but invisible to the custom chipset.

            section code,code_c

start:
            lea     CUSTOM,a5           ; A5 = $DFF000 (custom chip base)
                                        ; We keep this in A5 throughout the program
                                        ; for quick access to hardware registers

;──────────────────────────────────────────────────────────────────────────────
; SYSTEM TAKEOVER
;──────────────────────────────────────────────────────────────────────────────
; AmigaOS is a preemptive multitasking operating system. It uses interrupts
; to switch between tasks, and DMA for disk, sound, and graphics.
;
; For a game that needs precise timing and full hardware control, we disable
; all of this. The OS stops running; we own the machine.
;
; This is why you need to reset to exit - there's no OS to return to!

            move.w  #$7fff,INTENA(a5)   ; Disable ALL interrupts
                                        ; $7fff = bits 0-14 set, bit 15 clear
                                        ; Bit 15 is SET/CLR: 0=disable, 1=enable
                                        ; So this disables bits 0-14

            move.w  #$7fff,INTREQ(a5)   ; Clear any pending interrupt requests
                                        ; Even disabled interrupts might be waiting

            move.w  #$7fff,DMACON(a5)   ; Disable ALL DMA channels
                                        ; Same SET/CLR bit 15 logic
                                        ; Stops copper, sprites, bitplanes, audio, disk

;──────────────────────────────────────────────────────────────────────────────
; INITIALISE FROG POSITION
;──────────────────────────────────────────────────────────────────────────────

            move.w  #FROG_START_X,frog_x    ; Set initial X position
            move.w  #FROG_START_Y,frog_y    ; Set initial Y position

;──────────────────────────────────────────────────────────────────────────────
; SET UP SPRITE POINTER
;──────────────────────────────────────────────────────────────────────────────
; The Copper needs to know where sprite data is in memory. We write the
; address of our sprite data into the Copper list.
;
; Amiga addresses are 32-bit, but each Copper instruction is only 32 bits
; total (16-bit register + 16-bit value). So we need TWO instructions:
; one for the high 16 bits, one for the low 16 bits.

            lea     frog_data,a0        ; A0 = address of sprite data
            move.l  a0,d0               ; D0 = same address (32-bit)
            swap    d0                  ; D0 high word now in low word
            lea     sprpth_val,a1       ; A1 = where to write high word
            move.w  d0,(a1)             ; Write high word to Copper list
            swap    d0                  ; Restore: low word back in low word
            lea     sprptl_val,a1       ; A1 = where to write low word
            move.w  d0,(a1)             ; Write low word to Copper list

;──────────────────────────────────────────────────────────────────────────────
; UPDATE SPRITE CONTROL WORDS
;──────────────────────────────────────────────────────────────────────────────

            bsr     update_sprite       ; Set initial sprite position

;──────────────────────────────────────────────────────────────────────────────
; INSTALL COPPER LIST
;──────────────────────────────────────────────────────────────────────────────
; The Copper is a simple processor that runs in sync with the video beam.
; It can WAIT for a specific screen position, or MOVE a value to a register.
; Our Copper list sets colours at specific scanlines to create the playfield.

            lea     copperlist,a0       ; A0 = address of our Copper list
            move.l  a0,COP1LC(a5)       ; Tell hardware where list is
            move.w  d0,COPJMP1(a5)      ; "Strobe" register - writing ANY value
                                        ; here makes the Copper jump to COP1LC

;──────────────────────────────────────────────────────────────────────────────
; ENABLE DMA
;──────────────────────────────────────────────────────────────────────────────
; Now we selectively enable only what we need:
;
; $83a0 = %1000 0011 1010 0000
;         │    │  │ │  │
;         │    │  │ │  └─ Bit 5: SPREN (sprite DMA enable)
;         │    │  │ └──── Bit 7: COPEN (Copper DMA enable)
;         │    │  └────── Bit 8: BPLEN (bitplane DMA enable)
;         │    └───────── Bit 9: DMAEN (master DMA enable)
;         └────────────── Bit 15: SET (1=enable the bits below)
;
; IMPORTANT: We need BPLEN even though we have no bitplanes!
; Without it, sprites don't render correctly. This is a hardware quirk.

            move.w  #$83a0,DMACON(a5)   ; Enable master + copper + sprites + bitplanes

;══════════════════════════════════════════════════════════════════════════════
; MAIN LOOP
;══════════════════════════════════════════════════════════════════════════════
; This runs 50 times per second (PAL) or 60 times per second (NTSC).
; Each iteration:
;   1. Wait for vertical blank (beam at bottom of screen)
;   2. Read joystick input
;   3. Update frog position based on input
;   4. Update sprite control words for new position

mainloop:
            bsr.s   wait_vblank         ; Wait for vertical blank
            bsr.s   read_joystick       ; Read joystick -> D0
            bsr.s   move_frog           ; Move frog based on D0
            bsr     update_sprite       ; Update sprite position

            ; Check left mouse button (active low at $BFE001 bit 6)
            btst    #6,$bfe001          ; Test bit 6 of CIA-A PRA
            bne.s   mainloop            ; If not pressed (bit=1), continue

            ; Button pressed - but we have nowhere to go!
            ; On a real Amiga, you'd restore the system here.
            ; For now, just keep looping until reset.
            bra.s   mainloop

;══════════════════════════════════════════════════════════════════════════════
; SUBROUTINES
;══════════════════════════════════════════════════════════════════════════════

;──────────────────────────────────────────────────────────────────────────────
; WAIT_VBLANK - Wait for vertical blank
;──────────────────────────────────────────────────────────────────────────────
; The video beam scans from top-left to bottom-right, then returns to top.
; "Vertical blank" is when the beam is returning - no visible output.
; This is the safe time to update graphics without visible tearing.
;
; VPOSR contains the beam position. We wait until it's at line 0.

wait_vblank:
            move.l  #$1ff00,d1          ; Mask: bits 16-8 (vertical position)
.wait:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Mask out horizontal position
            bne.s   .wait               ; Loop until vertical = 0
            rts

;──────────────────────────────────────────────────────────────────────────────
; READ_JOYSTICK - Read and decode joystick input
;──────────────────────────────────────────────────────────────────────────────
; JOY1DAT contains joystick data, but it's encoded weirdly (inherited from
; the Atari 400/800). The vertical movement affects the horizontal bits
; through XOR, so we need to decode it.
;
; Raw JOY1DAT:
;   Bit 9: Y1 XOR X1 (left signal)
;   Bit 8: Y1 (up signal before decode)
;   Bit 1: Y0 XOR X0 (right signal)
;   Bit 0: Y0 (down signal before decode)
;
; After XOR decoding, bits represent actual directions.

read_joystick:
            move.w  JOY1DAT(a5),d0      ; Read raw joystick data
            move.w  d0,d1               ; Copy to D1
            lsr.w   #1,d1               ; Shift D1 right by 1
            eor.w   d1,d0               ; XOR with shifted copy
                                        ; This decodes the quadrature encoding
            rts
            ; Result in D0:
            ;   Bit 8 = up
            ;   Bit 0 = down
            ;   Bit 9 = left
            ;   Bit 1 = right

;──────────────────────────────────────────────────────────────────────────────
; MOVE_FROG - Update frog position based on joystick
;──────────────────────────────────────────────────────────────────────────────
; For each direction:
;   1. Test if that direction bit is set
;   2. Calculate new position
;   3. Check against boundary
;   4. Store new position if within bounds

move_frog:
            ; --- Check Up (bit 8) ---
            btst    #8,d0               ; Test up bit
            beq.s   .no_up              ; Skip if not pressed
            move.w  frog_y,d1           ; Get current Y
            sub.w   #MOVE_SPEED,d1      ; Subtract (up = decrease Y)
            cmp.w   #MIN_Y,d1           ; Compare with top boundary
            blt.s   .no_up              ; Skip if past boundary
            move.w  d1,frog_y           ; Store new Y
.no_up:
            ; --- Check Down (bit 0) ---
            btst    #0,d0
            beq.s   .no_down
            move.w  frog_y,d1
            add.w   #MOVE_SPEED,d1      ; Add (down = increase Y)
            cmp.w   #MAX_Y,d1
            bgt.s   .no_down            ; Skip if past boundary
            move.w  d1,frog_y
.no_down:
            ; --- Check Left (bit 9) ---
            btst    #9,d0
            beq.s   .no_left
            move.w  frog_x,d1
            sub.w   #MOVE_SPEED,d1      ; Subtract (left = decrease X)
            cmp.w   #MIN_X,d1
            blt.s   .no_left
            move.w  d1,frog_x
.no_left:
            ; --- Check Right (bit 1) ---
            btst    #1,d0
            beq.s   .no_right
            move.w  frog_x,d1
            add.w   #MOVE_SPEED,d1      ; Add (right = increase X)
            cmp.w   #MAX_X,d1
            bgt.s   .no_right
            move.w  d1,frog_x
.no_right:
            rts

;──────────────────────────────────────────────────────────────────────────────
; UPDATE_SPRITE - Write position to sprite control words
;──────────────────────────────────────────────────────────────────────────────
; Hardware sprites have control words at the start of their data:
;
; Word 0: VSTART[7:0] << 8 | HSTART[8:1]
;         (vertical start position, horizontal start / 2)
;
; Word 1: VSTOP[7:0] << 8 | VSTART[8] << 2 | VSTOP[8] << 1 | HSTART[0]
;         (vertical stop position, plus extra bits for large positions)
;
; For our 16-pixel tall sprite starting at Y positions < 256, we can
; simplify: just pack VSTART and HSTART/2 into word 0, VSTOP into word 1.

update_sprite:
            lea     frog_data,a0        ; A0 = sprite data start
            move.w  frog_y,d0           ; D0 = Y position (VSTART)
            move.w  frog_x,d1           ; D1 = X position (HSTART)

            ; Build control word 0: VSTART << 8 | HSTART >> 1
            move.w  d0,d2               ; D2 = VSTART
            lsl.w   #8,d2               ; Shift to high byte
            lsr.w   #1,d1               ; HSTART / 2 (sprites use half-res X)
            or.b    d1,d2               ; Combine into low byte
            move.w  d2,(a0)             ; Write to sprite control word 0

            ; Build control word 1: VSTOP << 8
            add.w   #FROG_HEIGHT,d0     ; D0 = VSTOP (VSTART + height)
            lsl.w   #8,d0               ; Shift to high byte
            move.w  d0,2(a0)            ; Write to sprite control word 1

            rts

;══════════════════════════════════════════════════════════════════════════════
; VARIABLES
;══════════════════════════════════════════════════════════════════════════════
; These are in the code section so they're in Chip RAM with everything else.
; The 68000 can access them with PC-relative addressing for efficiency.

frog_x:     dc.w    160             ; Current horizontal position
frog_y:     dc.w    180             ; Current vertical position

;══════════════════════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════════════════════
; The Copper executes simple instructions synchronised to the video beam.
; Each instruction is 32 bits (two 16-bit words).
;
; MOVE instruction: $XXYY,$VVVV
;   XX = register offset / 2 (bits 8-1 of register address)
;   YY = 00 (identifies this as a MOVE)
;   VVVV = 16-bit value to write
;
; WAIT instruction: $VVHH,$FFFE
;   VV = vertical position to wait for
;   HH = horizontal position to wait for
;   $FFFE = identifies this as a WAIT (bits 0 and 15 clear)
;
; The $07 in our WAITs means "wait for horizontal position 7" which is
; just after the left edge of the visible screen.

copperlist:
            dc.w    COLOR00,$0000       ; MOVE: Set background to black

            ; --- Sprite 0 palette (colours 17-19) ---
            ; Sprites 0-1 share colours 16-19 ($1A0-$1A6)
            ; Colour 16 ($1A0) is transparent, 17-19 are the sprite colours
            dc.w    $01a2,COLOUR_FROG   ; MOVE: Colour 17 = frog body
            dc.w    $01a4,COLOUR_EYES   ; MOVE: Colour 18 = eyes
            dc.w    $01a6,COLOUR_OUTLINE ; MOVE: Colour 19 = outline

            ; --- Sprite 0 pointer ---
            ; These values are filled in by the CPU at startup
            dc.w    SPR0PTH             ; MOVE: SPR0PTH register ($120)
sprpth_val: dc.w    $0000               ; Value: high word of sprite address
            dc.w    SPR0PTL             ; MOVE: SPR0PTL register ($122)
sprptl_val: dc.w    $0000               ; Value: low word of sprite address

            ; === HOME ZONE (line $2C = 44) ===
            dc.w    $2c07,$fffe          ; WAIT for line 44, position 7
            dc.w    COLOR00,COLOUR_HOME  ; MOVE: Background = green

            ; === WATER ZONE (5 lanes with wave highlights) ===
            dc.w    $4007,$fffe          ; WAIT for line 64
            dc.w    COLOR00,COLOUR_WATER ; Dark blue

            dc.w    $4c07,$fffe          ; WAIT for line 76
            dc.w    COLOR00,COLOUR_WAVE  ; Light blue highlight

            dc.w    $5407,$fffe          ; WAIT for line 84
            dc.w    COLOR00,COLOUR_WATER ; Dark blue

            dc.w    $5c07,$fffe          ; WAIT for line 92
            dc.w    COLOR00,COLOUR_WAVE  ; Light blue highlight

            dc.w    $6407,$fffe          ; WAIT for line 100
            dc.w    COLOR00,COLOUR_WATER ; Dark blue

            ; === MEDIAN (safe zone, line $6C = 108) ===
            dc.w    $6c07,$fffe
            dc.w    COLOR00,COLOUR_MEDIAN

            ; === ROAD ZONE (4 lanes with markings) ===
            dc.w    $7807,$fffe          ; Line 120 - road
            dc.w    COLOR00,COLOUR_ROAD

            dc.w    $8407,$fffe          ; Line 132 - marking
            dc.w    COLOR00,COLOUR_MARKER

            dc.w    $8807,$fffe          ; Line 136 - road
            dc.w    COLOR00,COLOUR_ROAD

            dc.w    $9407,$fffe          ; Line 148 - marking
            dc.w    COLOR00,COLOUR_MARKER

            dc.w    $9807,$fffe          ; Line 152 - road
            dc.w    COLOR00,COLOUR_ROAD

            dc.w    $a407,$fffe          ; Line 164 - marking
            dc.w    COLOR00,COLOUR_MARKER

            dc.w    $a807,$fffe          ; Line 168 - road
            dc.w    COLOR00,COLOUR_ROAD

            ; === START ZONE (line $B4 = 180) ===
            dc.w    $b407,$fffe
            dc.w    COLOR00,COLOUR_START

            dc.w    $c007,$fffe          ; Line 192 - border
            dc.w    COLOR00,COLOUR_BORDER

            ; === BOTTOM (line $F0 = 240) ===
            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000        ; Black

            ; === END OF COPPER LIST ===
            dc.w    $ffff,$fffe          ; WAIT for impossible position
                                         ; This effectively halts the Copper
                                         ; until next frame when it restarts

;══════════════════════════════════════════════════════════════════════════════
; SPRITE DATA
;══════════════════════════════════════════════════════════════════════════════
; Hardware sprites are 16 pixels wide and up to 256 lines tall.
; Each line is 4 bytes: two 16-bit words (plane 0 and plane 1).
;
; The two planes combine to give 4 colours per pixel:
;   Plane0=0, Plane1=0 -> Transparent
;   Plane0=1, Plane1=0 -> Colour 17 (green body)
;   Plane0=0, Plane1=1 -> Colour 18 (yellow eyes)
;   Plane0=1, Plane1=1 -> Colour 19 (black outline)

            even                        ; Ensure word alignment
frog_data:
            ; Control words (updated by update_sprite)
            dc.w    $b450,$c400         ; Default: Y=180, X=160

            ; 16 lines of image data (plane0, plane1)
            ; Each pair: plane0 bits | plane1 bits
            dc.w    $0000,$0000         ; ................
            dc.w    $07e0,$0000         ; .....######.....
            dc.w    $1ff8,$0420         ; ...##########...  (with eye hints)
            dc.w    $3ffc,$0a50         ; ..############..
            dc.w    $7ffe,$1248         ; .##############.  (eyes visible)
            dc.w    $7ffe,$1008         ; .##############.
            dc.w    $ffff,$2004         ; ################
            dc.w    $ffff,$0000         ; ################
            dc.w    $ffff,$0000         ; ################
            dc.w    $7ffe,$2004         ; .##############.
            dc.w    $7ffe,$1008         ; .##############.
            dc.w    $3ffc,$0810         ; ..############..
            dc.w    $1ff8,$0420         ; ...##########...
            dc.w    $07e0,$0000         ; .....######.....
            dc.w    $0000,$0000         ; ................
            dc.w    $0000,$0000         ; ................

            ; End marker (required by hardware)
            dc.w    $0000,$0000         ; Tells chipset "no more sprite data"
