show_results:
        ; ... initial setup ...

        ; Print player labels based on mode
        ld a, 22
        rst $10
        ld a, 10
        rst $10
        ld a, 10
        rst $10

        ld a, (game_mode)
        cp 1
        jr nz, .two_player_labels

        ; 1P mode labels
        ld hl, msg_player
        call print_string
        ld a, (p1_count)
        call print_number

        ld a, 22
        rst $10
        ld a, 12
        rst $10
        ld a, 10
        rst $10
        ld hl, msg_cpu
        call print_string
        ld a, (p2_count)
        call print_number
        jr .print_winner_section

.two_player_labels:
        ; 2P mode labels
        ld hl, msg_p1
        call print_string
        ld a, (p1_count)
        call print_number

        ld a, 22
        rst $10
        ld a, 12
        rst $10
        ld a, 10
        rst $10
        ld hl, msg_p2
        call print_string
        ld a, (p2_count)
        call print_number

.print_winner_section:
        ; ... rest of winner display ...
