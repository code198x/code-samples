;=============================================================================
; HOP - Unit 10: Home Zone
;=============================================================================
; Complete takeover Amiga game - no OS, direct hardware access
; Adds: home slots, goal detection, level completion
;=============================================================================

; All hardware constants defined below - no external includes needed

;=============================================================================
; Constants
;=============================================================================

CUSTOM          equ $dff000

; Display
SCREEN_WIDTH    equ 320
SCREEN_HEIGHT   equ 256
BITPLANE_SIZE   equ (SCREEN_WIDTH/8)*SCREEN_HEIGHT
HUD_HEIGHT      equ 16

; DMA and interrupts
DMAF_SETCLR     equ $8000
DMAF_COPPER     equ $0080
DMAF_RASTER     equ $0100
DMAF_BLITTER    equ $0040
DMAF_SPRITE     equ $0020

; Custom chip register offsets
DMACONR         equ $002
VPOSR           equ $004
DMACON          equ $096
INTENA          equ $09a
INTREQ          equ $09c
BPLCON0         equ $100
BPLCON1         equ $102
BPLCON2         equ $104
BPL1PTH         equ $0e0
BPL1PTL         equ $0e2
DIWSTRT         equ $08e
DIWSTOP         equ $090
DDFSTRT         equ $092
DDFSTOP         equ $094
BLTCON0         equ $040
BLTCON1         equ $042
BLTAFWM         equ $044
BLTALWM         equ $046
BLTAMOD         equ $064
BLTDMOD         equ $066
BLTAPTH         equ $050
BLTDPTH         equ $054
BLTSIZE         equ $058
SPR0PTH         equ $120
SPR0PTL         equ $122
COLOR00         equ $180
COP1LCH         equ $080
COPJMP1         equ $088

; CIA
CIAA_PRA        equ $bfe001
JOY1DAT         equ $00c

; Frog
FROG_START_X    equ 152
FROG_START_Y    equ 236
FROG_WIDTH      equ 16
FROG_HEIGHT     equ 16
HOP_DISTANCE    equ 16

; Scoring
SCORE_HOP       equ 10
SCORE_HOME      equ 100
SCORE_LEVEL     equ 1000
SCORE_X         equ 8
SCORE_Y         equ 4
LIVES_X         equ 280
LIVES_Y         equ 4
STARTING_LIVES  equ 3

; Home zone
HOME_TOP        equ 48
HOME_BOT        equ 64
SLOT_WIDTH      equ 32
SLOT_HEIGHT     equ 16
SLOT_X          equ 0
SLOT_FILLED     equ 2
SLOT_SIZE       equ 4
NUM_SLOTS       equ 5

; Object system
OBJ_X           equ 0
OBJ_Y           equ 2
OBJ_SPEED       equ 4
OBJ_TYPE        equ 6
OBJ_SIZE        equ 8
NUM_OBJECTS     equ 8

; Object types
TYPE_NONE       equ 0
TYPE_CAR        equ 1
TYPE_LOG        equ 2

; Zone boundaries
WATER_TOP       equ 80
WATER_BOT       equ 124
ROAD_TOP        equ 136
ROAD_BOT        equ 216

; Object dimensions
OBJ_WIDTH       equ 32
OBJ_HEIGHT      equ 16

; Game states
STATE_ALIVE     equ 0
STATE_DYING     equ 1
STATE_DEAD      equ 2
STATE_GAMEOVER  equ 3
DEATH_FRAMES    equ 30

;=============================================================================
; Entry Point
;=============================================================================

            section code,code

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,DMACON(a5)
            move.w  #$7fff,INTREQ(a5)

            bsr     init_display
            bsr     init_sprites
            bsr     init_objects
            bsr     init_home
            bsr     init_frog

            move.w  #DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_SPRITE|DMAF_BLITTER,DMACON(a5)

main_loop:
            bsr     wait_vblank

            cmp.w   #STATE_GAMEOVER,frog_state
            beq     .game_over_loop

            bsr     update_objects

            cmp.w   #STATE_ALIVE,frog_state
            bne.s   .skip_input

            bsr     read_joystick
            bsr     handle_movement
            bsr     check_home_zone
            bsr     handle_platform
            bsr     check_bounds_death
            bsr     check_car_death
            bsr     check_water_death
            bra.s   .draw

