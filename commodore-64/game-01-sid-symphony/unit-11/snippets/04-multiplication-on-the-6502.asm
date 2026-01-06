cg_add_score:
            ; A contains base points, multiply by multiplier (1-4)
            sta cg_base_points      ; Save base points
            lda multiplier
            cmp #1
            beq cg_mult_done        ; 1x = no change
            cmp #2
            beq cg_mult_2x
            cmp #3
            beq cg_mult_3x

            ; 4x = shift left twice
            lda cg_base_points
            asl                     ; x2
            asl                     ; x4
            jmp cg_mult_done

cg_mult_2x:
            lda cg_base_points
            asl                     ; x2
            jmp cg_mult_done

cg_mult_3x:
            lda cg_base_points
            asl                     ; x2
            clc
            adc cg_base_points      ; x2 + x1 = x3

cg_mult_done:
            ; A now contains multiplied points
            clc
            adc score_lo
            sta score_lo
            bcc cg_done
            inc score_hi
