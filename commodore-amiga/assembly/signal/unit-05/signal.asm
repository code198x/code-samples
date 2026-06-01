;══════════════════════════════════════════════════════════════════════════════
; SIGNAL - A Frogger-style game for the Commodore Amiga
; Unit 5: Grid-Based Movement
;
; Real Frogger doesn't glide—it hops. Each press moves the frog exactly one
; grid cell, with smooth animation over 8 frames. This unit implements that
; distinctive movement feel using a simple state machine.
;══════════════════════════════════════════════════════════════════════════════

;══════════════════════════════════════════════════════════════════════════════
; GRID CONSTANTS
;══════════════════════════════════════════════════════════════════════════════

; Grid dimensions
GRID_COLS       equ 20          ; 20 columns (320 ÷ 16)
GRID_ROWS       equ 13          ; 13 rows (matching our playfield)
CELL_SIZE       equ 16          ; Each cell is 16×16 pixels

; Grid origin (pixel coordinates of top-left cell)
GRID_ORIGIN_X   equ 48          ; Left margin
GRID_ORIGIN_Y   equ 44          ; Top of playfield

; Starting position (grid coordinates)
START_GRID_X    equ 9           ; Middle column (0-19)
START_GRID_Y    equ 12          ; Bottom row (0-12)

; Animation timing
HOP_FRAMES      equ 8           ; Animation lasts 8 frames
PIXELS_PER_FRAME equ 2          ; 2 pixels per frame × 8 frames = 16 pixels

; Movement states
STATE_IDLE      equ 0           ; Waiting for input
STATE_HOPPING   equ 1           ; Currently animating a hop

; Direction codes
DIR_UP          equ 0
DIR_DOWN        equ 1
DIR_LEFT        equ 2
DIR_RIGHT       equ 3

FROG_HEIGHT     equ 16

; Zone colours
COLOUR_BLACK    equ $0000
COLOUR_HOME     equ $0282
COLOUR_HOME_LIT equ $03a3
COLOUR_WATER1   equ $0148
COLOUR_WATER2   equ $026a
COLOUR_MEDIAN   equ $0383
COLOUR_ROAD1    equ $0333
COLOUR_ROAD2    equ $0444
COLOUR_START    equ $0262
COLOUR_START_LIT equ $0373

; Sprite palette
COLOUR_FROG     equ $00f0
COLOUR_EYES     equ $0ff0
COLOUR_OUTLINE  equ $0000

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

            ; --- Initialise game state ---
            move.w  #START_GRID_X,frog_grid_x
            move.w  #START_GRID_Y,frog_grid_y
            move.w  #STATE_IDLE,frog_state
            move.w  #0,frog_anim_frame
            clr.w   joy_prev

            ; --- Calculate initial pixel position ---
            bsr     grid_to_pixels

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
            bsr     wait_vblank
            bsr     update_frog
            bsr     update_sprite
            bra.s   mainloop

;══════════════════════════════════════════════════════════════════════════════
; UPDATE_FROG - Main frog logic
;══════════════════════════════════════════════════════════════════════════════
; State machine:
;   IDLE: Check for joystick input, start hop if valid
;   HOPPING: Animate position, return to IDLE when complete

update_frog:
            tst.w   frog_state
            beq     .idle
            bra     .hopping

.idle:
            ; --- Read joystick with edge detection ---
            bsr     read_joystick_edge
            tst.w   d0
            beq     .done                   ; No new input

            ; --- Check each direction ---
            btst    #8,d0                   ; Up?
            beq.s   .not_up
            move.w  frog_grid_y,d1
            tst.w   d1
            beq.s   .not_up                 ; Already at top
            move.w  #DIR_UP,frog_dir
            bra.s   .start_hop
.not_up:
            btst    #0,d0                   ; Down?
            beq.s   .not_down
            move.w  frog_grid_y,d1
            cmp.w   #GRID_ROWS-1,d1
            beq.s   .not_down               ; Already at bottom
            move.w  #DIR_DOWN,frog_dir
            bra.s   .start_hop
