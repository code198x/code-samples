game_loop:
        ; Wait for the raster beam to reach line 255
-       lda $d012
        cmp #$ff
        bne -

        ; --- Check game over ---
        lda game_over
        beq game_active
        jmp game_loop       ; Game frozen — just keep waiting

game_active:
        ; ... input, movement, collision code continues here
