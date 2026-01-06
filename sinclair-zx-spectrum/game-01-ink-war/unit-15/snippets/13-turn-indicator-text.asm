show_turn_indicator:
        ; Position at top-right
        ld a, 22
        rst $10
        ld a, 0
        rst $10
        ld a, 24
        rst $10

        ld a, (game_mode)
        cp 1
        jr nz, .two_player

        ; 1P mode
        ld a, (current_player)
        cp 1
        jr nz, .cpu_turn
        ld hl, msg_p1_turn
        jr .print
.cpu_turn:
        ld hl, msg_cpu_turn
        jr .print

.two_player:
        ; 2P mode
        ld a, (current_player)
        cp 1
        jr nz, .p2_turn
        ld hl, msg_p1_turn
        jr .print
.p2_turn:
        ld hl, msg_p2_turn

.print:
        call print_string
        ret