.not_down:
            btst    #9,d0                   ; Left?
            beq.s   .not_left
            move.w  frog_grid_x,d1
            tst.w   d1
            beq.s   .not_left               ; Already at left
            move.w  #DIR_LEFT,frog_dir
            bra.s   .start_hop
.not_left:
            btst    #1,d0                   ; Right?
            beq     .done
            move.w  frog_grid_x,d1
            cmp.w   #GRID_COLS-1,d1
            beq     .done                   ; Already at right
            move.w  #DIR_RIGHT,frog_dir
            ; Fall through to start_hop

.start_hop:
            ; --- Begin hopping animation ---
            move.w  #STATE_HOPPING,frog_state
            move.w  #0,frog_anim_frame
            bra.s   .done

.hopping:
            ; --- Advance animation frame ---
            addq.w  #1,frog_anim_frame

            ; --- Move pixel position based on direction ---
            move.w  frog_dir,d0

            cmp.w   #DIR_UP,d0
            bne.s   .hop_not_up
            sub.w   #PIXELS_PER_FRAME,frog_pixel_y
            bra.s   .check_hop_done
.hop_not_up:
            cmp.w   #DIR_DOWN,d0
            bne.s   .hop_not_down
            add.w   #PIXELS_PER_FRAME,frog_pixel_y
            bra.s   .check_hop_done
.hop_not_down:
            cmp.w   #DIR_LEFT,d0
            bne.s   .hop_not_left
            sub.w   #PIXELS_PER_FRAME,frog_pixel_x
            bra.s   .check_hop_done
.hop_not_left:
            ; Must be RIGHT
            add.w   #PIXELS_PER_FRAME,frog_pixel_x

.check_hop_done:
            ; --- Check if animation complete ---
            cmp.w   #HOP_FRAMES,frog_anim_frame
            blt.s   .done

            ; --- Hop complete: update grid position ---
            move.w  frog_dir,d0

            cmp.w   #DIR_UP,d0
            bne.s   .end_not_up
            subq.w  #1,frog_grid_y
            bra.s   .snap_to_grid
.end_not_up:
            cmp.w   #DIR_DOWN,d0
            bne.s   .end_not_down
            addq.w  #1,frog_grid_y
            bra.s   .snap_to_grid
.end_not_down:
            cmp.w   #DIR_LEFT,d0
            bne.s   .end_not_left
            subq.w  #1,frog_grid_x
            bra.s   .snap_to_grid
.end_not_left:
            ; Must be RIGHT
            addq.w  #1,frog_grid_x

.snap_to_grid:
            ; --- Snap pixel position to grid (prevents drift) ---
            bsr     grid_to_pixels

            ; --- Return to idle state ---
            move.w  #STATE_IDLE,frog_state

.done:
            rts

;══════════════════════════════════════════════════════════════════════════════
; GRID_TO_PIXELS - Convert grid coordinates to pixel coordinates
;══════════════════════════════════════════════════════════════════════════════
; Input: frog_grid_x, frog_grid_y
; Output: frog_pixel_x, frog_pixel_y

grid_to_pixels:
            move.w  frog_grid_x,d0
            mulu    #CELL_SIZE,d0
            add.w   #GRID_ORIGIN_X,d0
            move.w  d0,frog_pixel_x

            move.w  frog_grid_y,d0
            mulu    #CELL_SIZE,d0
            add.w   #GRID_ORIGIN_Y,d0
            move.w  d0,frog_pixel_y

            rts

;══════════════════════════════════════════════════════════════════════════════
; READ_JOYSTICK_EDGE - Read joystick with edge detection
;══════════════════════════════════════════════════════════════════════════════
; Returns only newly-pressed directions (not held directions)
; Output: D0 = direction bits (only set on transition from not-pressed)

