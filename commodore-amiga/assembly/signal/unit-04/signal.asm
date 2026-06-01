;══════════════════════════════════════════════════════════════════════════════
; SIGNAL - A Frogger-style game for the Commodore Amiga
; Unit 4: The Playfield
;
; This unit refines our Copper list to create a proper 13-row Frogger grid:
; - Row 1: Home zone (5 docking spots at top)
; - Rows 2-6: Water zone (5 lanes for logs and turtles)
; - Row 7: Median (safe resting zone)
; - Rows 8-12: Road zone (5 lanes for traffic)
; - Row 13: Start zone (where the frog begins)
;══════════════════════════════════════════════════════════════════════════════

;══════════════════════════════════════════════════════════════════════════════
; TWEAKABLE VALUES
;══════════════════════════════════════════════════════════════════════════════

FROG_START_X    equ 160         ; Centre of screen
FROG_START_Y    equ 220         ; Bottom row (start zone)

MOVE_SPEED      equ 2           ; Pixels per frame

; Screen boundaries match our 13-row grid
MIN_X           equ 48          ; Left edge
MAX_X           equ 280         ; Right edge
MIN_Y           equ 44          ; Top of home zone
MAX_Y           equ 220         ; Bottom of start zone

FROG_HEIGHT     equ 16          ; Sprite height

; Grid layout constants
ROW_HEIGHT      equ 16          ; Each row is 16 pixels tall
GRID_TOP        equ 44          ; First row starts at scanline 44
GRID_ROWS       equ 13          ; Total rows in the playfield

; Zone colours - carefully chosen for readability and atmosphere
COLOUR_BLACK    equ $0000       ; Border
COLOUR_HOME     equ $0282       ; Home zone: deep green
COLOUR_HOME_LIT equ $03a3       ; Home zone highlight
COLOUR_WATER1   equ $0148       ; Water: deep blue
COLOUR_WATER2   equ $026a       ; Water: medium blue
COLOUR_MEDIAN   equ $0383       ; Median: bright green (safe!)
COLOUR_ROAD1    equ $0333       ; Road: dark grey
COLOUR_ROAD2    equ $0444       ; Road: medium grey
COLOUR_START    equ $0262       ; Start zone: grass green
COLOUR_START_LIT equ $0373      ; Start zone highlight

; Sprite palette
COLOUR_FROG     equ $00f0       ; Bright green body
COLOUR_EYES     equ $0ff0       ; Yellow eyes
COLOUR_OUTLINE  equ $0000       ; Black outline

;══════════════════════════════════════════════════════════════════════════════
; HARDWARE REGISTERS
;══════════════════════════════════════════════════════════════════════════════

CUSTOM      equ $dff000

DMACONR     equ $002
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
VPOSR       equ $004
JOY1DAT     equ $00c
COP1LC      equ $080
COPJMP1     equ $088
COLOR00     equ $180
SPR0PTH     equ $120
SPR0PTL     equ $122

;══════════════════════════════════════════════════════════════════════════════
; CODE SECTION
;══════════════════════════════════════════════════════════════════════════════

            section code,code_c

start:
            lea     CUSTOM,a5

            ; --- System takeover ---
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

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

            ; --- Update sprite control words ---
            bsr     update_sprite

            ; --- Install copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; --- Enable DMA ---
            move.w  #$83a0,DMACON(a5)

;══════════════════════════════════════════════════════════════════════════════
; MAIN LOOP
;══════════════════════════════════════════════════════════════════════════════

mainloop:
            bsr.s   wait_vblank
            bsr.s   read_joystick
            bsr.s   move_frog
            bsr     update_sprite

            btst    #6,$bfe001
            bne.s   mainloop
            bra.s   mainloop

;══════════════════════════════════════════════════════════════════════════════
; SUBROUTINES
;══════════════════════════════════════════════════════════════════════════════

wait_vblank:
            move.l  #$1ff00,d1
.wait:
            move.l  VPOSR(a5),d0
            and.l   d1,d0
            bne.s   .wait
            rts

read_joystick:
            move.w  JOY1DAT(a5),d0
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d1,d0
            rts