.skip_input:
            bsr     update_death

.draw:
            bsr     update_frog_sprite
            bsr     draw_objects
            bsr     draw_home_zone
            bsr     draw_hud

            btst    #6,CIAA_PRA
            bne     main_loop

            bra.s   exit

.game_over_loop:
            bsr     draw_hud
            btst    #6,CIAA_PRA
            bne.s   .game_over_loop

exit:
            lea     CUSTOM,a5
            move.w  #$7fff,DMACON(a5)
            move.w  #$7fff,INTENA(a5)
            moveq   #0,d0
            rts

;=============================================================================
; Initialisation
;=============================================================================

init_display:
            lea     CUSTOM,a5

            lea     bitplane,a0
            move.l  a0,d0
            lea     copperlist,a1
            move.w  d0,bitplane_ptr_lo-copperlist+2(a1)
            swap    d0
            move.w  d0,bitplane_ptr_hi-copperlist+2(a1)

            lea     copperlist,a0
            move.l  a0,COP1LCH(a5)
            move.w  COPJMP1(a5),d0
            rts

init_sprites:
            lea     CUSTOM,a5
            lea     frog_sprite,a0
            move.l  a0,d0
            move.w  d0,SPR0PTL(a5)
            swap    d0
            move.w  d0,SPR0PTH(a5)

            ; Disable other sprites (1-7)
            lea     null_sprite,a0
            move.l  a0,d0
            lea     SPR0PTH+8(a5),a1      ; Start at sprite 1 (skip sprite 0)
            moveq   #6,d1                  ; 7 sprites to disable (1-7)
.disable:
            move.w  d0,(a1)+               ; SPRxPTH
            swap    d0
            move.w  d0,(a1)+               ; SPRxPTL
            swap    d0
            dbf     d1,.disable
            rts

init_objects:
            lea     objects,a0

            move.w  #0,OBJ_X(a0)
            move.w  #156,OBJ_Y(a0)
            move.w  #2,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #160,OBJ_X(a0)
            move.w  #156,OBJ_Y(a0)
            move.w  #2,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #280,OBJ_X(a0)
            move.w  #176,OBJ_Y(a0)
            move.w  #-3,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #120,OBJ_X(a0)
            move.w  #176,OBJ_Y(a0)
            move.w  #-3,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #60,OBJ_X(a0)
            move.w  #196,OBJ_Y(a0)
            move.w  #1,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #20,OBJ_X(a0)
            move.w  #92,OBJ_Y(a0)
            move.w  #1,OBJ_SPEED(a0)
            move.w  #TYPE_LOG,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #180,OBJ_X(a0)
            move.w  #92,OBJ_Y(a0)
            move.w  #1,OBJ_SPEED(a0)
            move.w  #TYPE_LOG,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            move.w  #100,OBJ_X(a0)
            move.w  #108,OBJ_Y(a0)
            move.w  #-2,OBJ_SPEED(a0)
            move.w  #TYPE_LOG,OBJ_TYPE(a0)
            rts

init_home:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7
.loop:
            clr.w   SLOT_FILLED(a0)
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop
            rts

init_frog:
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            move.w  #STATE_ALIVE,frog_state
            clr.w   on_log
            clr.w   death_timer
            clr.w   joy_last
            move.w  #STARTING_LIVES,lives
            clr.l   score
            rts

;=============================================================================
; Input Handling
;=============================================================================

read_joystick:
            lea     CUSTOM,a5
            move.w  JOY1DAT(a5),d0
            moveq   #0,d1

            move.w  d0,d2
            lsr.w   #1,d2
            eor.w   d0,d2
            btst    #0,d2
            beq.s   .no_right
            or.w    #1,d1
.no_right:

            move.w  d0,d2
            lsr.w   #1,d2
            eor.w   d0,d2
            btst    #8,d2
            beq.s   .no_left
            or.w    #2,d1
.no_left:

            btst    #1,d0
            beq.s   .no_down
            or.w    #4,d1
.no_down:

            btst    #9,d0
            beq.s   .no_up
            or.w    #8,d1
.no_up:

            move.w  d1,joy_current
            rts