read_joystick_edge:
            ; --- Read and decode joystick ---
            move.w  JOY1DAT(a5),d0
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d1,d0               ; D0 = decoded current state

            ; --- Edge detection: current AND NOT previous ---
            move.w  joy_prev,d1
            not.w   d1                  ; D1 = NOT previous
            and.w   d0,d1               ; D1 = newly pressed only

            ; --- Save current state for next frame ---
            move.w  d0,joy_prev

            move.w  d1,d0               ; Return newly pressed in D0
            rts

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

update_sprite:
            lea     frog_data,a0
            move.w  frog_pixel_y,d0
            move.w  frog_pixel_x,d1

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

; Grid position (which cell the frog occupies)
frog_grid_x:    dc.w    9           ; Column (0-19)
frog_grid_y:    dc.w    12          ; Row (0-12)

; Pixel position (for rendering and animation)
frog_pixel_x:   dc.w    0           ; Screen X
frog_pixel_y:   dc.w    0           ; Screen Y

; Movement state machine
frog_state:     dc.w    0           ; 0=idle, 1=hopping
frog_dir:       dc.w    0           ; Direction of current hop
frog_anim_frame: dc.w   0           ; Current frame of hop animation (0-7)

; Input state
joy_prev:       dc.w    0           ; Previous joystick state (for edge detection)

;══════════════════════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════════════════════

copperlist:
            dc.w    COLOR00,COLOUR_BLACK

            ; --- Sprite palette ---
            dc.w    $01a2,COLOUR_FROG
            dc.w    $01a4,COLOUR_EYES
            dc.w    $01a6,COLOUR_OUTLINE

            ; --- Sprite 0 pointer ---
            dc.w    SPR0PTH
sprpth_val: dc.w    $0000
            dc.w    SPR0PTL
sprptl_val: dc.w    $0000

            ; ROW 1: HOME ZONE
            dc.w    $2c07,$fffe
            dc.w    COLOR00,COLOUR_HOME
            dc.w    $3407,$fffe
            dc.w    COLOR00,COLOUR_HOME_LIT
            dc.w    $3807,$fffe
            dc.w    COLOR00,COLOUR_HOME

            ; ROWS 2-6: WATER ZONE
            dc.w    $3c07,$fffe
            dc.w    COLOR00,COLOUR_WATER1
            dc.w    $4c07,$fffe
            dc.w    COLOR00,COLOUR_WATER2
            dc.w    $5c07,$fffe
            dc.w    COLOR00,COLOUR_WATER1
            dc.w    $6c07,$fffe
            dc.w    COLOR00,COLOUR_WATER2
            dc.w    $7c07,$fffe
            dc.w    COLOR00,COLOUR_WATER1

            ; ROW 7: MEDIAN
            dc.w    $8c07,$fffe
            dc.w    COLOR00,COLOUR_MEDIAN

            ; ROWS 8-12: ROAD ZONE
            dc.w    $9c07,$fffe
            dc.w    COLOR00,COLOUR_ROAD1
            dc.w    $ac07,$fffe
            dc.w    COLOR00,COLOUR_ROAD2
            dc.w    $bc07,$fffe
            dc.w    COLOR00,COLOUR_ROAD1
            dc.w    $cc07,$fffe
            dc.w    COLOR00,COLOUR_ROAD2
            dc.w    $dc07,$fffe
            dc.w    COLOR00,COLOUR_ROAD1

            ; ROW 13: START ZONE
            dc.w    $ec07,$fffe
            dc.w    COLOR00,COLOUR_START
            dc.w    $f407,$fffe
            dc.w    COLOR00,COLOUR_START_LIT
            dc.w    $f807,$fffe
            dc.w    COLOR00,COLOUR_START

            ; BOTTOM BORDER
            dc.w    $fc07,$fffe
            dc.w    COLOR00,COLOUR_BLACK

            dc.w    $ffff,$fffe

;══════════════════════════════════════════════════════════════════════════════
; SPRITE DATA
;══════════════════════════════════════════════════════════════════════════════

            even
frog_data:
            dc.w    $ec50,$fc00             ; Control words

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

            dc.w    $0000,$0000
