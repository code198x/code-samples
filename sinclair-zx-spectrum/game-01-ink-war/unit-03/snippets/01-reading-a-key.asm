; Check if Q is pressed
; Returns: Z flag set if pressed, NZ if not
check_key_q:
        ld bc, $fbfe            ; B = $FB (Q row), C = $FE (port)
        in a, (c)               ; Read the half-row
        bit 0, a                ; Test bit 0 (Q)
        ret                     ; Z if pressed (bit was 0)
