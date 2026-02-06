        ; --- Read joystick and move ship ---

        ; UP (bit 0)
        lda $dc00           ; Read joystick port 2
        and #%00000001      ; Isolate bit 0
        bne not_up          ; Bit is 1 = NOT pressed (active low)
        dec $d001           ; Move ship up (decrease Y)
        dec $d001           ; 2 pixels per frame
not_up:

        ; DOWN (bit 1)
        lda $dc00
        and #%00000010
        bne not_down
        inc $d001           ; Move ship down (increase Y)
        inc $d001
not_down:

        ; LEFT (bit 2)
        lda $dc00
        and #%00000100
        bne not_left
        dec $d000           ; Move ship left (decrease X)
        dec $d000
not_left:

        ; RIGHT (bit 3)
        lda $dc00
        and #%00001000
        bne not_right
        inc $d000           ; Move ship right (increase X)
        inc $d000
not_right:
