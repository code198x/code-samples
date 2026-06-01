;==============================================================================
; SIGNAL - A Frogger-style game for the Commodore Amiga
; Unit 10: Home Zones
;
; Stakes alone aren't enough—you need a goal. This unit adds 5 home zones at
; the top of the screen. Reach one, it fills in, you respawn. Fill all 5 to
; complete a round. Each successful docking scores 50 points.
;==============================================================================

;==============================================================================
; CONSTANTS
;==============================================================================

SCREEN_W        equ 40
SCREEN_H        equ 256
PLANE_SIZE      equ SCREEN_W*SCREEN_H

GRID_COLS       equ 20
GRID_ROWS       equ 13
CELL_SIZE       equ 16
GRID_ORIGIN_X   equ 48
GRID_ORIGIN_Y   equ 44
START_GRID_X    equ 9
START_GRID_Y    equ 12

HOP_FRAMES      equ 8
PIXELS_PER_FRAME equ 2
STATE_IDLE      equ 0
STATE_HOPPING   equ 1
STATE_DYING     equ 2
STATE_GAMEOVER  equ 3
DIR_UP          equ 0
DIR_DOWN        equ 1
DIR_LEFT        equ 2
DIR_RIGHT       equ 3
FROG_HEIGHT     equ 16
FROG_WIDTH      equ 16

DEATH_FRAMES    equ 30
FLASH_COLOUR    equ $0f00

NUM_CARS        equ 10
CAR_WIDTH       equ 2
CAR_WIDTH_PX    equ 32
CAR_HEIGHT      equ 12
CAR_STRUCT_SIZE equ 8

ROAD_ROW_FIRST  equ 7
ROAD_ROW_LAST   equ 11

; Lives system
START_LIVES     equ 3
LIFE_ICON_W     equ 1
LIFE_ICON_H     equ 8
LIFE_ICON_X     equ 8
LIFE_ICON_Y     equ 260
LIFE_ICON_SPACING equ 20

; Home zones
NUM_HOMES       equ 5
HOME_ROW        equ 0           ; Top row of grid
POINTS_PER_HOME equ 50

; Home X positions (grid coordinates): 2, 6, 10, 14, 18
; Each home is 2 cells wide (even column = start of home)
HOME_0_X        equ 2
HOME_1_X        equ 6
HOME_2_X        equ 10
HOME_3_X        equ 14
HOME_4_X        equ 18

; Colours
COLOUR_BLACK    equ $0000
COLOUR_HOME     equ $0282
COLOUR_HOME_LIT equ $03a3
COLOUR_HOME_FILLED equ $0f80    ; Orange for filled homes
COLOUR_WATER1   equ $0148
COLOUR_WATER2   equ $026a
COLOUR_MEDIAN   equ $0383
COLOUR_ROAD1    equ $0333
COLOUR_ROAD2    equ $0444
COLOUR_START    equ $0262
COLOUR_START_LIT equ $0373
COLOUR_FROG     equ $00f0
COLOUR_EYES     equ $0ff0
COLOUR_OUTLINE  equ $0000
COLOUR_CAR      equ $0f00
COLOUR_LIFE     equ $00f0

;==============================================================================
; HARDWARE REGISTERS
;==============================================================================

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
SPR1PTH     equ $124
SPR1PTL     equ $126
SPR2PTH     equ $128
SPR2PTL     equ $12a

;==============================================================================
; CODE SECTION
;==============================================================================

            section code,code_c

start:
            lea     CUSTOM,a5

            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            bsr     clear_screen

            ; Set up bitplane pointer
            lea     screen_plane,a0
            move.l  a0,d0
            swap    d0
            lea     bplpth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     bplptl_val,a1
            move.w  d0,(a1)

            ; Initialise game
            bsr     init_game

            ; Set main sprite pointer (sprite 0 = frog)
            lea     frog_data,a0
            move.l  a0,d0
            swap    d0
            lea     sprpth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     sprptl_val,a1
            move.w  d0,(a1)

            ; Set up life icon sprites (sprites 1, 2, 3)
            bsr     setup_life_sprites

            bsr     update_sprite
            bsr     update_life_display

            ; Install copper list
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; Enable DMA
            move.w  #$87e0,DMACON(a5)

;==============================================================================
; MAIN LOOP
;==============================================================================

