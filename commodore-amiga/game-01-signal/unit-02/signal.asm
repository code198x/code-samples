;──────────────────────────────────────────────────────────────
; SIGNAL - A Frogger-style game for the Commodore Amiga
; Unit 2: Moving the Frog
;
; Push the joystick, the frog moves. Interactivity!
;──────────────────────────────────────────────────────────────

;══════════════════════════════════════════════════════════════
; TWEAKABLE VALUES
;══════════════════════════════════════════════════════════════

FROG_START_X    equ 160         ; Starting horizontal position
FROG_START_Y    equ 180         ; Starting vertical position

MOVE_SPEED      equ 2           ; Pixels per frame (try 1, 2, or 4)

; Boundaries (where the frog can move)
MIN_X           equ 48          ; Left edge
MAX_X           equ 280         ; Right edge
MIN_Y           equ 44          ; Top of play area
MAX_Y           equ 196         ; Bottom of play area

; Sprite dimensions
FROG_HEIGHT     equ 16

; Colours
COLOUR_HOME     equ $0080       ; Home zone: green
COLOUR_WATER    equ $0048       ; Water: dark blue
COLOUR_WAVE     equ $006b       ; Water highlight: lighter blue
COLOUR_MEDIAN   equ $0080       ; Safe median: green
COLOUR_ROAD     equ $0444       ; Road: dark grey
COLOUR_MARKER   equ $0666       ; Road marking: light grey
COLOUR_START    equ $0080       ; Start zone: green
COLOUR_BORDER   equ $0070       ; Border: darker green

; Frog colours
COLOUR_FROG     equ $00f0       ; Frog body: bright green
COLOUR_EYES     equ $0ff0       ; Frog eyes: yellow
COLOUR_OUTLINE  equ $0000       ; Frog outline: black

;══════════════════════════════════════════════════════════════
; HARDWARE REGISTERS
;══════════════════════════════════════════════════════════════

CUSTOM      equ $dff000

; Custom chip register offsets
DMACONR     equ $002
VPOSR       equ $004
JOY1DAT     equ $00c            ; Joystick port 2 data
COP1LC      equ $080
COPJMP1     equ $088
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COLOR00     equ $180
SPR0PTH     equ $120
SPR0PTL     equ $122

;══════════════════════════════════════════════════════════════
; CODE SECTION (in chip RAM)
;══════════════════════════════════════════════════════════════
            section code,code_c

start:
            lea     CUSTOM,a5           ; Custom chip base in A5

            ; --- Take over the machine ---
            move.w  #$7fff,INTENA(a5)   ; Disable all interrupts
            move.w  #$7fff,INTREQ(a5)   ; Clear pending interrupts
            move.w  #$7fff,DMACON(a5)   ; Disable all DMA

            ; --- Initialise frog position ---
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y

            ; --- Set sprite pointer in copper list ---
            lea     frog_data,a0
            move.l  a0,d0
            swap    d0
            lea     sprpth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     sprptl_val,a1
            move.w  d0,(a1)

            ; --- Update sprite position ---
            bsr     update_sprite

            ; --- Install copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; --- Enable DMA ---
            move.w  #$83a0,DMACON(a5)   ; Master + copper + sprites + bitplanes

;══════════════════════════════════════════════════════════════
; MAIN LOOP
;══════════════════════════════════════════════════════════════

mainloop:
            bsr.s   wait_vblank         ; Wait for vertical blank
            bsr.s   read_joystick       ; Read joystick into D0
            bsr.s   move_frog           ; Move frog based on input
            bsr     update_sprite       ; Update sprite control words

            ; Check left mouse button for exit
            btst    #6,$bfe001
            bne.s   mainloop

            ; Button pressed - exit
            bra.s   mainloop            ; (Actually just loop - reset to exit)

;──────────────────────────────────────────────────────────────
; Wait for vertical blank
;──────────────────────────────────────────────────────────────
wait_vblank:
            move.l  #$1ff00,d1
.wait:
            move.l  VPOSR(a5),d0
            and.l   d1,d0
            bne.s   .wait
            rts

;──────────────────────────────────────────────────────────────
; Read joystick
; Output: D0 = decoded directions
;         Bit 8 = up, Bit 0 = down, Bit 9 = left, Bit 1 = right
;──────────────────────────────────────────────────────────────
read_joystick:
            move.w  JOY1DAT(a5),d0      ; Read joystick data
            move.w  d0,d1
            lsr.w   #1,d1               ; Shift for XOR decode
            eor.w   d1,d0               ; XOR decode for up/down
            rts

;──────────────────────────────────────────────────────────────
; Move frog based on joystick input
; Input: D0 = decoded joystick directions
;──────────────────────────────────────────────────────────────
move_frog:
            ; --- Check Up ---
            btst    #8,d0
            beq.s   .no_up
            move.w  frog_y,d1
            sub.w   #MOVE_SPEED,d1
            cmp.w   #MIN_Y,d1
            blt.s   .no_up
            move.w  d1,frog_y
