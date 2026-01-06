update_combo:
            inc combo_count
            lda combo_count
            cmp #COMBO_THRESHOLD
            bcc uc_done             ; Haven't reached threshold yet

            ; Reached threshold - increase multiplier if not at max
            lda multiplier
            cmp #MAX_MULTIPLIER
            bcs uc_reset            ; Already at max
            inc multiplier

uc_reset:
            lda #0
            sta combo_count         ; Reset combo counter

uc_done:
            rts
