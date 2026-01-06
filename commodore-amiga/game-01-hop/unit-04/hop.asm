;──────────────────────────────────────────────────────────────
; HOP - A Frogger-style game for the Commodore Amiga
; Unit 4: The Traffic
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

; Screen constants
SCREEN_W    equ 40                  ; Bytes per line (320/8)
SCREEN_H    equ 256                 ; Lines
PLANE_SIZE  equ SCREEN_W*SCREEN_H   ; 10240 bytes

; Movement constants
HOP_SIZE    equ 16
FROG_HEIGHT equ 16
MIN_X       equ 32
MAX_X       equ 288
MIN_Y       equ 44
MAX_Y       equ 196

; Car constants
CAR_WIDTH   equ 1                   ; Words
CAR_HEIGHT  equ 8                   ; Lines
CAR_Y       equ 130                 ; Fixed Y for now

;──────────────────────────────────────────────────────────────
; Code Section
;──────────────────────────────────────────────────────────────
            section code,code

start:
            lea     CUSTOM,a5

            ; --- Take over the machine ---
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- Clear screen memory ---
            bsr     clear_screen

            ; --- Set up bitplane pointers in copper list ---
            lea     screen_plane1,a0
            lea     bplpt+2,a1
            move.l  a0,d0
            swap    d0
            move.w  d0,(a1)             ; BPL1PTH
            swap    d0
            move.w  d0,4(a1)            ; BPL1PTL

            lea     screen_plane2,a0
            move.l  a0,d0
            swap    d0
            move.w  d0,8(a1)            ; BPL2PTH
            swap    d0
            move.w  d0,12(a1)           ; BPL2PTL

            ; --- Set sprite pointer in copper list ---
            lea     frog_data,a0
            lea     sprpt+2,a1
            move.l  a0,d0
            swap    d0
            move.w  d0,(a1)
            swap    d0
            move.w  d0,4(a1)

            ; --- Install copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; --- Enable DMA ---
            move.w  #$83e0,DMACON(a5)   ; Master + copper + bitplane + sprite + blitter

            ; --- Initialise game state ---
            move.w  #160,frog_x
            move.w  #180,frog_y
            move.w  #0,car_x
            bsr     update_sprite

            ; === Main Loop ===
mainloop:
            bsr     wait_vblank
            bsr     read_joystick

            ; --- Update frog ---
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

            bsr     update_sprite

            ; --- Update car ---
            bsr     clear_car
            addq.w  #2,car_x            ; Move right
            cmp.w   #320,car_x
            blt.s   .no_wrap
            clr.w   car_x
.no_wrap:
            bsr     draw_car

            bra     mainloop

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
; Wait for blitter
;──────────────────────────────────────────────────────────────
wait_blit:
            btst    #6,DMACONR(a5)
            bne.s   wait_blit
            rts

;──────────────────────────────────────────────────────────────
; Clear entire screen (both planes)
;──────────────────────────────────────────────────────────────
clear_screen:
            bsr.s   wait_blit

            move.l  #screen_plane1,BLTDPTH(a5)
            move.w  #0,BLTDMOD(a5)
            move.w  #$0100,BLTCON0(a5)  ; D only, clear
            move.w  #0,BLTCON1(a5)
            move.w  #(SCREEN_H<<6)|SCREEN_W/2,BLTSIZE(a5)

            bsr.s   wait_blit

            move.l  #screen_plane2,BLTDPTH(a5)
            move.w  #(SCREEN_H<<6)|SCREEN_W/2,BLTSIZE(a5)

            rts

;──────────────────────────────────────────────────────────────
; Clear car at old position
;──────────────────────────────────────────────────────────────
clear_car:
            bsr.s   wait_blit

            ; Calculate old position
            move.w  car_x,d0
            move.w  #CAR_Y,d1

            ; Calculate destination address
            lea     screen_plane1,a0
            mulu    #SCREEN_W,d1
            add.l   d1,a0
            move.w  d0,d2
            lsr.w   #3,d2
            ext.l   d2
            add.l   d2,a0

            ; Clear blit (D only, minterm 0)
            move.l  a0,BLTDPTH(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)
            move.w  #$0100,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)

            rts

