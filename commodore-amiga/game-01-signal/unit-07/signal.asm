;══════════════════════════════════════════════════════════════════════════════
; SIGNAL - A Frogger-style game for the Commodore Amiga
; Unit 7: Cars on the Road
;
; One car isn't traffic. This unit adds multiple cars across all five road
; lanes, each moving at different speeds. Some go left, some go right.
; The Blitter draws them all efficiently using a loop.
;══════════════════════════════════════════════════════════════════════════════

;══════════════════════════════════════════════════════════════════════════════
; CONSTANTS
;══════════════════════════════════════════════════════════════════════════════

; Screen setup
SCREEN_W        equ 40
SCREEN_H        equ 256
PLANE_SIZE      equ SCREEN_W*SCREEN_H

; Grid constants
GRID_COLS       equ 20
GRID_ROWS       equ 13
CELL_SIZE       equ 16
GRID_ORIGIN_X   equ 48
GRID_ORIGIN_Y   equ 44
START_GRID_X    equ 9
START_GRID_Y    equ 12

; Frog animation
HOP_FRAMES      equ 8
PIXELS_PER_FRAME equ 2
STATE_IDLE      equ 0
STATE_HOPPING   equ 1
DIR_UP          equ 0
DIR_DOWN        equ 1
DIR_LEFT        equ 2
DIR_RIGHT       equ 3
FROG_HEIGHT     equ 16

; Car constants
NUM_CARS        equ 10          ; Total cars
CAR_WIDTH       equ 2           ; 32 pixels = 2 words
CAR_HEIGHT      equ 12
CAR_STRUCT_SIZE equ 8           ; Bytes per car: x(2), row(2), speed(2), pad(2)

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

; Sprite and car colours
COLOUR_FROG     equ $00f0
COLOUR_EYES     equ $0ff0
COLOUR_OUTLINE  equ $0000
COLOUR_CAR      equ $0f00

;══════════════════════════════════════════════════════════════════════════════
; HARDWARE REGISTERS
;══════════════════════════════════════════════════════════════════════════════

CUSTOM      equ $dff000

DMACONR     equ $002
VPOSR       equ $004
JOY1DAT     equ $00c

BLTCON0     equ $040
BLTCON1     equ $042
BLTAFWM     equ $044
BLTALWM     equ $046
BLTCPTH     equ $048
BLTBPTH     equ $04c
BLTAPTH     equ $050
BLTDPTH     equ $054
BLTSIZE     equ $058
BLTCMOD     equ $060
BLTBMOD     equ $062
BLTAMOD     equ $064
BLTDMOD     equ $066

COP1LC      equ $080
COPJMP1     equ $088
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
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

            ; --- Clear screen ---
            bsr     clear_screen

            ; --- Set up bitplane pointer ---
            lea     screen_plane,a0
            move.l  a0,d0
            swap    d0
            lea     bplpth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     bplptl_val,a1
            move.w  d0,(a1)

            ; --- Initialise frog ---
            move.w  #START_GRID_X,frog_grid_x
            move.w  #START_GRID_Y,frog_grid_y
            move.w  #STATE_IDLE,frog_state
            clr.w   joy_prev
            bsr     grid_to_pixels

            ; --- Set sprite pointer ---
            lea     frog_data,a0
            move.l  a0,d0
            swap    d0
            lea     sprpth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     sprptl_val,a1
            move.w  d0,(a1)
            bsr     update_sprite

            ; --- Install copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; --- Enable DMA ---
            move.w  #$87e0,DMACON(a5)

;══════════════════════════════════════════════════════════════════════════════
; MAIN LOOP
;══════════════════════════════════════════════════════════════════════════════

mainloop:
            bsr     wait_vblank

            ; --- Update frog ---
            bsr     update_frog
            bsr     update_sprite

            ; --- Update cars ---
            bsr     erase_all_cars
            bsr     move_all_cars
            bsr     draw_all_cars

            bra     mainloop

;══════════════════════════════════════════════════════════════════════════════
; CAR MANAGEMENT
;══════════════════════════════════════════════════════════════════════════════

