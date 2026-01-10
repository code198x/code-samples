; Read a single key from the keyboard
; Example: Check if Q is pressed

        ld a, ROW_Q_T       ; Select the Q-T half-row
        in a, (KEYBOARD_PORT)  ; Read keyboard port
        bit 0, a            ; Test bit 0 (Q key)
        jr nz, q_not_pressed ; If bit is 1, key is NOT pressed
        ; Q is pressed - handle it here
q_not_pressed:

; Keys are ACTIVE LOW!
; Bit = 0 means pressed
; Bit = 1 means not pressed
; This is backwards from what you might expect
