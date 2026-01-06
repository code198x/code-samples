inc multiplier
            ; Trigger border flash on multiplier increase
            lda #BORDER_FLASH_TIME
            sta border_flash_timer
            ; Update speed for new multiplier
            jsr update_speed
