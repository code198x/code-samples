; Print title at top of screen
            ld a, 22            ; AT control code
            rst 16
            ld a, 0             ; row 0
            rst 16
            ld a, 10            ; column 10
            rst 16

            ld hl, title_text
            call print_string

            ; Print instructions at bottom (before drawing board)
            ld a, 22            ; AT control code
            rst 16
            ld a, 21            ; row 21
            rst 16
            ld a, 0             ; column 0
            rst 16

            ld hl, instructions
            call print_string