move_frog:
            btst    #8,d0
            beq.s   .no_up
            move.w  frog_y,d1
            sub.w   #MOVE_SPEED,d1
            cmp.w   #MIN_Y,d1
            blt.s   .no_up
            move.w  d1,frog_y
.no_up:
            btst    #0,d0
            beq.s   .no_down
            move.w  frog_y,d1
            add.w   #MOVE_SPEED,d1
            cmp.w   #MAX_Y,d1
            bgt.s   .no_down
            move.w  d1,frog_y
.no_down:
            btst    #9,d0
            beq.s   .no_left
            move.w  frog_x,d1
            sub.w   #MOVE_SPEED,d1
            cmp.w   #MIN_X,d1
            blt.s   .no_left
            move.w  d1,frog_x
.no_left:
            btst    #1,d0
            beq.s   .no_right
            move.w  frog_x,d1
            add.w   #MOVE_SPEED,d1
            cmp.w   #MAX_X,d1
            bgt.s   .no_right
            move.w  d1,frog_x
.no_right:
            rts

update_sprite:
            lea     frog_data,a0
            move.w  frog_y,d0
            move.w  frog_x,d1

            move.w  d0,d2
            lsl.w   #8,d2
            lsr.w   #1,d1
            or.b    d1,d2
            move.w  d2,(a0)

            add.w   #FROG_HEIGHT,d0
            lsl.w   #8,d0
            move.w  d0,2(a0)

            rts

;══════════════════════════════════════════════════════════════════════════════
; VARIABLES
;══════════════════════════════════════════════════════════════════════════════

frog_x:     dc.w    160
frog_y:     dc.w    220

;══════════════════════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════════════════════
; The playfield is organised as a 13-row grid, each row 16 pixels tall.
; Row numbers (1-13) and scanlines are:
;
;   Row 1  (Home)   : $2C-$3B (44-59)   - 5 docking spots
;   Row 2  (Water)  : $3C-$4B (60-75)   - Log/turtle lane 1
;   Row 3  (Water)  : $4C-$5B (76-91)   - Log/turtle lane 2
;   Row 4  (Water)  : $5C-$6B (92-107)  - Log/turtle lane 3
;   Row 5  (Water)  : $6C-$7B (108-123) - Log/turtle lane 4
;   Row 6  (Water)  : $7C-$8B (124-139) - Log/turtle lane 5
;   Row 7  (Median) : $8C-$9B (140-155) - Safe zone
;   Row 8  (Road)   : $9C-$AB (156-171) - Car lane 1
;   Row 9  (Road)   : $AC-$BB (172-187) - Car lane 2
;   Row 10 (Road)   : $BC-$CB (188-203) - Car lane 3
;   Row 11 (Road)   : $CC-$DB (204-219) - Car lane 4
;   Row 12 (Road)   : $DC-$EB (220-235) - Car lane 5
;   Row 13 (Start)  : $EC-$FB (236-251) - Starting area
;
; The Copper changes COLOR00 at each row boundary to create the zones.

copperlist:
            dc.w    COLOR00,COLOUR_BLACK    ; Black border at top

            ; --- Sprite palette (colours 17-19) ---
            dc.w    $01a2,COLOUR_FROG
            dc.w    $01a4,COLOUR_EYES
            dc.w    $01a6,COLOUR_OUTLINE

            ; --- Sprite 0 pointer ---
            dc.w    SPR0PTH
sprpth_val: dc.w    $0000
            dc.w    SPR0PTL
