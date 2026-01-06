; Print winner message
        ld a, (winner)
        or a
        jr z, .draw

        ld a, (game_mode)
        cp 1
        jr nz, .two_player_winner

        ; 1P mode winner
        ld a, (winner)
        cp 1
        jr z, .player_wins_1p
        ld hl, msg_cpu_wins
        jr .print_winner
.player_wins_1p:
        ld hl, msg_player_wins
        jr .print_winner

.two_player_winner:
        ; 2P mode winner
        ld a, (winner)
        cp 1
        jr z, .p1_wins_2p
        ld hl, msg_p2_wins
        jr .print_winner
.p1_wins_2p:
        ld hl, msg_p1_wins
        jr .print_winner

.draw:
        ld hl, msg_draw

.print_winner:
        call print_string