handle_movement:
            move.w  joy_current,d0
            move.w  joy_last,d1
            not.w   d1
            and.w   d0,d1
            move.w  d0,joy_last

            btst    #3,d1
            beq.s   .no_up
            move.w  frog_y,d0
            sub.w   #HOP_DISTANCE,d0
            cmp.w   #HOME_TOP,d0
            blt.s   .no_up
            move.w  d0,frog_y
            clr.w   on_log
            add.l   #SCORE_HOP,score
.no_up:

            btst    #2,d1
            beq.s   .no_down
            move.w  frog_y,d0
            add.w   #HOP_DISTANCE,d0
            cmp.w   #FROG_START_Y,d0
            bgt.s   .no_down
            move.w  d0,frog_y
            clr.w   on_log
.no_down:

            btst    #0,d1
            beq.s   .no_right
            move.w  frog_x,d0
            add.w   #HOP_DISTANCE,d0
            cmp.w   #304,d0
            bgt.s   .no_right
            move.w  d0,frog_x
.no_right:

            btst    #1,d1
            beq.s   .no_left
            move.w  frog_x,d0
            sub.w   #HOP_DISTANCE,d0
            bmi.s   .no_left
            move.w  d0,frog_x
.no_left:
            rts

;=============================================================================
; Home Zone
;=============================================================================

check_home_zone:
            move.w  frog_y,d0
            cmp.w   #HOME_TOP,d0
            blt.s   .done
            cmp.w   #HOME_BOT,d0
            bge.s   .done

            bsr     find_home_slot
            tst.w   d0
            bmi.s   .in_gap

            bsr     fill_home_slot
            bra.s   .done

.in_gap:
            bsr     kill_frog
.done:
            rts

find_home_slot:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7
            moveq   #0,d1

.loop:
            move.w  SLOT_X(a0),d2
            move.w  frog_x,d0
            cmp.w   d2,d0
            blt.s   .next

            add.w   #SLOT_WIDTH,d2
            cmp.w   d2,d0
            bge.s   .next

            move.w  d1,d0
            rts

.next:
            add.w   #SLOT_SIZE,a0
            addq.w  #1,d1
            dbf     d7,.loop

            moveq   #-1,d0
            rts

fill_home_slot:
            lea     home_slots,a0
            move.w  d0,d1
            lsl.w   #2,d1
            add.w   d1,a0

            tst.w   SLOT_FILLED(a0)
            bne.s   .already_filled

            move.w  #1,SLOT_FILLED(a0)
            add.l   #SCORE_HOME,score

            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            clr.w   on_log

            bsr     check_level_complete
            rts

.already_filled:
            bsr     kill_frog
            rts

check_level_complete:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7

.loop:
            tst.w   SLOT_FILLED(a0)
            beq.s   .not_done
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop

            add.l   #SCORE_LEVEL,score
            bsr     reset_level
            rts

.not_done:
            rts

reset_level:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7

.loop:
            clr.w   SLOT_FILLED(a0)
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop
            rts

;=============================================================================
; Platform and Collision
;=============================================================================

handle_platform:
            clr.w   on_log

            move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .done
            cmp.w   #WATER_BOT,d0
            bge.s   .done

            lea     objects,a0
            move.w  #NUM_OBJECTS-1,d7

.loop:
            cmp.w   #TYPE_LOG,OBJ_TYPE(a0)
            bne.s   .next

            move.w  frog_y,d0
            move.w  OBJ_Y(a0),d1
            sub.w   d1,d0
            bmi.s   .next
            cmp.w   #OBJ_HEIGHT,d0
            bge.s   .next

            move.w  frog_x,d0
            move.w  OBJ_X(a0),d1
            sub.w   d1,d0
            add.w   #FROG_WIDTH,d0
            bmi.s   .next
            cmp.w   #OBJ_WIDTH+FROG_WIDTH,d0
            bge.s   .next

            move.w  #1,on_log
            move.w  OBJ_SPEED(a0),d0
            add.w   d0,frog_x
            bra.s   .done

.next:
            add.w   #OBJ_SIZE,a0
            dbf     d7,.loop
.done:
            rts

check_car_death:
            tst.w   frog_state
            bne.s   .done

            lea     objects,a0
            move.w  #NUM_OBJECTS-1,d7