;------------------------------------------------------------------------------
; ERASE_ALL_CARS - Clear all cars from screen
;------------------------------------------------------------------------------
erase_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0             ; X position
            move.w  2(a2),d1            ; Row

            bsr     calc_screen_addr
            bsr     wait_blit

            move.l  a0,BLTDPTH(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)
            move.w  #$0100,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)

            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop
            rts

;------------------------------------------------------------------------------
; MOVE_ALL_CARS - Update all car positions
;------------------------------------------------------------------------------
move_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0             ; X position
            move.w  4(a2),d1            ; Speed (signed)
            add.w   d1,d0               ; Move

            ; --- Wrap at screen edges ---
            tst.w   d1                  ; Check direction
            bmi.s   .check_left

            ; Moving right
            cmp.w   #320,d0
            blt.s   .store
            sub.w   #320+32,d0          ; Wrap from right to left
            bra.s   .store

.check_left:
            ; Moving left
            cmp.w   #-32,d0
            bgt.s   .store
            add.w   #320+32,d0          ; Wrap from left to right

.store:
            move.w  d0,(a2)             ; Store new X

            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop
            rts

;------------------------------------------------------------------------------
; DRAW_ALL_CARS - Draw all cars to screen
;------------------------------------------------------------------------------
draw_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0             ; X position
            move.w  2(a2),d1            ; Row

            ; Skip if offscreen
            cmp.w   #-32,d0
            blt.s   .next
            cmp.w   #320,d0
            bge.s   .next

            bsr     calc_screen_addr
            bsr     wait_blit

            move.l  #car_gfx,BLTAPTH(a5)
            move.l  a0,BLTDPTH(a5)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.w  #0,BLTAMOD(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)
            move.w  #$09f0,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)

.next:
            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop
            rts

;══════════════════════════════════════════════════════════════════════════════
; BLITTER UTILITIES
;══════════════════════════════════════════════════════════════════════════════

wait_blit:
            btst    #6,DMACONR(a5)
            bne.s   wait_blit
            rts

clear_screen:
            bsr.s   wait_blit
            move.l  #screen_plane,BLTDPTH(a5)
            move.w  #0,BLTDMOD(a5)
            move.w  #$0100,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #(SCREEN_H<<6)|SCREEN_W/2,BLTSIZE(a5)
            rts

calc_screen_addr:
            ; D0 = pixel X, D1 = row number -> A0 = screen address
            lea     screen_plane,a0

            move.w  d1,d2
            mulu    #CELL_SIZE,d2
            add.w   #GRID_ORIGIN_Y,d2
            mulu    #SCREEN_W,d2
            add.l   d2,a0

            move.w  d0,d2
            lsr.w   #3,d2
            ext.l   d2
            add.l   d2,a0
            rts

;══════════════════════════════════════════════════════════════════════════════
; FROG ROUTINES
;══════════════════════════════════════════════════════════════════════════════

update_frog:
            tst.w   frog_state
            beq     .idle
            bra     .hopping

.idle:
            bsr     read_joystick_edge
            tst.w   d0
            beq     .done

            btst    #8,d0
            beq.s   .not_up
            move.w  frog_grid_y,d1
            tst.w   d1
            beq.s   .not_up
            move.w  #DIR_UP,frog_dir
            bra.s   .start_hop
.not_up:
            btst    #0,d0
            beq.s   .not_down
            move.w  frog_grid_y,d1
            cmp.w   #GRID_ROWS-1,d1
            beq.s   .not_down
            move.w  #DIR_DOWN,frog_dir
            bra.s   .start_hop
.not_down:
            btst    #9,d0
            beq.s   .not_left
            move.w  frog_grid_x,d1
            tst.w   d1
            beq.s   .not_left
            move.w  #DIR_LEFT,frog_dir
            bra.s   .start_hop
.not_left:
            btst    #1,d0
            beq     .done
            move.w  frog_grid_x,d1
            cmp.w   #GRID_COLS-1,d1
            beq     .done
            move.w  #DIR_RIGHT,frog_dir

.start_hop:
            move.w  #STATE_HOPPING,frog_state
            clr.w   frog_anim_frame
            bra.s   .done

.hopping:
            addq.w  #1,frog_anim_frame
            move.w  frog_dir,d0

            cmp.w   #DIR_UP,d0
            bne.s   .hop_not_up
            sub.w   #PIXELS_PER_FRAME,frog_pixel_y
            bra.s   .check_done
