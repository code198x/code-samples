; Draw a single digit at screen position
; d0 = digit (0-9)
; d1 = X position (must be byte-aligned)
; d2 = Y position
draw_digit:
            lea     CUSTOM,a5

            ; Wait for blitter
.wait:
            btst    #14,DMACONR(a5)
            bne.s   .wait

            ; Calculate font source address
            lea     font_digits,a0
            lsl.w   #3,d0               ; d0 * 8
            add.w   d0,a0               ; a0 = font data for this digit

            ; Calculate screen destination
            lea     bitplane,a1
            move.w  d2,d3
            mulu.w  #SCREEN_WIDTH/8,d3  ; Y * bytes per row
            lsr.w   #3,d1               ; X / 8 for byte offset
            add.w   d1,d3
            add.w   d3,a1               ; a1 = screen destination

            ; Set up blitter
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.l  #$09f00000,BLTCON0(a5)  ; A->D, no shifts
            move.w  #0,BLTAMOD(a5)
            move.w  #(SCREEN_WIDTH/8)-1,BLTDMOD(a5)
            move.l  a0,BLTAPTH(a5)
            move.l  a1,BLTDPTH(a5)
            move.w  #(8<<6)|1,BLTSIZE(a5)   ; 8 rows, 1 word

            rts