.no_up:
            ; --- Check Down ---
            btst    #0,d0
            beq.s   .no_down
            move.w  frog_y,d1
            add.w   #MOVE_SPEED,d1
            cmp.w   #MAX_Y,d1
            bgt.s   .no_down
            move.w  d1,frog_y
.no_down:
            ; --- Check Left ---
            btst    #9,d0
            beq.s   .no_left
            move.w  frog_x,d1
            sub.w   #MOVE_SPEED,d1
            cmp.w   #MIN_X,d1
            blt.s   .no_left
            move.w  d1,frog_x
.no_left:
            ; --- Check Right ---
            btst    #1,d0
            beq.s   .no_right
            move.w  frog_x,d1
            add.w   #MOVE_SPEED,d1
            cmp.w   #MAX_X,d1
            bgt.s   .no_right
            move.w  d1,frog_x
.no_right:
            rts

;──────────────────────────────────────────────────────────────
; Update sprite control words from frog_x/frog_y
;──────────────────────────────────────────────────────────────
update_sprite:
            lea     frog_data,a0
            move.w  frog_y,d0           ; D0 = Y position
            move.w  frog_x,d1           ; D1 = X position

            ; --- Control word 1: VSTART<<8 | HSTART>>1 ---
            move.w  d0,d2               ; D2 = VSTART
            lsl.w   #8,d2               ; Shift to high byte
            lsr.w   #1,d1               ; HSTART / 2
            or.b    d1,d2               ; Combine
            move.w  d2,(a0)             ; Write to sprite

            ; --- Control word 2: VSTOP<<8 | control bits ---
            add.w   #FROG_HEIGHT,d0     ; VSTOP = VSTART + height
            lsl.w   #8,d0               ; Shift to high byte
            move.w  d0,2(a0)            ; Write to sprite

            rts

;──────────────────────────────────────────────────────────────
; Variables
;──────────────────────────────────────────────────────────────
frog_x:     dc.w    160
frog_y:     dc.w    180

;══════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════

copperlist:
            dc.w    COLOR00,$0000       ; Black border at top

            ; --- Sprite 0 palette (colours 17-19) ---
            dc.w    $01a2,COLOUR_FROG
            dc.w    $01a4,COLOUR_EYES
            dc.w    $01a6,COLOUR_OUTLINE

            ; --- Sprite 0 pointer ---
            dc.w    SPR0PTH
sprpth_val: dc.w    $0000
            dc.w    SPR0PTL
sprptl_val: dc.w    $0000

            ; === HOME ZONE ===
            dc.w    $2c07,$fffe
            dc.w    COLOR00,COLOUR_HOME

            ; === WATER ZONE (5 lanes) ===
            dc.w    $4007,$fffe
            dc.w    COLOR00,COLOUR_WATER

            dc.w    $4c07,$fffe
            dc.w    COLOR00,COLOUR_WAVE

            dc.w    $5407,$fffe
            dc.w    COLOR00,COLOUR_WATER

            dc.w    $5c07,$fffe
            dc.w    COLOR00,COLOUR_WAVE

            dc.w    $6407,$fffe
            dc.w    COLOR00,COLOUR_WATER

            ; === MEDIAN (safe zone) ===
            dc.w    $6c07,$fffe
            dc.w    COLOR00,COLOUR_MEDIAN

            ; === ROAD ZONE (4 lanes) ===
            dc.w    $7807,$fffe
            dc.w    COLOR00,COLOUR_ROAD

            dc.w    $8407,$fffe
            dc.w    COLOR00,COLOUR_MARKER

            dc.w    $8807,$fffe
            dc.w    COLOR00,COLOUR_ROAD

            dc.w    $9407,$fffe
            dc.w    COLOR00,COLOUR_MARKER

            dc.w    $9807,$fffe
            dc.w    COLOR00,COLOUR_ROAD

            dc.w    $a407,$fffe
            dc.w    COLOR00,COLOUR_MARKER

            dc.w    $a807,$fffe
            dc.w    COLOR00,COLOUR_ROAD

            ; === START ZONE ===
            dc.w    $b407,$fffe
            dc.w    COLOR00,COLOUR_START

            dc.w    $c007,$fffe
            dc.w    COLOR00,COLOUR_BORDER

            ; === BOTTOM ===
            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000

            ; End of copper list
            dc.w    $ffff,$fffe

;──────────────────────────────────────────────────────────────
; SPRITE DATA
;──────────────────────────────────────────────────────────────
            even
frog_data:
            dc.w    $b450,$c400         ; Control words (updated by code)

            ; 16 lines of sprite data (plane0, plane1)
            dc.w    $0000,$0000
            dc.w    $07e0,$0000
            dc.w    $1ff8,$0420
            dc.w    $3ffc,$0a50
            dc.w    $7ffe,$1248
            dc.w    $7ffe,$1008
            dc.w    $ffff,$2004
            dc.w    $ffff,$0000
            dc.w    $ffff,$0000
            dc.w    $7ffe,$2004
            dc.w    $7ffe,$1008
            dc.w    $3ffc,$0810
            dc.w    $1ff8,$0420
            dc.w    $07e0,$0000
            dc.w    $0000,$0000
            dc.w    $0000,$0000

            ; End marker
            dc.w    $0000,$0000
