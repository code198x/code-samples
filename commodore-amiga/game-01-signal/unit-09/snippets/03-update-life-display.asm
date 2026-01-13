; Update Life Display
; Show/hide sprite icons based on lives count

update_life_display:
            ; Position life icons at top of screen
            ; VSTART = 30, VSTOP = 38 (8 pixels tall)
            ; HSTART varies: 64, 80, 96 (sprite coords)

            ; Life 1 (show if lives >= 1)
            lea     life_icon_1,a0
            move.w  lives,d0
            cmp.w   #1,d0
            blt.s   .hide_life1
            move.w  #$1e20,$0(a0)       ; VSTART=30, HSTART=64
            move.w  #$2600,$2(a0)       ; VSTOP=38
            bra.s   .life2
.hide_life1:
            clr.l   (a0)                ; Hide: zero control words

.life2:
            ; Life 2 (show if lives >= 2)
            lea     life_icon_2,a0
            cmp.w   #2,d0
            blt.s   .hide_life2
            move.w  #$1e28,$0(a0)       ; VSTART=30, HSTART=80
            move.w  #$2600,$2(a0)
            bra.s   .life3
.hide_life2:
            clr.l   (a0)

.life3:
            ; Life 3 (show if lives >= 3)
            lea     life_icon_3,a0
            cmp.w   #3,d0
            blt.s   .hide_life3
            move.w  #$1e30,$0(a0)       ; VSTART=30, HSTART=96
            move.w  #$2600,$2(a0)
            rts
.hide_life3:
            clr.l   (a0)
            rts
