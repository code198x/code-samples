; Shadowkeep — Set the border colour

            org     32768

start:
            ld      a, 1            ; 1 = blue
            out     ($fe), a        ; Write to border port

.loop:      halt                    ; Wait for next frame
            jr      .loop           ; Loop forever

            end     start