.hop_not_up:
            cmp.w   #DIR_DOWN,d0
            bne.s   .hop_not_down
            add.w   #PIXELS_PER_FRAME,frog_pixel_y
            bra.s   .check_done
.hop_not_down:
            cmp.w   #DIR_LEFT,d0
            bne.s   .hop_not_left
            sub.w   #PIXELS_PER_FRAME,frog_pixel_x
            bra.s   .check_done
.hop_not_left:
            add.w   #PIXELS_PER_FRAME,frog_pixel_x

.check_done:
            cmp.w   #HOP_FRAMES,frog_anim_frame
            blt.s   .done

            move.w  frog_dir,d0
            cmp.w   #DIR_UP,d0
            bne.s   .end_not_up
            subq.w  #1,frog_grid_y
            bra.s   .snap
.end_not_up:
            cmp.w   #DIR_DOWN,d0
            bne.s   .end_not_down
            addq.w  #1,frog_grid_y
            bra.s   .snap
.end_not_down:
            cmp.w   #DIR_LEFT,d0
            bne.s   .end_not_left
            subq.w  #1,frog_grid_x
            bra.s   .snap
.end_not_left:
            addq.w  #1,frog_grid_x

.snap:
            bsr     grid_to_pixels
            move.w  #STATE_IDLE,frog_state

.done:
            rts

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

read_joystick_edge:
            move.w  JOY1DAT(a5),d0
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d1,d0

            move.w  joy_prev,d1
            not.w   d1
            and.w   d0,d1
            move.w  d0,joy_prev

            move.w  d1,d0
            rts

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

frog_grid_x:    dc.w    9
frog_grid_y:    dc.w    12
frog_pixel_x:   dc.w    0
frog_pixel_y:   dc.w    0
frog_state:     dc.w    0
frog_dir:       dc.w    0
frog_anim_frame: dc.w   0
joy_prev:       dc.w    0

; Car data: X position, Row, Speed, (padding)
; Row 7 = road lane 1 (rows 7-11 are road lanes)
car_data:
            ; Lane 1 (row 7) - moving right, speed 1
            dc.w    0,7,1,0
            dc.w    160,7,1,0

            ; Lane 2 (row 8) - moving left, speed -2
            dc.w    100,8,-2,0
            dc.w    250,8,-2,0

            ; Lane 3 (row 9) - moving right, speed 2
            dc.w    50,9,2,0
            dc.w    200,9,2,0

            ; Lane 4 (row 10) - moving left, speed -1
            dc.w    80,10,-1,0
            dc.w    220,10,-1,0

            ; Lane 5 (row 11) - moving right, speed 3
            dc.w    30,11,3,0
            dc.w    180,11,3,0

;══════════════════════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════════════════════

copperlist:
            dc.w    COLOR00,COLOUR_BLACK

            dc.w    $0100,$1200
            dc.w    $0102,$0000
            dc.w    $0104,$0000
            dc.w    $0108,$0000
            dc.w    $010a,$0000

            dc.w    $00e0
bplpth_val: dc.w    $0000
            dc.w    $00e2
bplptl_val: dc.w    $0000

            dc.w    $0180,$0000
            dc.w    $0182,COLOUR_CAR

            dc.w    $01a2,COLOUR_FROG
            dc.w    $01a4,COLOUR_EYES
            dc.w    $01a6,COLOUR_OUTLINE

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

            dc.w    $fc07,$fffe
            dc.w    COLOR00,COLOUR_BLACK

            dc.w    $ffff,$fffe

;══════════════════════════════════════════════════════════════════════════════
; GRAPHICS DATA
;══════════════════════════════════════════════════════════════════════════════

            even
car_gfx:
            dc.w    $0ff0,$0ff0
            dc.w    $3ffc,$3ffc
            dc.w    $7ffe,$7ffe
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $7ffe,$7ffe
            dc.w    $3c3c,$3c3c
            dc.w    $0000,$0000

            even
frog_data:
            dc.w    $ec50,$fc00

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

;══════════════════════════════════════════════════════════════════════════════
; SCREEN BUFFER
;══════════════════════════════════════════════════════════════════════════════

            section chipbss,bss_c

            even
screen_plane:
            ds.b    PLANE_SIZE
