;──────────────────────────────────────────────────────────────
; HOP - A Frogger-style game for the Commodore Amiga
; Unit 5: Traffic Flow
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000

; Custom chip register offsets
DMACONR     equ $002
VPOSR       equ $004
JOY1DAT     equ $00c
BLTCON0     equ $040
BLTCON1     equ $042
BLTAFWM     equ $044
BLTALWM     equ $046
BLTAPTH     equ $050
BLTDPTH     equ $054
BLTSIZE     equ $058
BLTAMOD     equ $064
BLTDMOD     equ $066
COP1LC      equ $080
COPJMP1     equ $088
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COLOR00     equ $180

; Screen constants
SCREEN_W    equ 40
SCREEN_H    equ 256
PLANE_SIZE  equ SCREEN_W*SCREEN_H

; Frog constants
HOP_SIZE    equ 16
FROG_HEIGHT equ 16
MIN_X       equ 32
MAX_X       equ 288
MIN_Y       equ 44
MAX_Y       equ 196

; Car constants
CAR_WIDTH   equ 1
CAR_HEIGHT  equ 8
CAR_X       equ 0
CAR_Y       equ 2
CAR_SPEED   equ 4
CAR_SIZE    equ 6
NUM_CARS    equ 4

;──────────────────────────────────────────────────────────────
; Code Section
;──────────────────────────────────────────────────────────────
            section code,code

start:
            lea     CUSTOM,a5

            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            bsr     clear_screen
            bsr     setup_copper_pointers

            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            move.w  #$83e0,DMACON(a5)

            move.w  #160,frog_x
            move.w  #180,frog_y
            bsr     update_sprite

mainloop:
            bsr     wait_vblank
            bsr     read_joystick
            bsr     update_frog
            bsr     update_sprite
            bsr     update_cars
            bra     mainloop

;──────────────────────────────────────────────────────────────
wait_vblank:
            move.l  #$1ff00,d1
.wait:
            move.l  VPOSR(a5),d0
            and.l   d1,d0
            bne.s   .wait
            rts

;──────────────────────────────────────────────────────────────
wait_blit:
            btst    #6,DMACONR(a5)
            bne.s   wait_blit
            rts

;──────────────────────────────────────────────────────────────
clear_screen:
            bsr.s   wait_blit
            move.l  #screen_plane1,BLTDPTH(a5)
            move.w  #0,BLTDMOD(a5)
            move.w  #$0100,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #(SCREEN_H<<6)|SCREEN_W/2,BLTSIZE(a5)
            bsr.s   wait_blit
            move.l  #screen_plane2,BLTDPTH(a5)
            move.w  #(SCREEN_H<<6)|SCREEN_W/2,BLTSIZE(a5)
            rts

;──────────────────────────────────────────────────────────────
setup_copper_pointers:
            ; Bitplane pointers
            lea     screen_plane1,a0
            lea     bplpt+2,a1
            move.l  a0,d0
            swap    d0
            move.w  d0,(a1)
            swap    d0
            move.w  d0,4(a1)

            lea     screen_plane2,a0
            move.l  a0,d0
            swap    d0
            move.w  d0,8(a1)
            swap    d0
            move.w  d0,12(a1)

            ; Sprite pointer
            lea     frog_data,a0
            lea     sprpt+2,a1
            move.l  a0,d0
            swap    d0
            move.w  d0,(a1)
            swap    d0
            move.w  d0,4(a1)
            rts

;──────────────────────────────────────────────────────────────
read_joystick:
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

;──────────────────────────────────────────────────────────────
update_frog:
            btst    #8,d0
            beq.s   .no_up
            move.w  frog_y,d1
            sub.w   #HOP_SIZE,d1
            cmp.w   #MIN_Y,d1
            blt.s   .no_up
            move.w  d1,frog_y
.no_up:
            btst    #0,d0
            beq.s   .no_down
            move.w  frog_y,d1
            add.w   #HOP_SIZE,d1
            cmp.w   #MAX_Y,d1
            bgt.s   .no_down
            move.w  d1,frog_y
.no_down:
            btst    #9,d0
            beq.s   .no_left
            move.w  frog_x,d1
            sub.w   #HOP_SIZE,d1
            cmp.w   #MIN_X,d1
            blt.s   .no_left
            move.w  d1,frog_x
.no_left:
            btst    #1,d0
            beq.s   .no_right
            move.w  frog_x,d1
            add.w   #HOP_SIZE,d1
            cmp.w   #MAX_X,d1
            bgt.s   .no_right
            move.w  d1,frog_x
.no_right:
            rts

;──────────────────────────────────────────────────────────────
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

;──────────────────────────────────────────────────────────────
; Update all cars
;──────────────────────────────────────────────────────────────
update_cars:
            lea     cars,a2
            move.w  #NUM_CARS-1,d7
.loop:
            ; Clear at old position
            move.w  CAR_X(a2),d0
            move.w  CAR_Y(a2),d1
            bsr     clear_car

            ; Update X position
            move.w  CAR_SPEED(a2),d0
            add.w   d0,CAR_X(a2)

            ; Wrap at edges
            move.w  CAR_X(a2),d0
            cmp.w   #320,d0
            blt.s   .check_left
            sub.w   #336,d0
            move.w  d0,CAR_X(a2)
            bra.s   .draw
