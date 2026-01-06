; Clear the score number area
clear_score_area:
            lea     CUSTOM,a5

.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            lea     bitplane,a0
            add.w   #(SCORE_Y*(SCREEN_WIDTH/8))+(SCORE_X/8),a0

            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$01000000,BLTCON0(a5)  ; D=0 (clear)
            move.l  a0,BLTDPTH(a5)
            move.w  #(SCREEN_WIDTH/8)-6,BLTDMOD(a5)
            move.w  #(8<<6)|3,BLTSIZE(a5)   ; 8 rows, 3 words (48 pixels)

            rts
