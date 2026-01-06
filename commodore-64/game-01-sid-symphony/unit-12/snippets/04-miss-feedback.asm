; Trigger miss flash effect
            lda #MISS_FLASH_TIME
            sta miss_flash_timer

            ; Reset combo and multiplier
            lda #0
            sta combo_count
            lda #1
            sta multiplier
