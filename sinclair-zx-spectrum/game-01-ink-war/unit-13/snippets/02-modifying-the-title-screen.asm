show_title:
        call clear_screen

        ; Set cyan border for title
        ld a, 5
        ld (border_colour), a
        out (254), a

        ; Set white on black
        ld a, %00000111
        ld (23693), a

        ; Open channel 2
        ld a, 2
        call OPEN_CHANNEL

        ; Print title at row 4
        ld a, 22
        rst $10
        ld a, 4
        rst $10
        ld a, 12
        rst $10
        ld hl, msg_title
        call print_string

        ; Print mode selection at row 10
        ld a, 22
        rst $10
        ld a, 10
        rst $10
        ld a, 9
        rst $10
        ld hl, msg_mode1
        call print_string

        ld a, 22
        rst $10
        ld a, 12
        rst $10
        ld a, 9
        rst $10
        ld hl, msg_mode2
        call print_string

        ; Print controls at row 16
        ld a, 22
        rst $10
        ld a, 16
        rst $10
        ld a, 9
        rst $10
        ld hl, msg_move
        call print_string

        ld a, 22
        rst $10
        ld a, 18
        rst $10
        ld a, 9
        rst $10
        ld hl, msg_claim
        call print_string

        ret
