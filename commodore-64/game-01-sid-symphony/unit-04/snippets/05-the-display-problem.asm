convert_score:
            ; Copy score to working area
            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ; 10000s digit
            ldx #$00                ; Digit counter
-           lda work_hi
            cmp #>10000             ; Compare high bytes first
            bcc +                   ; Definitely can't subtract
            bne ++                  ; Definitely can subtract
            lda work_lo
            cmp #<10000             ; High bytes equal, check low
            bcc +                   ; Can't subtract
++          ; Subtract 10000
            lda work_lo
            sec
            sbc #<10000
            sta work_lo
            lda work_hi
            sbc #>10000
            sta work_hi
            inx                     ; Count this subtraction
            jmp -
+           stx score_digits        ; Store 10000s digit
