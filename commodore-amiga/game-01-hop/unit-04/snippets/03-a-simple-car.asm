draw_car:
            bsr.s   wait_blit

            ; Calculate destination
            lea     screen_plane1,a0
            mulu    #40,d1              ; D1 = Y * bytes per line
            add.l   d1,a0               ; Add Y offset
            move.w  d0,d2
            lsr.w   #3,d2               ; D2 = X / 8
            add.w   d2,a0               ; Add X offset

            ; Set up blitter
            move.l  #car_gfx,BLTAPTH(a5)
            move.l  a0,BLTDPTH(a5)

            move.w  #$09f0,BLTCON0(a5)  ; A->D copy
            move.w  #0,BLTCON1(a5)
            move.w  #$ffff,BLTAFWM(a5)  ; No masking
            move.w  #$ffff,BLTALWM(a5)

            move.w  #0,BLTAMOD(a5)      ; Source: no gap
            move.w  #38,BLTDMOD(a5)     ; Dest: 40-2=38 bytes to next line

            ; Start blit: 8 lines, 1 word wide
            move.w  #(8<<6)|1,BLTSIZE(a5)

            rts
