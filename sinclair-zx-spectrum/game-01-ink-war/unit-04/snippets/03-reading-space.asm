; Check if SPACE is pressed
; Returns: Z if pressed, NZ if not
check_space:
        ld bc, $7ffe
        in a, (c)
        bit 0, a
        ret
