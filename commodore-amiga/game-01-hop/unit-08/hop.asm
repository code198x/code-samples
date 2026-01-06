;=============================================================================
; HOP - Unit 08: Collision and Death
;=============================================================================
; Complete takeover Amiga game - no OS, direct hardware access
; Adds: car collision, water death, death animation, respawn
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

; DMA and interrupts
DMAF_SETCLR     equ $8000
DMAF_COPPER     equ $0080
DMAF_RASTER     equ $0100
DMAF_BLITTER    equ $0040
DMAF_SPRITE     equ $0020
INTF_VERTB      equ $0020
INTF_SETCLR     equ $8000

; Custom chip register offsets
DMACONR         equ $002
VPOSR           equ $004
VHPOSR          equ $006
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
COP1LCL         equ $082
COPJMP1         equ $088

; CIA
CIAA_PRA        equ $bfe001
JOY1DAT         equ $00c

; Frog
FROG_START_X    equ 152
FROG_START_Y    equ 220
FROG_WIDTH      equ 16
FROG_HEIGHT     equ 16
HOP_DISTANCE    equ 16

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
WATER_TOP       equ 64
WATER_BOT       equ 108
ROAD_TOP        equ 120
ROAD_BOT       equ 200

; Object dimensions (for collision)
OBJ_WIDTH       equ 32
OBJ_HEIGHT      equ 16

; Game states
STATE_ALIVE     equ 0
STATE_DYING     equ 1
STATE_DEAD      equ 2
DEATH_FRAMES    equ 30

;=============================================================================
; Entry Point
;=============================================================================

            section code,code

start:
            ; Disable interrupts and DMA
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,DMACON(a5)
            move.w  #$7fff,INTREQ(a5)

            ; Initialise game
            bsr     init_display
            bsr     init_sprites
            bsr     init_objects
            bsr     init_frog

            ; Enable required DMA
            move.w  #DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_SPRITE|DMAF_BLITTER,DMACON(a5)

main_loop:
            bsr     wait_vblank

            ; Always update world
            bsr     update_objects

            ; Check game state
            cmp.w   #STATE_ALIVE,frog_state
            bne.s   .skip_input

            ; Process input and collisions when alive
            bsr     read_joystick
            bsr     handle_movement
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

            ; Check for exit (left mouse button)
            btst    #6,CIAA_PRA
            bne     main_loop

            ; Exit - restore system
            move.w  #$7fff,DMACON(a5)
            move.w  #$7fff,INTENA(a5)
            moveq   #0,d0
            rts

;=============================================================================
; Initialisation
;=============================================================================

init_display:
            lea     CUSTOM,a5

            ; Point copper to our list
            lea     copperlist,a0
            move.l  a0,COP1LCH(a5)
            move.w  COPJMP1(a5),d0

            rts

init_sprites:
            ; Point sprite 0 to frog data
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
            ; Set up cars (road zone)
            lea     objects,a0

            ; Car 1 - lane 1
            move.w  #0,OBJ_X(a0)
            move.w  #140,OBJ_Y(a0)
            move.w  #2,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Car 2 - lane 1
            move.w  #160,OBJ_X(a0)
            move.w  #140,OBJ_Y(a0)
            move.w  #2,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Car 3 - lane 2
            move.w  #280,OBJ_X(a0)
            move.w  #160,OBJ_Y(a0)
            move.w  #-3,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Car 4 - lane 2
            move.w  #120,OBJ_X(a0)
            move.w  #160,OBJ_Y(a0)
            move.w  #-3,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Car 5 - lane 3
            move.w  #60,OBJ_X(a0)
            move.w  #180,OBJ_Y(a0)
            move.w  #1,OBJ_SPEED(a0)
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Log 1 - water lane 1
            move.w  #20,OBJ_X(a0)
            move.w  #76,OBJ_Y(a0)
            move.w  #1,OBJ_SPEED(a0)
            move.w  #TYPE_LOG,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Log 2 - water lane 1
            move.w  #180,OBJ_X(a0)
            move.w  #76,OBJ_Y(a0)
            move.w  #1,OBJ_SPEED(a0)
            move.w  #TYPE_LOG,OBJ_TYPE(a0)
            add.w   #OBJ_SIZE,a0

            ; Log 3 - water lane 2
            move.w  #100,OBJ_X(a0)
            move.w  #92,OBJ_Y(a0)
            move.w  #-2,OBJ_SPEED(a0)
            move.w  #TYPE_LOG,OBJ_TYPE(a0)

            rts

init_frog:
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            move.w  #STATE_ALIVE,frog_state
            clr.w   on_log
            clr.w   death_timer
            clr.w   joy_last
            rts