sprptl_val: dc.w    $0000

            ; ═══════════════════════════════════════════════════════════════
            ; ROW 1: HOME ZONE (scanline $2C = 44)
            ; ═══════════════════════════════════════════════════════════════
            dc.w    $2c07,$fffe
            dc.w    COLOR00,COLOUR_HOME
            dc.w    $3407,$fffe              ; Highlight stripe in home zone
            dc.w    COLOR00,COLOUR_HOME_LIT
            dc.w    $3807,$fffe
            dc.w    COLOR00,COLOUR_HOME

            ; ═══════════════════════════════════════════════════════════════
            ; ROWS 2-6: WATER ZONE (5 lanes)
            ; ═══════════════════════════════════════════════════════════════
            ; Alternating blue shades suggest rippling water

            ; Row 2: Water lane 1 (scanline $3C = 60)
            dc.w    $3c07,$fffe
            dc.w    COLOR00,COLOUR_WATER1

            ; Row 3: Water lane 2 (scanline $4C = 76)
            dc.w    $4c07,$fffe
            dc.w    COLOR00,COLOUR_WATER2

            ; Row 4: Water lane 3 (scanline $5C = 92)
            dc.w    $5c07,$fffe
            dc.w    COLOR00,COLOUR_WATER1

            ; Row 5: Water lane 4 (scanline $6C = 108)
            dc.w    $6c07,$fffe
            dc.w    COLOR00,COLOUR_WATER2

            ; Row 6: Water lane 5 (scanline $7C = 124)
            dc.w    $7c07,$fffe
            dc.w    COLOR00,COLOUR_WATER1

            ; ═══════════════════════════════════════════════════════════════
            ; ROW 7: MEDIAN - SAFE ZONE (scanline $8C = 140)
            ; ═══════════════════════════════════════════════════════════════
            dc.w    $8c07,$fffe
            dc.w    COLOR00,COLOUR_MEDIAN

            ; ═══════════════════════════════════════════════════════════════
            ; ROWS 8-12: ROAD ZONE (5 lanes)
            ; ═══════════════════════════════════════════════════════════════
            ; Alternating grey shades suggest lane markings

            ; Row 8: Road lane 1 (scanline $9C = 156)
            dc.w    $9c07,$fffe
            dc.w    COLOR00,COLOUR_ROAD1

            ; Row 9: Road lane 2 (scanline $AC = 172)
            dc.w    $ac07,$fffe
            dc.w    COLOR00,COLOUR_ROAD2

            ; Row 10: Road lane 3 (scanline $BC = 188)
            dc.w    $bc07,$fffe
            dc.w    COLOR00,COLOUR_ROAD1

            ; Row 11: Road lane 4 (scanline $CC = 204)
            dc.w    $cc07,$fffe
            dc.w    COLOR00,COLOUR_ROAD2

            ; Row 12: Road lane 5 (scanline $DC = 220)
            dc.w    $dc07,$fffe
            dc.w    COLOR00,COLOUR_ROAD1

            ; ═══════════════════════════════════════════════════════════════
            ; ROW 13: START ZONE (scanline $EC = 236)
            ; ═══════════════════════════════════════════════════════════════
            dc.w    $ec07,$fffe
            dc.w    COLOR00,COLOUR_START
            dc.w    $f407,$fffe              ; Highlight stripe in start zone
            dc.w    COLOR00,COLOUR_START_LIT
            dc.w    $f807,$fffe
            dc.w    COLOR00,COLOUR_START

            ; ═══════════════════════════════════════════════════════════════
            ; BOTTOM BORDER
            ; ═══════════════════════════════════════════════════════════════
            dc.w    $fc07,$fffe
            dc.w    COLOR00,COLOUR_BLACK

            ; End of copper list
            dc.w    $ffff,$fffe

;══════════════════════════════════════════════════════════════════════════════
; SPRITE DATA
;══════════════════════════════════════════════════════════════════════════════

            even
frog_data:
            dc.w    $dc50,$ec00             ; Control words (Y=220, X=160)

            ; 16 lines of image data
            dc.w    $0000,$0000             ; ................
            dc.w    $07e0,$0000             ; .....######.....
            dc.w    $1ff8,$0420             ; ...##########...
            dc.w    $3ffc,$0a50             ; ..############..
            dc.w    $7ffe,$1248             ; .##############.
            dc.w    $7ffe,$1008             ; .##############.
            dc.w    $ffff,$2004             ; ################
            dc.w    $ffff,$0000             ; ################
            dc.w    $ffff,$0000             ; ################
            dc.w    $7ffe,$2004             ; .##############.
            dc.w    $7ffe,$1008             ; .##############.
            dc.w    $3ffc,$0810             ; ..############..
            dc.w    $1ff8,$0420             ; ...##########...
            dc.w    $07e0,$0000             ; .....######.....
            dc.w    $0000,$0000             ; ................
            dc.w    $0000,$0000             ; ................

            dc.w    $0000,$0000             ; End marker