.loop:
            cmp.w   #TYPE_CAR,OBJ_TYPE(a0)
            bne.s   .next

            move.w  frog_y,d0
            move.w  OBJ_Y(a0),d1
            sub.w   d1,d0
            bmi.s   .next
            cmp.w   #OBJ_HEIGHT,d0
            bge.s   .next

            move.w  frog_x,d0
            move.w  OBJ_X(a0),d1
            sub.w   d1,d0
            add.w   #FROG_WIDTH,d0
            bmi.s   .next
            cmp.w   #OBJ_WIDTH+FROG_WIDTH,d0
            bge.s   .next

            bsr     kill_frog
            bra.s   .done

.next:
            add.w   #OBJ_SIZE,a0
            dbf     d7,.loop
.done:
            rts

check_water_death:
            tst.w   frog_state
            bne.s   .done

            move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .done
            cmp.w   #WATER_BOT,d0
            bge.s   .done

            tst.w   on_log
            bne.s   .done

            bsr     kill_frog
.done:
            rts

check_bounds_death:
            tst.w   frog_state
            bne.s   .done

            move.w  frog_x,d0
            bmi.s   .kill
            cmp.w   #SCREEN_WIDTH-FROG_WIDTH,d0
            bgt.s   .kill
.done:
            rts
.kill:
            bsr     kill_frog
            rts

kill_frog:
            tst.w   frog_state
            bne.s   .done

            move.w  #STATE_DYING,frog_state
            move.w  #DEATH_FRAMES,death_timer
            subq.w  #1,lives
.done:
            rts

update_death:
            cmp.w   #STATE_DYING,frog_state
            bne.s   .check_dead

            subq.w  #1,death_timer
            bne.s   .done

            move.w  #STATE_DEAD,frog_state
            bra.s   .respawn

.check_dead:
            cmp.w   #STATE_DEAD,frog_state
            bne.s   .done

.respawn:
            tst.w   lives
            beq.s   .game_over

            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            move.w  #STATE_ALIVE,frog_state
            clr.w   on_log
            bra.s   .done

.game_over:
            move.w  #STATE_GAMEOVER,frog_state
.done:
            rts

;=============================================================================
; Object Update
;=============================================================================

update_objects:
            lea     objects,a0
            move.w  #NUM_OBJECTS-1,d7

.loop:
            tst.w   OBJ_TYPE(a0)
            beq.s   .next

            move.w  OBJ_SPEED(a0),d0
            add.w   d0,OBJ_X(a0)

            move.w  OBJ_X(a0),d0
            cmp.w   #SCREEN_WIDTH,d0
            blt.s   .check_left
            move.w  #-OBJ_WIDTH,OBJ_X(a0)
            bra.s   .next

.check_left:
            cmp.w   #-OBJ_WIDTH,d0
            bgt.s   .next
            move.w  #SCREEN_WIDTH,OBJ_X(a0)

.next:
            add.w   #OBJ_SIZE,a0
            dbf     d7,.loop
            rts

;=============================================================================
; Drawing
;=============================================================================

update_frog_sprite:
            cmp.w   #STATE_DYING,frog_state
            bne.s   .visible

            move.w  death_timer,d0
            and.w   #1,d0
            bne.s   .hide

.visible:
            cmp.w   #STATE_GAMEOVER,frog_state
            beq.s   .hide

            move.w  frog_x,d0
            add.w   #128,d0
            move.w  d0,d2
            lsr.w   #1,d0

            move.w  frog_y,d1
            add.w   #44,d1

            move.w  d1,d3
            lsl.w   #8,d3
            or.w    d0,d3
            move.w  d3,frog_sprite

            move.w  d1,d3
            add.w   #FROG_HEIGHT,d3
            lsl.w   #8,d3
            and.w   #1,d2
            or.w    d2,d3
            move.w  d3,frog_sprite+2
            bra.s   .done

.hide:
            clr.l   frog_sprite
.done:
            rts

draw_objects:
            lea     CUSTOM,a5
            lea     objects,a0
            lea     bitplane,a1
            move.w  #NUM_OBJECTS-1,d7

.loop:
            tst.w   OBJ_TYPE(a0)
            beq.s   .next

