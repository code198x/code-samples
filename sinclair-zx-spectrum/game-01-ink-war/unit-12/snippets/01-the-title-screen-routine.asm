;───────────────────────────────────────
; Show title screen
;───────────────────────────────────────
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

        ; Print instructions at row 10
        ld a, 22
        rst $10
        ld a, 10
        rst $10
        ld a, 7
        rst $10
        ld hl, msg_controls
        call print_string

        ; Print move keys at row 12
        ld a, 22
        rst $10
        ld a, 12
        rst $10
        ld a, 7
        rst $10
        ld hl, msg_move
        call print_string

        ; Print claim key at row 14
        ld a, 22
        rst $10
        ld a, 14
        rst $10
        ld a, 7
        rst $10
        ld hl, msg_claim
        call print_string

        ; Print start prompt at row 20
        ld a, 22
        rst $10
        ld a, 20
        rst $10
        ld a, 8
        rst $10
        ld hl, msg_start
        call print_string

        ret