mainloop:
            bsr     wait_vblank

            ; Check game state
            cmp.w   #STATE_GAMEOVER,frog_state
            beq     .game_over_loop

            ; Normal game loop
            bsr     update_frog
            bsr     update_sprite

            bsr     erase_all_cars
            bsr     move_all_cars
            bsr     draw_all_cars

            cmp.w   #STATE_DYING,frog_state
            beq.s   .skip_collision
            cmp.w   #STATE_IDLE,frog_state
            bne.s   .skip_collision
            bsr     check_home
            bsr     check_collision
.skip_collision:

            bra     mainloop

.game_over_loop:
            ; Game over - wait for fire button to restart
            btst    #7,$bfe001
            bne.s   mainloop

            ; Restart game
            bsr     init_game
            bsr     update_life_display
            bsr     clear_screen

            bra     mainloop

;==============================================================================
; GAME INITIALISATION
;==============================================================================

init_game:
            move.w  #START_LIVES,lives
            clr.l   score

            ; Clear all homes
            lea     home_filled,a0
            moveq   #NUM_HOMES-1,d0
.clear_homes:
            clr.w   (a0)+
            dbf     d0,.clear_homes

            bsr     update_home_display
            bsr     reset_frog
            rts

;==============================================================================
; HOME ZONE DETECTION
;==============================================================================

;------------------------------------------------------------------------------
; CHECK_HOME - Check if frog has reached a home zone
;------------------------------------------------------------------------------
check_home:
            ; Only check if at top row
            move.w  frog_grid_y,d0
            tst.w   d0
            bne     .not_home

            ; At top row - determine which home
            move.w  frog_grid_x,d0

            ; Check home 0 (X = 2-3)
            cmp.w   #HOME_0_X,d0
            blt.s   .not_home
            cmp.w   #HOME_0_X+2,d0
            blt.s   .home_0

            ; Check home 1 (X = 6-7)
            cmp.w   #HOME_1_X,d0
            blt.s   .not_home
            cmp.w   #HOME_1_X+2,d0
            blt.s   .home_1

            ; Check home 2 (X = 10-11)
            cmp.w   #HOME_2_X,d0
            blt.s   .not_home
            cmp.w   #HOME_2_X+2,d0
            blt.s   .home_2

            ; Check home 3 (X = 14-15)
            cmp.w   #HOME_3_X,d0
            blt.s   .not_home
            cmp.w   #HOME_3_X+2,d0
            blt.s   .home_3

            ; Check home 4 (X = 18-19)
            cmp.w   #HOME_4_X,d0
            blt.s   .not_home
            cmp.w   #HOME_4_X+2,d0
            blt.s   .home_4

            ; Between homes - death!
            bra     .death_between

.home_0:    moveq   #0,d1
            bra.s   .check_filled
.home_1:    moveq   #1,d1
            bra.s   .check_filled
.home_2:    moveq   #2,d1
            bra.s   .check_filled
.home_3:    moveq   #3,d1
            bra.s   .check_filled
.home_4:    moveq   #4,d1

.check_filled:
            ; D1 = home index (0-4)
            lea     home_filled,a0
            add.w   d1,d1               ; *2 for word offset
            tst.w   0(a0,d1.w)
            bne.s   .death_filled       ; Already filled - death!

            ; Home is empty - fill it!
            move.w  #1,0(a0,d1.w)

            ; Add points
            add.l   #POINTS_PER_HOME,score

            ; Update display
            bsr     update_home_display

            ; Check if all homes filled
            bsr     check_round_complete

            ; Respawn frog
            bsr     reset_frog
            rts

.death_filled:
            ; Landed on filled home - death
            bsr     trigger_death
            rts

.death_between:
            ; Landed between homes (on lily pad gaps) - death
            bsr     trigger_death
            rts

.not_home:
            rts

;------------------------------------------------------------------------------
; CHECK_ROUND_COMPLETE - Check if all 5 homes are filled
;------------------------------------------------------------------------------
check_round_complete:
            lea     home_filled,a0
            moveq   #NUM_HOMES-1,d0
            moveq   #0,d1               ; Count filled homes

