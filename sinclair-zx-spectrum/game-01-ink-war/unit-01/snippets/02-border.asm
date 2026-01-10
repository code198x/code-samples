; Set the border colour
; Port $FE (254) controls the border
; Bits 0-2 set the colour (0-7)

        ld a, BLUE          ; Load colour into A register
        out (BORDER_PORT), a ; Send to port $FE
