lda #$00
            sta streak              ; Reset streak
            lda #FLASH_TIME
            sta miss_flash          ; Red flash