.loop:
            tst.w   (a0)+
            beq.s   .not_complete
            addq.w  #1,d1
            dbf     d0,.loop

            ; All homes filled - reset for next round
            cmp.w   #NUM_HOMES,d1
            bne.s   .not_complete

            ; Clear all homes for next round
            lea     home_filled,a0
            moveq   #NUM_HOMES-1,d0
.clear:
            clr.w   (a0)+
            dbf     d0,.clear

            bsr     update_home_display
            ; Could add bonus points here, increase speed, etc.

.not_complete:
            rts

;------------------------------------------------------------------------------
; UPDATE_HOME_DISPLAY - Update Copper colours to show filled homes
;------------------------------------------------------------------------------
update_home_display:
            lea     home_filled,a0
            lea     home_colour_0,a1

            ; Home 0
            tst.w   (a0)+
            beq.s   .home0_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            bra.s   .home1
.home0_empty:
            move.w  #COLOUR_HOME_LIT,(a1)

.home1:
            lea     home_colour_1,a1
            tst.w   (a0)+
            beq.s   .home1_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            bra.s   .home2
.home1_empty:
            move.w  #COLOUR_HOME_LIT,(a1)

.home2:
            lea     home_colour_2,a1
            tst.w   (a0)+
            beq.s   .home2_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            bra.s   .home3
.home2_empty:
            move.w  #COLOUR_HOME_LIT,(a1)

.home3:
            lea     home_colour_3,a1
            tst.w   (a0)+
            beq.s   .home3_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            bra.s   .home4
.home3_empty:
            move.w  #COLOUR_HOME_LIT,(a1)

.home4:
            lea     home_colour_4,a1
            tst.w   (a0)+
            beq.s   .home4_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            rts
.home4_empty:
            move.w  #COLOUR_HOME_LIT,(a1)
            rts

;==============================================================================
; LIFE DISPLAY
;==============================================================================

setup_life_sprites:
            ; Sprite 1
            lea     life_icon_1,a0
            move.l  a0,d0
            swap    d0
            lea     spr1pth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     spr1ptl_val,a1
            move.w  d0,(a1)

            ; Sprite 2
            lea     life_icon_2,a0
            move.l  a0,d0
            swap    d0
            lea     spr2pth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     spr2ptl_val,a1
            move.w  d0,(a1)

            ; Sprite 3
            lea     life_icon_3,a0
            move.l  a0,d0
            swap    d0
            lea     spr3pth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     spr3ptl_val,a1
            move.w  d0,(a1)

            rts

update_life_display:
            ; Life 1 (always show if lives >= 1)
            lea     life_icon_1,a0
            move.w  lives,d0
            cmp.w   #1,d0
            blt.s   .hide_life1
            move.w  #$1e20,$0(a0)
            move.w  #$2600,$2(a0)
            bra.s   .life2
.hide_life1:
            clr.l   (a0)

.life2:
            lea     life_icon_2,a0
            cmp.w   #2,d0
            blt.s   .hide_life2
            move.w  #$1e28,$0(a0)
            move.w  #$2600,$2(a0)
            bra.s   .life3
.hide_life2:
            clr.l   (a0)

.life3:
            lea     life_icon_3,a0
            cmp.w   #3,d0
            blt.s   .hide_life3
            move.w  #$1e30,$0(a0)
            move.w  #$2600,$2(a0)
            rts
.hide_life3:
            clr.l   (a0)
            rts

;==============================================================================
; COLLISION AND DEATH
;==============================================================================

check_collision:
            move.w  frog_grid_y,d0
            cmp.w   #ROAD_ROW_FIRST,d0
            blt     .no_collision
            cmp.w   #ROAD_ROW_LAST,d0
            bgt     .no_collision

            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  2(a2),d1
            cmp.w   d0,d1
            bne.s   .next_car

            move.w  frog_pixel_x,d2
            move.w  (a2),d3

            move.w  d2,d4
            add.w   #FROG_WIDTH,d4
            cmp.w   d3,d4
            ble.s   .next_car

            move.w  d3,d4
            add.w   #CAR_WIDTH_PX,d4
            cmp.w   d2,d4
            ble.s   .next_car

            bsr     trigger_death
            bra.s   .no_collision

.next_car:
            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop

.no_collision:
            rts

trigger_death:
            move.w  #STATE_DYING,frog_state
            move.w  #DEATH_FRAMES,death_timer
            move.w  #FLASH_COLOUR,flash_colour

            ; Decrement lives
            subq.w  #1,lives
            bsr     update_life_display

            rts

