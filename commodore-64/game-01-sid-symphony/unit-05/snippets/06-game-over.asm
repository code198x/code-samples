main_loop:
            jsr wait_frame
            lda game_running
            beq main_loop           ; Frozen - just wait

            ; ... normal game logic ...
            jmp main_loop
