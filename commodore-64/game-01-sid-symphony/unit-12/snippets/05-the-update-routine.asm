update_visual_effects:
            ; Border flash (cyan when multiplier increases)
            lda border_flash_timer
            beq uve_no_border
            dec border_flash_timer
            lda #COL_CYAN           ; Bright cyan border flash
            sta BORDER
            rts

uve_no_border:
            ; Miss flash overrides normal
            lda miss_flash_timer
            beq uve_normal_border
            dec miss_flash_timer
            lda #COL_RED            ; Red border on miss
            sta BORDER
            rts

uve_normal_border:
            lda #COL_BLACK          ; Black border normally
            sta BORDER
            rts
