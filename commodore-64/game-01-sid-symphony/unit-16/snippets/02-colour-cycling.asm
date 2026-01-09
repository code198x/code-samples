; Title colour cycling animation
;
; Uses a frame counter to cycle through a colour table.
; The title text pulses between cyan, white, and grey.

title_anim_frame: !byte 0

; Colour sequence (8 steps, loops)
title_colours:
                !byte COL_CYAN, COL_CYAN, COL_WHITE, COL_WHITE
                !byte COL_CYAN, COL_CYAN, COL_GREY, COL_GREY

animate_title:
                ; Increment frame counter
                inc title_anim_frame
                lda title_anim_frame
                lsr
                lsr                     ; /4 = slow down animation
                and #7                  ; 8 colour steps, wrap around

                ; Look up colour
                tax
                lda title_colours,x

                ; Apply to all title characters
                ldx #0
-               cpx #12                 ; Length of "SID SYMPHONY"
                beq +
                sta COLOUR + 8*40 + 14,x
                inx
                bne -
+               rts