;=============================================================================
; Input Handling
;=============================================================================

read_joystick:
            lea     CUSTOM,a5
            move.w  JOY1DAT(a5),d0

            ; Decode directions into d1
            moveq   #0,d1

            ; Right: bit 1 XOR bit 9
            move.w  d0,d2
            lsr.w   #1,d2
            eor.w   d0,d2
            btst    #0,d2
            beq.s   .no_right
            or.w    #1,d1
.no_right:

            ; Left: bit 9 XOR bit 8
            move.w  d0,d2
            lsr.w   #1,d2
            eor.w   d0,d2
            btst    #8,d2
            beq.s   .no_left
            or.w    #2,d1
.no_left:

            ; Down: bit 1
            btst    #1,d0
            beq.s   .no_down
            or.w    #4,d1
.no_down:

            ; Up: bit 9
            btst    #9,d0
            beq.s   .no_up
            or.w    #8,d1
.no_up:

            move.w  d1,joy_current
            rts

handle_movement:
            ; Edge detection: only trigger on press, not hold
            move.w  joy_current,d0
            move.w  joy_last,d1
            not.w   d1
            and.w   d0,d1               ; d1 = newly pressed
            move.w  d0,joy_last

            ; Check each direction
            btst    #3,d1               ; Up
            beq.s   .no_up
            move.w  frog_y,d0
            sub.w   #HOP_DISTANCE,d0
            cmp.w   #48,d0
            blt.s   .no_up
            move.w  d0,frog_y
            clr.w   on_log              ; Left the log
.no_up:

            btst    #2,d1               ; Down
            beq.s   .no_down
            move.w  frog_y,d0
            add.w   #HOP_DISTANCE,d0
            cmp.w   #FROG_START_Y,d0
            bgt.s   .no_down
            move.w  d0,frog_y
            clr.w   on_log
.no_down:

            btst    #0,d1               ; Right
            beq.s   .no_right
            move.w  frog_x,d0
            add.w   #HOP_DISTANCE,d0
            cmp.w   #304,d0
            bgt.s   .no_right
            move.w  d0,frog_x
.no_right:

            btst    #1,d1               ; Left
            beq.s   .no_left
            move.w  frog_x,d0
            sub.w   #HOP_DISTANCE,d0
            bmi.s   .no_left
            move.w  d0,frog_x
.no_left:

            rts

;=============================================================================
; Platform and Collision
;=============================================================================

handle_platform:
            ; Clear platform state
            clr.w   on_log

            ; Check if in water zone
            move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .done
            cmp.w   #WATER_BOT,d0
            bge.s   .done

            ; In water - check each log
            lea     objects,a0
            move.w  #NUM_OBJECTS-1,d7

.loop:
            ; Only check logs
            cmp.w   #TYPE_LOG,OBJ_TYPE(a0)
            bne.s   .next

            ; Check Y overlap (same lane)
            move.w  frog_y,d0
            move.w  OBJ_Y(a0),d1
            sub.w   d1,d0               ; d0 = frog_y - obj_y
            bmi.s   .next               ; Frog above object
            cmp.w   #OBJ_HEIGHT,d0
            bge.s   .next               ; Frog below object

            ; Check X overlap
            move.w  frog_x,d0
            move.w  OBJ_X(a0),d1
            sub.w   d1,d0               ; d0 = frog_x - obj_x
            add.w   #FROG_WIDTH,d0
            bmi.s   .next               ; Frog completely left
            cmp.w   #OBJ_WIDTH+FROG_WIDTH,d0
            bge.s   .next               ; Frog completely right

            ; On this log!
            move.w  #1,on_log
            move.w  OBJ_SPEED(a0),d0
            add.w   d0,frog_x           ; Move with log
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

            ; Check Y overlap
            move.w  frog_y,d0
            move.w  OBJ_Y(a0),d1
            sub.w   d1,d0
            bmi.s   .next
            cmp.w   #OBJ_HEIGHT,d0
            bge.s   .next

            ; Check X overlap
            move.w  frog_x,d0
            move.w  OBJ_X(a0),d1
            sub.w   d1,d0
            add.w   #FROG_WIDTH,d0
            bmi.s   .next
            cmp.w   #OBJ_WIDTH+FROG_WIDTH,d0
            bge.s   .next

            ; Hit!
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

            ; In water zone?
            move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .done
            cmp.w   #WATER_BOT,d0
            bge.s   .done

            ; On a log?
            tst.w   on_log
            bne.s   .done

            ; Drowning!
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
.done:
            rts