.check_left:
            cmp.w   #-16,d0
            bge.s   .draw
            add.w   #336,d0
            move.w  d0,CAR_X(a2)
.draw:
            ; Draw at new position
            move.w  CAR_X(a2),d0
            move.w  CAR_Y(a2),d1
            bsr     draw_car

            lea     CAR_SIZE(a2),a2
            dbf     d7,.loop
            rts

;──────────────────────────────────────────────────────────────
; Clear car at D0=X, D1=Y
;──────────────────────────────────────────────────────────────
clear_car:
            ; Skip if off-screen
            tst.w   d0
            bmi.s   .done
            cmp.w   #320,d0
            bge.s   .done

            bsr     wait_blit

            lea     screen_plane1,a0
            mulu    #SCREEN_W,d1
            add.l   d1,a0
            move.w  d0,d2
            lsr.w   #3,d2
            ext.l   d2
            add.l   d2,a0

            move.l  a0,BLTDPTH(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)
            move.w  #$0100,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)
.done:
            rts

;──────────────────────────────────────────────────────────────
; Draw car at D0=X, D1=Y
;──────────────────────────────────────────────────────────────
draw_car:
            ; Skip if off-screen
            tst.w   d0
            bmi.s   .done
            cmp.w   #320,d0
            bge.s   .done

            bsr     wait_blit

            lea     screen_plane1,a0
            mulu    #SCREEN_W,d1
            add.l   d1,a0
            move.w  d0,d2
            lsr.w   #3,d2
            ext.l   d2
            add.l   d2,a0

            move.l  #car_gfx,BLTAPTH(a5)
            move.l  a0,BLTDPTH(a5)
            move.w  #$09f0,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.w  #0,BLTAMOD(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)
.done:
            rts

;──────────────────────────────────────────────────────────────
; Variables
;──────────────────────────────────────────────────────────────
frog_x:     dc.w    160
frog_y:     dc.w    180
joy_prev:   dc.w    0

; Car data: X, Y, Speed
cars:
            dc.w    0,122,2             ; Car 0: Lane 1, right
            dc.w    300,138,-3          ; Car 1: Lane 2, left
            dc.w    100,154,1           ; Car 2: Lane 3, right (slow)
            dc.w    200,170,-2          ; Car 3: Lane 4, left

;──────────────────────────────────────────────────────────────
; Chip RAM Data
;──────────────────────────────────────────────────────────────
            section chipdata,data_c

copperlist:
            dc.w    COLOR00,$0000

            dc.w    $0100,$2200
            dc.w    $0102,$0000
            dc.w    $0104,$0000
            dc.w    $0108,$0000
            dc.w    $010a,$0000

bplpt:
            dc.w    $00e0,$0000
            dc.w    $00e2,$0000
            dc.w    $00e4,$0000
            dc.w    $00e6,$0000

            dc.w    $0180,$0000
            dc.w    $0182,$0f00
            dc.w    $0184,$0ff0
            dc.w    $0186,$0fff

            dc.w    $01a2,$00f0
            dc.w    $01a4,$0ff0
            dc.w    $01a6,$0000

sprpt:
            dc.w    $0120,$0000
            dc.w    $0122,$0000

            dc.w    $2c07,$fffe
            dc.w    COLOR00,$0080

            dc.w    $4007,$fffe
            dc.w    COLOR00,$0048
            dc.w    $4c07,$fffe
            dc.w    COLOR00,$006b
            dc.w    $5407,$fffe
            dc.w    COLOR00,$0048
            dc.w    $5c07,$fffe
            dc.w    COLOR00,$006b
            dc.w    $6407,$fffe
            dc.w    COLOR00,$0048

            dc.w    $6c07,$fffe
            dc.w    COLOR00,$0080

            dc.w    $7807,$fffe
            dc.w    COLOR00,$0444
            dc.w    $8407,$fffe
            dc.w    COLOR00,$0666
            dc.w    $8807,$fffe
            dc.w    COLOR00,$0444
            dc.w    $9407,$fffe
            dc.w    COLOR00,$0666
            dc.w    $9807,$fffe
            dc.w    COLOR00,$0444
            dc.w    $a407,$fffe
            dc.w    COLOR00,$0666
            dc.w    $a807,$fffe
            dc.w    COLOR00,$0444

            dc.w    $b407,$fffe
            dc.w    COLOR00,$0080
            dc.w    $c007,$fffe
            dc.w    COLOR00,$0070

            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000

            dc.w    $ffff,$fffe

            even
car_gfx:
            dc.w    $ffff,$ffff,$ffff,$ffff
            dc.w    $ffff,$ffff,$ffff,$ffff

            even
frog_data:
            dc.w    $b460,$c400
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

            even
screen_plane1:
            ds.b    PLANE_SIZE
            even
screen_plane2:
            ds.b    PLANE_SIZE
