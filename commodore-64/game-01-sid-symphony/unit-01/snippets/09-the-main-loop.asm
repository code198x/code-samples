main_loop:
            jsr check_x_key
            cmp #$01
            beq .x_pressed

            ; X not pressed - check if we need to stop note
            lda key_state
            cmp #$01
            bne main_loop
            ; Was playing, now released
            lda #$00
            sta key_state
            jsr stop_note
            jmp main_loop

.x_pressed:
            ; X pressed - check if we need to start note
            lda key_state
            cmp #$01
            beq main_loop       ; Already playing
            ; Start playing
            lda #$01
            sta key_state
            jsr play_note
            jmp main_loop