;──────────────────────────────────────────────────────────────
; Draw car at current position
;──────────────────────────────────────────────────────────────
draw_car:
            bsr.s   wait_blit

            ; Calculate position
            move.w  car_x,d0
            move.w  #CAR_Y,d1

            ; Calculate destination address
            lea     screen_plane1,a0
            mulu    #SCREEN_W,d1
            add.l   d1,a0
            move.w  d0,d2
            lsr.w   #3,d2
            ext.l   d2
            add.l   d2,a0

            ; A->D copy blit
            move.l  #car_gfx,BLTAPTH(a5)
            move.l  a0,BLTDPTH(a5)

            move.w  #$09f0,BLTCON0(a5)  ; Use A, D=A
            move.w  #0,BLTCON1(a5)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.w  #0,BLTAMOD(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)

            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)

            rts

;──────────────────────────────────────────────────────────────
; Read joystick with edge detection
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
; Update sprite control words
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
; Variables
;──────────────────────────────────────────────────────────────
frog_x:     dc.w    160
frog_y:     dc.w    180
joy_prev:   dc.w    0
car_x:      dc.w    0

;──────────────────────────────────────────────────────────────
; Chip RAM Data
;──────────────────────────────────────────────────────────────
            section chipdata,data_c

copperlist:
            dc.w    COLOR00,$0000       ; Black border

            ; --- Bitplane control ---
            dc.w    $0100,$2200         ; BPLCON0: 2 planes, colour on
            dc.w    $0102,$0000         ; BPLCON1: no scroll
            dc.w    $0104,$0000         ; BPLCON2: default priority
            dc.w    $0108,$0000         ; BPL1MOD
            dc.w    $010a,$0000         ; BPL2MOD

            ; --- Bitplane pointers (filled by CPU) ---
bplpt:
            dc.w    $00e0,$0000         ; BPL1PTH
            dc.w    $00e2,$0000         ; BPL1PTL
            dc.w    $00e4,$0000         ; BPL2PTH
            dc.w    $00e6,$0000         ; BPL2PTL

            ; --- Playfield colours ---
            dc.w    $0180,$0000         ; Colour 0: Transparent (shows copper bg)
            dc.w    $0182,$0f00         ; Colour 1: Red (car)
            dc.w    $0184,$0ff0         ; Colour 2: Yellow
            dc.w    $0186,$0fff         ; Colour 3: White

            ; --- Sprite 0 palette ---
            dc.w    $01a2,$00f0         ; Colour 17: Green (frog)
            dc.w    $01a4,$0ff0         ; Colour 18: Yellow
            dc.w    $01a6,$0000         ; Colour 19: Black

            ; --- Sprite 0 pointer ---
sprpt:
            dc.w    $0120,$0000
            dc.w    $0122,$0000

            ; === ZONE COLOURS (via copper) ===

            ; HOME ZONE
            dc.w    $2c07,$fffe
            dc.w    COLOR00,$0080

            ; WATER ZONE
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

            ; MEDIAN
            dc.w    $6c07,$fffe
            dc.w    COLOR00,$0080

            ; ROAD ZONE
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

            ; START ZONE
            dc.w    $b407,$fffe
            dc.w    COLOR00,$0080

            dc.w    $c007,$fffe
            dc.w    COLOR00,$0070

            ; BOTTOM BORDER
            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000

            dc.w    $ffff,$fffe

;──────────────────────────────────────────────────────────────
; Car Graphics (16x8 solid block)
;──────────────────────────────────────────────────────────────
            even
car_gfx:
            dc.w    $ffff
            dc.w    $ffff
            dc.w    $ffff
            dc.w    $ffff
            dc.w    $ffff
            dc.w    $ffff
            dc.w    $ffff
            dc.w    $ffff

;──────────────────────────────────────────────────────────────
; Sprite Data
;──────────────────────────────────────────────────────────────
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

;──────────────────────────────────────────────────────────────
; Screen Memory (must be in chip RAM)
;──────────────────────────────────────────────────────────────
            even
screen_plane1:
            ds.b    PLANE_SIZE

            even
screen_plane2:
            ds.b    PLANE_SIZE
