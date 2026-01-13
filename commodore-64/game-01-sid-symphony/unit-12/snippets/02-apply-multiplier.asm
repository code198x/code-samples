; ----------------------------------------------------------------------------
; Apply Multiplier - Multiply base score by current combo multiplier
; ----------------------------------------------------------------------------

; Input: A = base score (e.g., 100 for perfect, 50 for good)
; Output: score_add_lo/hi = base score * multiplier

apply_multiplier:
            sta base_score
            jsr get_multiplier
            sta current_mult

            ; Start with base score
            lda base_score
            sta score_add_lo
            lda #0
            sta score_add_hi

            ; If multiplier is 1, we're done
            lda current_mult
            cmp #1
            beq mult_done_apply

            ; Multiply by adding base_score (mult-1) more times
            dec current_mult
mult_add_loop:
            lda score_add_lo
            clc
            adc base_score
            sta score_add_lo
            lda score_add_hi
            adc #0
            sta score_add_hi
            dec current_mult
            bne mult_add_loop

mult_done_apply:
            rts

base_score:    !byte 0
current_mult:  !byte 0
score_add_lo:  !byte 0
score_add_hi:  !byte 0

; ----------------------------------------------------------------------------
; Usage in award_points
; ----------------------------------------------------------------------------

award_points:
            ; Increment combo first (combo builds BEFORE score)
            jsr increment_combo

            lda hit_quality
            cmp #2
            beq award_perfect

            ; Good hit: 50 * multiplier
            lda #GOOD_SCORE             ; 50
            jsr apply_multiplier        ; Returns in score_add_lo/hi
            jsr add_score
            ; ...

award_perfect:
            ; Perfect hit: 100 * multiplier
            lda #PERFECT_SCORE          ; 100
            jsr apply_multiplier        ; Returns in score_add_lo/hi
            jsr add_score
            ; ...
