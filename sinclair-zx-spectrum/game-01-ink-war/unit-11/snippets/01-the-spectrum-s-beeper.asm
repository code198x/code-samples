; Simplest possible beep
        ld a, %00010000         ; Bit 4 on
        out ($FE), a
        ; wait...
        xor a                   ; Bit 4 off
        out ($FE), a
