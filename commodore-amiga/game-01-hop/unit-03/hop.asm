;──────────────────────────────────────────────────────────────
; HOP - A Frogger-style game for the Commodore Amiga
; Unit 3: The Hop
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000

; Custom chip register offsets
DMACONR     equ $002
VPOSR       equ $004
JOY1DAT     equ $00c
COP1LC      equ $080
COPJMP1     equ $088
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COLOR00     equ $180

; Movement constants
HOP_SIZE    equ 16
FROG_HEIGHT equ 16
MIN_X       equ 32
MAX_X       equ 288
MIN_Y       equ 44
MAX_Y       equ 196

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
            move.w  #$8320,DMACON(a5)

            ; --- Initialise frog position ---
            move.w  #160,frog_x
            move.w  #180,frog_y
            bsr.s   update_sprite

            ; === Main Loop ===
mainloop:
            bsr.s   wait_vblank
            bsr.s   read_joystick

            ; --- Check Up ---
            btst    #8,d0
            beq.s   .no_up
            move.w  frog_y,d1
            sub.w   #HOP_SIZE,d1
            cmp.w   #MIN_Y,d1
            blt.s   .no_up
            move.w  d1,frog_y
.no_up:
            ; --- Check Down ---
            btst    #0,d0
            beq.s   .no_down
            move.w  frog_y,d1
            add.w   #HOP_SIZE,d1
            cmp.w   #MAX_Y,d1
            bgt.s   .no_down
            move.w  d1,frog_y
.no_down:
            ; --- Check Left ---
            btst    #9,d0
            beq.s   .no_left
            move.w  frog_x,d1
            sub.w   #HOP_SIZE,d1
            cmp.w   #MIN_X,d1
            blt.s   .no_left
            move.w  d1,frog_x
.no_left:
            ; --- Check Right ---
            btst    #1,d0
            beq.s   .no_right
            move.w  frog_x,d1
            add.w   #HOP_SIZE,d1
            cmp.w   #MAX_X,d1
            bgt.s   .no_right
            move.w  d1,frog_x
.no_right:

            bsr.s   update_sprite
            bra.s   mainloop

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
; Read joystick with edge detection
; Returns: D0 = newly pressed directions
;──────────────────────────────────────────────────────────────
read_joystick:
            move.w  JOY1DAT(a5),d0
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d1,d0               ; Decode up/down

            ; Edge detection
            move.w  joy_prev,d1
            not.w   d1
            and.w   d0,d1
            move.w  d0,joy_prev

            move.w  d1,d0
            rts

;──────────────────────────────────────────────────────────────
; Update sprite control words from frog_x/frog_y
;──────────────────────────────────────────────────────────────
update_sprite:
            lea     frog_data,a0
            move.w  frog_y,d0
            move.w  frog_x,d1

            ; Word 1: VSTART | HSTART>>1
            move.w  d0,d2
            lsl.w   #8,d2
            lsr.w   #1,d1
            or.b    d1,d2
            move.w  d2,(a0)

            ; Word 2: VSTOP | 0
            add.w   #FROG_HEIGHT,d0
            lsl.w   #8,d0
            move.w  d0,2(a0)

            rts

;──────────────────────────────────────────────────────────────
; Variables (in code section for PC-relative access)
;──────────────────────────────────────────────────────────────
frog_x:     dc.w    160
frog_y:     dc.w    180
joy_prev:   dc.w    0

;──────────────────────────────────────────────────────────────
; Chip RAM Data
;──────────────────────────────────────────────────────────────
            section chipdata,data_c

copperlist:
            dc.w    COLOR00,$0000

            ; --- Sprite 0 palette ---
            dc.w    $01a2,$00f0
            dc.w    $01a4,$0ff0
            dc.w    $01a6,$0000

            ; --- Sprite 0 pointer ---
sprpt:
            dc.w    $0120,$0000
            dc.w    $0122,$0000

            ; === HOME ZONE ===
            dc.w    $2c07,$fffe
            dc.w    COLOR00,$0080

            ; === WATER ZONE ===
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

            ; === MEDIAN ===
            dc.w    $6c07,$fffe
            dc.w    COLOR00,$0080

            ; === ROAD ZONE ===
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

            ; === START ZONE ===
            dc.w    $b407,$fffe
            dc.w    COLOR00,$0080

            dc.w    $c007,$fffe
            dc.w    COLOR00,$0070

            ; === BOTTOM BORDER ===
            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000

            dc.w    $ffff,$fffe

;──────────────────────────────────────────────────────────────
; Sprite Data
;──────────────────────────────────────────────────────────────
            even
frog_data:
            dc.w    $b460,$c400         ; Control words (updated by code)

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
