; Draw empty slot at d1,d2
draw_empty_slot:
            lea     CUSTOM,a5
            movem.l d1-d2,-(sp)

.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            ; Calculate destination
            lea     bitplane,a1
            move.w  d2,d0
            mulu.w  #SCREEN_WIDTH/8,d0
            lsr.w   #3,d1
            add.w   d1,d0
            add.w   d0,a1

            ; Draw outlined rectangle (just the border)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01f00000,BLTCON0(a5)
            move.l  a1,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-4,BLTDMOD(a5)
            move.w  #(2<<6)|2,BLTSIZE(a5)   ; Top border

            movem.l (sp)+,d1-d2
            rts

; Draw filled slot at d1,d2
draw_filled_slot:
            ; Same as empty but filled solid
            lea     CUSTOM,a5
            movem.l d1-d2,-(sp)

.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            lea     bitplane,a1
            move.w  d2,d0
            mulu.w  #SCREEN_WIDTH/8,d0
            lsr.w   #3,d1
            add.w   d1,d0
            add.w   d0,a1

            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01f00000,BLTCON0(a5)
            move.l  a1,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-4,BLTDMOD(a5)
            move.w  #(SLOT_HEIGHT<<6)|2,BLTSIZE(a5)

            movem.l (sp)+,d1-d2
            rts
