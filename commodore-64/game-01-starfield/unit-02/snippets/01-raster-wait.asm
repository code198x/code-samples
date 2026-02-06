game_loop:
        ; Wait for the raster beam to reach line 255
        ; This syncs our code to the display (~50Hz PAL)
-       lda $d012
        cmp #$ff
        bne -

        ; ... game logic here ...

        jmp game_loop