.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            move.w  OBJ_Y(a0),d0
            mulu.w  #SCREEN_WIDTH/8,d0
            move.w  OBJ_X(a0),d1
            bmi.s   .next
            lsr.w   #3,d1
            add.w   d1,d0
            lea     (a1,d0.w),a2

            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01f00000,BLTCON0(a5)
            move.l  a2,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-4,BLTDMOD(a5)
            move.w  #(OBJ_HEIGHT<<6)|2,BLTSIZE(a5)

.next:
            add.w   #OBJ_SIZE,a0
            dbf     d7,.loop
            rts

draw_home_zone:
            lea     home_slots,a0
            lea     CUSTOM,a5
            move.w  #NUM_SLOTS-1,d7

.loop:
            movem.l d7/a0,-(sp)

            move.w  SLOT_X(a0),d1
            move.w  #HOME_TOP,d2

            tst.w   SLOT_FILLED(a0)
            bne.s   .draw_filled

            bsr     draw_empty_slot
            bra.s   .next

.draw_filled:
            bsr     draw_filled_slot

.next:
            movem.l (sp)+,d7/a0
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop
            rts

draw_empty_slot:
            lea     CUSTOM,a5
.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            lea     bitplane,a1
            move.w  d2,d0
            mulu.w  #SCREEN_WIDTH/8,d0
            move.w  d1,d3
            lsr.w   #3,d3
            add.w   d3,d0
            add.w   d0,a1

            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01f00000,BLTCON0(a5)
            move.l  a1,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-4,BLTDMOD(a5)
            move.w  #(2<<6)|2,BLTSIZE(a5)
            rts

draw_filled_slot:
            lea     CUSTOM,a5
.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            lea     bitplane,a1
            move.w  d2,d0
            mulu.w  #SCREEN_WIDTH/8,d0
            move.w  d1,d3
            lsr.w   #3,d3
            add.w   d3,d0
            add.w   d0,a1

            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01f00000,BLTCON0(a5)
            move.l  a1,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-4,BLTDMOD(a5)
            move.w  #(SLOT_HEIGHT<<6)|2,BLTSIZE(a5)
            rts

;=============================================================================
; HUD Drawing
;=============================================================================

draw_hud:
            bsr     draw_score
            bsr     draw_lives_count
            rts

draw_score:
            move.l  score,d0
            move.w  #SCORE_X,d4
            move.w  #SCORE_Y,d5
            lea     powers_of_10,a2
            move.w  #5,d7

.digit_loop:
            move.l  (a2)+,d2
            moveq   #0,d1

.div_loop:
            cmp.l   d2,d0
            blt.s   .div_done
            sub.l   d2,d0
            addq.w  #1,d1
            bra.s   .div_loop

.div_done:
            movem.l d0/d4-d7/a2,-(sp)
            move.w  d1,d0
            move.w  d4,d1
            move.w  d5,d2
            bsr     draw_digit
            movem.l (sp)+,d0/d4-d7/a2

            addq.w  #8,d4
            dbf     d7,.digit_loop
            rts

draw_lives_count:
            move.w  lives,d0
            move.w  #LIVES_X,d1
            move.w  #LIVES_Y,d2
            bsr     draw_digit
            rts

draw_digit:
            lea     CUSTOM,a5
            movem.l d0-d2,-(sp)

.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            lea     font_digits,a0
            and.w   #$f,d0
            lsl.w   #3,d0
            add.w   d0,a0

            lea     bitplane,a1
            move.w  d2,d3
            mulu.w  #SCREEN_WIDTH/8,d3
            lsr.w   #3,d1
            add.w   d1,d3
            add.w   d3,a1

            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$09f00000,BLTCON0(a5)
            move.w  #0,BLTAMOD(a5)
            move.w  #(SCREEN_WIDTH/8)-1,BLTDMOD(a5)
            move.l  a0,BLTAPTH(a5)
            move.l  a1,BLTDPTH(a5)
            move.w  #(8<<6)|1,BLTSIZE(a5)

            movem.l (sp)+,d0-d2
            rts

wait_vblank:
            lea     CUSTOM,a5
.wait:
            move.l  VPOSR(a5),d0
            and.l   #$1ff00,d0
            cmp.l   #$12c00,d0
            bne.s   .wait
