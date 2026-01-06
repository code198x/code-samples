draw_text:
; Draw null-terminated string
; d0 = X position
; d1 = Y position
; a0 = pointer to string
            movem.l d0-d4/a0-a2,-(sp)
            move.w  d0,d3           ; Save starting X
            move.w  d1,d4           ; Save Y

.next_char:
            move.b  (a0)+,d0
            beq.s   .done           ; Null terminator

            cmpi.b  #' ',d0
            beq.s   .space

            ; Convert ASCII to font index
            ; A-Z = 65-90, we want 0-25
            cmpi.b  #'A',d0
            blt.s   .try_digit
            cmpi.b  #'Z',d0
            bgt.s   .try_digit

            ; It's a letter
            subi.b  #'A',d0
            ext.w   d0
            lea     font_alpha,a1
            bra.s   .draw_char

.try_digit:
            ; 0-9 = 48-57, we want 0-9
            cmpi.b  #'0',d0
            blt.s   .space
            cmpi.b  #'9',d0
            bgt.s   .space

            subi.b  #'0',d0
            ext.w   d0
            lea     font_digits,a1

.draw_char:
            ; Calculate font data address (8 bytes per char)
            lsl.w   #3,d0
            lea     (a1,d0.w),a1

            ; Draw at current position
            move.w  d3,d0
            move.w  d4,d1
            bsr     draw_char_8x8

.space:
            addq.w  #8,d3           ; Advance X
            bra.s   .next_char

.done:
            movem.l (sp)+,d0-d4/a0-a2
            rts
