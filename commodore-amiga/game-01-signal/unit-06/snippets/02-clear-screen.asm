; Clear Screen with Blitter
; D channel only, minterm 0 = all zeros

clear_screen:
            bsr     wait_blit           ; Must wait before setting up

            ; Destination pointer
            move.l  #screen_plane,BLTDPTH(a5)

            ; Modulo: 0 = continuous (no gaps between rows)
            move.w  #0,BLTDMOD(a5)

            ; BLTCON0: D channel only, minterm 0 (clear)
            ; $0100 = use D, minterms all 0
            move.w  #$0100,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)

            ; Size: trigger the blit!
            ; Format: [height << 6] | [width_in_words]
            ; 256 lines × 20 words = full PAL screen
            move.w  #(256<<6)|20,BLTSIZE(a5)

            rts
