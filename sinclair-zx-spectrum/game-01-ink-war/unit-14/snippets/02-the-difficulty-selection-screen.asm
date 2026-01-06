show_difficulty:
        call clear_screen

        ; Set cyan border
        ld a, 5
        ld (border_colour), a
        out (254), a

        ; Set white on black
        ld a, %00000111
        ld (23693), a

        ; Open channel 2
        ld a, 2
        call OPEN_CHANNEL

        ; Print "SELECT DIFFICULTY" at row 6
        ld a, 22
        rst $10
        ld a, 6
        rst $10
        ld a, 7
        rst $10
        ld hl, msg_difficulty
        call print_string

        ; Print Easy at row 10
        ld a, 22
        rst $10
        ld a, 10
        rst $10
        ld a, 11
        rst $10
        ld hl, msg_easy
        call print_string

        ; Print Normal at row 12
        ld a, 22
        rst $10
        ld a, 12
        rst $10
        ld a, 11
        rst $10
        ld hl, msg_normal
        call print_string

        ; Print Hard at row 14
        ld a, 22
        rst $10
        ld a, 14
        rst $10
        ld a, 11
        rst $10
        ld hl, msg_hard
        call print_string

        ret