reset_frog:
            move.w  #START_GRID_X,frog_grid_x
            move.w  #START_GRID_Y,frog_grid_y
            move.w  #STATE_IDLE,frog_state
            clr.w   frog_anim_frame
            clr.w   joy_prev
            move.w  #COLOUR_BLACK,flash_colour
            bsr     grid_to_pixels
            rts

;==============================================================================
; CAR MANAGEMENT
;==============================================================================

erase_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0
            move.w  2(a2),d1
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

move_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0
            move.w  4(a2),d1
            add.w   d1,d0

            tst.w   d1
            bmi.s   .check_left
            cmp.w   #320,d0
            blt.s   .store
            sub.w   #320+32,d0
            bra.s   .store
.check_left:
            cmp.w   #-32,d0
            bgt.s   .store
            add.w   #320+32,d0
.store:
            move.w  d0,(a2)
            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop
            rts

draw_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0
            move.w  2(a2),d1

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

;==============================================================================
; FROG ROUTINES
;==============================================================================

update_frog:
            move.w  frog_state,d0

            cmp.w   #STATE_DYING,d0
            beq     .dying
            tst.w   d0
            beq     .idle
            bra     .hopping

.dying:
            subq.w  #1,death_timer
            bgt.s   .still_dying

            ; Death complete - check for game over
            tst.w   lives
            beq.s   .game_over

            ; Still have lives - respawn
            bsr     reset_frog
            bra     .done

.game_over:
            move.w  #STATE_GAMEOVER,frog_state
            bra     .done

.still_dying:
            move.w  death_timer,d0
            and.w   #4,d0
            beq.s   .flash_off
            move.w  #FLASH_COLOUR,flash_colour
            bra     .done
.flash_off:
            move.w  #COLOUR_BLACK,flash_colour
            bra     .done

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
            move.w  flash_colour,flash_copper
            rts

;==============================================================================
; UTILITY ROUTINES
;==============================================================================

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

;==============================================================================
; VARIABLES
;==============================================================================

frog_grid_x:    dc.w    9
frog_grid_y:    dc.w    12
frog_pixel_x:   dc.w    0
frog_pixel_y:   dc.w    0
frog_state:     dc.w    0
frog_dir:       dc.w    0
frog_anim_frame: dc.w   0
joy_prev:       dc.w    0

death_timer:    dc.w    0
flash_colour:   dc.w    0

lives:          dc.w    3
score:          dc.l    0

; Home zone state (0 = empty, 1 = filled)
home_filled:    dc.w    0,0,0,0,0

car_data:
            dc.w    0,7,1,0
            dc.w    160,7,1,0
            dc.w    100,8,-2,0
            dc.w    250,8,-2,0
            dc.w    50,9,2,0
            dc.w    200,9,2,0
            dc.w    80,10,-1,0
            dc.w    220,10,-1,0
            dc.w    30,11,3,0
            dc.w    180,11,3,0

;==============================================================================
; COPPER LIST
;==============================================================================

copperlist:
            dc.w    COLOR00
flash_copper:
            dc.w    COLOUR_BLACK

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

            ; Sprite 0-1 palette (frog and life icons share this)
            dc.w    $01a2,COLOUR_FROG
            dc.w    $01a4,COLOUR_EYES
            dc.w    $01a6,COLOUR_OUTLINE

            ; Sprite 0 pointer (main frog)
            dc.w    SPR0PTH
sprpth_val: dc.w    $0000
            dc.w    SPR0PTL
sprptl_val: dc.w    $0000

            ; Sprite 1 pointer (life icon 1)
            dc.w    SPR1PTH
spr1pth_val: dc.w   $0000
            dc.w    SPR1PTL
spr1ptl_val: dc.w   $0000

            ; Sprite 2 pointer (life icon 2)
            dc.w    SPR2PTH
spr2pth_val: dc.w   $0000
            dc.w    SPR2PTL
spr2ptl_val: dc.w   $0000

            ; Sprite 3 pointer (life icon 3)
            dc.w    $0126           ; SPR3PTH
spr3pth_val: dc.w   $0000
            dc.w    $012a           ; SPR3PTL
