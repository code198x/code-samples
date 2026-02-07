            ; Check Q (up)
            ld      a, $fb          ; Row: Q, W, E, R, T
            in      a, ($fe)        ; Read keyboard row
            bit     0, a            ; Q = bit 0
            jr      z, .up          ; 0 = pressed

            ; Check A (down)
            ld      a, $fd          ; Row: A, S, D, F, G
            in      a, ($fe)
            bit     0, a            ; A = bit 0
            jr      z, .down

            ; Check O (left)
            ld      a, $df          ; Row: P, O, I, U, Y
            in      a, ($fe)
            bit     1, a            ; O = bit 1
            jr      z, .left

            ; Check P (right)
            ld      a, $df          ; Row: P, O, I, U, Y
            in      a, ($fe)
            bit     0, a            ; P = bit 0
            jr      z, .right
