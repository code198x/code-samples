; Shadowkeep — Keyboard: Read the Space bar

            org     32768

start:
            ld      a, 0
            out     ($fe), a        ; Black border

.loop:      halt                    ; Wait for next frame

            ld      a, $7f          ; Select row: Space, Sym, M, N, B
            in      a, ($fe)        ; Read keyboard row into A
            bit     0, a            ; Test bit 0 (Space key)
            jr      z, .pressed     ; 0 = pressed (active low)

            ; Not pressed — black border
            ld      a, 0
            out     ($fe), a
            jr      .loop

.pressed:   ; Space held — red border
            ld      a, 2
            out     ($fe), a
            jr      .loop

            end     start
