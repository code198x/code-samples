; ----------------------------------------------------------------------------
; Read Keyboard
; ----------------------------------------------------------------------------
; Checks Q/A/O/P keys and sets direction flags

read_keyboard:
            xor     a
            ld      (key_pressed), a ; Clear previous

            ; Check Q (up) - port $FBFE, bit 0
            ld      a, ROW_QAOP
            in      a, (KEY_PORT)
            bit     0, a            ; Q is bit 0
            jr      nz, .not_q
            ld      a, 1            ; Up
            ld      (key_pressed), a
            ret
.not_q:
            ; Check A (down) - port $FDFE, bit 0
            ld      a, ROW_ASDF
            in      a, (KEY_PORT)
            bit     0, a            ; A is bit 0
            jr      nz, .not_a
            ld      a, 2            ; Down
            ld      (key_pressed), a
            ret
.not_a:
            ; Check O (left) - port $DFFE, bit 1
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     1, a            ; O is bit 1
            jr      nz, .not_o
            ld      a, 3            ; Left
            ld      (key_pressed), a
            ret
.not_o:
            ; Check P (right) - port $DFFE, bit 0
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     0, a            ; P is bit 0
            jr      nz, .not_p
            ld      a, 4            ; Right
            ld      (key_pressed), a
.not_p:
            ret