spr3ptl_val: dc.w   $0000

            ; Home zone row - 5 distinct zones for visual feedback
            ; Each home changes colour when filled
            dc.w    $2c07,$fffe
            dc.w    COLOR00,COLOUR_HOME     ; Gaps between homes

            ; Home 0 (columns 2-3, pixels 48+32=80 to 48+48=96)
            dc.w    $2c4f,$fffe             ; Wait for X=79
            dc.w    COLOR00
home_colour_0:
            dc.w    COLOUR_HOME_LIT

            dc.w    $2c5f,$fffe             ; Wait for X=95
            dc.w    COLOR00,COLOUR_HOME     ; Gap

            ; Home 1 (columns 6-7)
            dc.w    $2c8f,$fffe             ; Wait for X=143
            dc.w    COLOR00
home_colour_1:
            dc.w    COLOUR_HOME_LIT

            dc.w    $2c9f,$fffe             ; Wait for X=159
            dc.w    COLOR00,COLOUR_HOME     ; Gap

            ; Home 2 (columns 10-11)
            dc.w    $2ccf,$fffe             ; Wait for X=207
            dc.w    COLOR00
home_colour_2:
            dc.w    COLOUR_HOME_LIT

            dc.w    $2cdf,$fffe             ; Wait for X=223
            dc.w    COLOR00,COLOUR_HOME     ; Gap

            ; Home 3 (columns 14-15) - past X=223, need high bit
            dc.w    $2d07,$fffe             ; Wait for next pixel region
            dc.w    COLOR00
home_colour_3:
            dc.w    COLOUR_HOME_LIT

            dc.w    $2d17,$fffe
            dc.w    COLOR00,COLOUR_HOME     ; Gap

            ; Home 4 (columns 18-19)
            dc.w    $2d47,$fffe
            dc.w    COLOR00
home_colour_4:
            dc.w    COLOUR_HOME_LIT

            dc.w    $2d57,$fffe
            dc.w    COLOR00,COLOUR_HOME     ; End

            ; Rest of home row - solid colour
            dc.w    $3407,$fffe
            dc.w    COLOR00,COLOUR_HOME_LIT
            dc.w    $3807,$fffe
            dc.w    COLOR00,COLOUR_HOME

            ; Water rows
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

            ; Median
            dc.w    $8c07,$fffe
            dc.w    COLOR00,COLOUR_MEDIAN

            ; Road rows
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

            ; Start zone
            dc.w    $ec07,$fffe
            dc.w    COLOR00,COLOUR_START
            dc.w    $f407,$fffe
            dc.w    COLOR00,COLOUR_START_LIT
            dc.w    $f807,$fffe
            dc.w    COLOR00,COLOUR_START

            dc.w    $fc07,$fffe
            dc.w    COLOR00,COLOUR_BLACK

            dc.w    $ffff,$fffe

;==============================================================================
; GRAPHICS DATA
;==============================================================================

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

; Life icon sprites (small frog shape, 8 pixels tall)
            even
life_icon_1:
            dc.w    $0000,$0000
            dc.w    $0000,$0000
            dc.w    $1800,$0000
            dc.w    $3c00,$0000
            dc.w    $7e00,$0000
            dc.w    $7e00,$0000
            dc.w    $3c00,$0000
            dc.w    $1800,$0000
            dc.w    $0000,$0000
            dc.w    $0000,$0000

            even
life_icon_2:
            dc.w    $0000,$0000
            dc.w    $0000,$0000
            dc.w    $1800,$0000
            dc.w    $3c00,$0000
            dc.w    $7e00,$0000
            dc.w    $7e00,$0000
            dc.w    $3c00,$0000
            dc.w    $1800,$0000
            dc.w    $0000,$0000
            dc.w    $0000,$0000

            even
life_icon_3:
            dc.w    $0000,$0000
            dc.w    $0000,$0000
            dc.w    $1800,$0000
            dc.w    $3c00,$0000
            dc.w    $7e00,$0000
            dc.w    $7e00,$0000
            dc.w    $3c00,$0000
            dc.w    $1800,$0000
            dc.w    $0000,$0000
            dc.w    $0000,$0000

;==============================================================================
; SCREEN BUFFER
;==============================================================================

            section chipbss,bss_c

            even
screen_plane:
            ds.b    PLANE_SIZE