update_death:
            cmp.w   #STATE_DYING,frog_state
            bne.s   .check_dead

            ; Count down
            subq.w  #1,death_timer
            bne.s   .flash

            ; Timer done - go to dead state
            move.w  #STATE_DEAD,frog_state
            bra.s   .respawn

.flash:
            ; Flash on odd frames
            move.w  death_timer,d0
            and.w   #1,d0
            bne.s   .done               ; Odd = hidden (sprite update handles)
            bra.s   .done

.check_dead:
            cmp.w   #STATE_DEAD,frog_state
            bne.s   .done

.respawn:
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            move.w  #STATE_ALIVE,frog_state
            clr.w   on_log

.done:
            rts

;=============================================================================
; Object Update
;=============================================================================

update_objects:
            lea     objects,a0
            move.w  #NUM_OBJECTS-1,d7

.loop:
            ; Skip empty slots
            tst.w   OBJ_TYPE(a0)
            beq.s   .next

            ; Move horizontally
            move.w  OBJ_SPEED(a0),d0
            add.w   d0,OBJ_X(a0)

            ; Wrap at screen edges
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
            ; Check death flash
            cmp.w   #STATE_DYING,frog_state
            bne.s   .visible

            move.w  death_timer,d0
            and.w   #1,d0
            bne.s   .hide

.visible:
            ; Calculate sprite position
            move.w  frog_x,d0
            add.w   #128,d0             ; Sprite X offset
            move.w  d0,d2               ; Save for low bit
            lsr.w   #1,d0               ; Divide by 2 for HSTART

            move.w  frog_y,d1
            add.w   #44,d1              ; Sprite Y offset

            ; Build control words
            move.w  d1,d3               ; VSTART
            lsl.w   #8,d3
            or.w    d0,d3               ; Add HSTART
            move.w  d3,frog_sprite      ; Control word 1

            move.w  d1,d3
            add.w   #FROG_HEIGHT,d3     ; VSTOP
            lsl.w   #8,d3
            and.w   #1,d2               ; Low bit of X
            or.w    d2,d3
            move.w  d3,frog_sprite+2    ; Control word 2
            bra.s   .done

.hide:
            ; Move sprite off-screen
            clr.l   frog_sprite

.done:
            rts

draw_objects:
            ; Use blitter to draw objects as rectangles
            lea     CUSTOM,a5
            lea     objects,a0
            lea     bitplane,a1
            move.w  #NUM_OBJECTS-1,d7

.loop:
            tst.w   OBJ_TYPE(a0)
            beq.s   .next

            ; Wait for blitter
.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            ; Calculate destination address
            move.w  OBJ_Y(a0),d0
            mulu.w  #SCREEN_WIDTH/8,d0
            move.w  OBJ_X(a0),d1
            bmi.s   .next               ; Skip if negative X
            lsr.w   #3,d1
            add.w   d1,d0
            lea     (a1,d0.w),a2

            ; Set up blitter for filled rectangle
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01f00000,BLTCON0(a5)  ; D=A, no shifts
            move.l  a2,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-4,BLTDMOD(a5)
            move.w  #(OBJ_HEIGHT<<6)|2,BLTSIZE(a5)  ; 16 lines, 2 words wide

.next:
            add.w   #OBJ_SIZE,a0
            dbf     d7,.loop
            rts

wait_vblank:
            lea     CUSTOM,a5
.wait:
            move.l  VPOSR(a5),d0
            and.l   #$1ff00,d0
            cmp.l   #$12c00,d0          ; Line 300
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
            dc.w    BPLCON0,$1200       ; 1 bitplane, colour on
            dc.w    BPLCON1,$0000
            dc.w    BPLCON2,$0000
            dc.w    BPL1PTH
bitplane_ptr_hi:
            dc.w    0
            dc.w    BPL1PTL
bitplane_ptr_lo:
            dc.w    0

            ; Colours
            dc.w    COLOR00,$0008       ; Dark blue background
            dc.w    COLOR00+2,$0fff     ; White for bitplane
            dc.w    COLOR00+34,$00f0    ; Green for sprite
            dc.w    COLOR00+36,$0080    ; Dark green
            dc.w    COLOR00+38,$00c0    ; Medium green

            ; End
            dc.w    $ffff,$fffe

            ; Copper list patch for bitplane pointer
            section code,code
            lea     bitplane,a0
            move.l  a0,d0
            lea     copperlist,a1
            move.w  d0,bitplane_ptr_lo-copperlist+2(a1)
            swap    d0
            move.w  d0,bitplane_ptr_hi-copperlist+2(a1)

frog_sprite:
            dc.w    $6050,$7800         ; Control words (Y=96, X=80, height=16)
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
            dc.w    $0000,$0000         ; End marker

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

            end
