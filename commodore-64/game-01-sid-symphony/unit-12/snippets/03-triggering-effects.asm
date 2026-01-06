update_combo:
            inc combo_count
            lda combo_count
            cmp #COMBO_THRESHOLD
            bcc uc_done

            lda multiplier
            cmp #MAX_MULTIPLIER
            bcs uc_reset
            inc multiplier

            ; Trigger border flash on multiplier increase
            lda #BORDER_FLASH_TIME
            sta border_flash_timer

uc_reset:
            lda #0
            sta combo_count
uc_done:
            rts