.wait2:
            move.l  VPOSR(a5),d0
            and.l   #$1ff00,d0
            cmp.l   #$12c00,d0
            beq.s   .wait2
            rts

;=============================================================================
; Data - Chip RAM
;=============================================================================

            section data,data_c

copperlist:
            dc.w    DIWSTRT,$2c81
            dc.w    DIWSTOP,$2cc1
            dc.w    DDFSTRT,$0038
            dc.w    DDFSTOP,$00d0
            dc.w    BPLCON0,$1200
            dc.w    BPLCON1,$0000
            dc.w    BPLCON2,$0000
            dc.w    BPL1PTH
bitplane_ptr_hi:
            dc.w    0
            dc.w    BPL1PTL
bitplane_ptr_lo:
            dc.w    0

            dc.w    COLOR00,$0008
            dc.w    COLOR00+2,$0fff
            dc.w    COLOR00+34,$00f0
            dc.w    COLOR00+36,$0080
            dc.w    COLOR00+38,$00c0

            dc.w    $ffff,$fffe

powers_of_10:
            dc.l    100000,10000,1000,100,10,1

; Home slots: X position, filled flag
home_slots:
            dc.w    24,0
            dc.w    88,0
            dc.w    152,0
            dc.w    216,0
            dc.w    280,0

font_digits:
            dc.b    %00111100,%01100110,%01101110,%01110110,%01100110,%01100110,%00111100,%00000000
            dc.b    %00011000,%00111000,%00011000,%00011000,%00011000,%00011000,%01111110,%00000000
            dc.b    %00111100,%01100110,%00000110,%00011100,%00110000,%01100000,%01111110,%00000000
            dc.b    %00111100,%01100110,%00000110,%00011100,%00000110,%01100110,%00111100,%00000000
            dc.b    %00001100,%00011100,%00101100,%01001100,%01111110,%00001100,%00001100,%00000000
            dc.b    %01111110,%01100000,%01111100,%00000110,%00000110,%01100110,%00111100,%00000000
            dc.b    %00011100,%00110000,%01100000,%01111100,%01100110,%01100110,%00111100,%00000000
            dc.b    %01111110,%00000110,%00001100,%00011000,%00110000,%00110000,%00110000,%00000000
            dc.b    %00111100,%01100110,%01100110,%00111100,%01100110,%01100110,%00111100,%00000000
            dc.b    %00111100,%01100110,%01100110,%00111110,%00000110,%00001100,%00111000,%00000000

frog_sprite:
            dc.w    $6050,$7800
            dc.w    %0000011111100000,%0000000000000000
            dc.w    %0001111111111000,%0000011111100000
            dc.w    %0011111111111100,%0001111111111000
            dc.w    %0111111111111110,%0011111111111100
            dc.w    %0111111111111110,%0111111111111110
            dc.w    %1111111111111111,%0111111111111110
            dc.w    %1111111111111111,%1111111111111111
            dc.w    %1111111111111111,%1111111111111111
            dc.w    %1111111111111111,%1111111111111111
            dc.w    %1111111111111111,%1111111111111111
            dc.w    %0111111111111110,%1111111111111111
            dc.w    %0111111111111110,%0111111111111110
            dc.w    %0011111111111100,%0111111111111110
            dc.w    %0001111111111000,%0011111111111100
            dc.w    %0000011111100000,%0001111111111000
            dc.w    %0000000000000000,%0000011111100000
            dc.w    $0000,$0000

null_sprite:
            dc.w    $0000,$0000
            dc.w    $0000,$0000

;=============================================================================
; Variables - Chip RAM
;=============================================================================

            section bss,bss_c

bitplane:
            ds.b    BITPLANE_SIZE

objects:
            ds.b    OBJ_SIZE*NUM_OBJECTS

;=============================================================================
; Variables - Any RAM
;=============================================================================

            section bss_fast,bss

frog_x:         ds.w    1
frog_y:         ds.w    1
frog_state:     ds.w    1
death_timer:    ds.w    1
on_log:         ds.w    1
joy_current:    ds.w    1
joy_last:       ds.w    1
lives:          ds.w    1
score:          ds.l    1

            end
