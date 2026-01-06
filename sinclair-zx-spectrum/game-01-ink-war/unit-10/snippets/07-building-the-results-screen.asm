;───────────────────────────────────────
; Show results screen
;───────────────────────────────────────
show_results:
        ; Clear screen first
        call clear_screen

        ; Set white on black for text
        ld a, %00000111         ; White ink, black paper
        ld (23693), a           ; ATTR_P system variable

        ; Open channel 2
        ld a, 2
        call $1601

        ; Print "GAME OVER" at row 6
        ld a, 22
        rst $10
        ld a, 6
        rst $10
        ld a, 11                ; Centre-ish
        rst $10
        ld hl, msg_gameover
        call print_string

        ; Print "PLAYER: " and score at row 10
        ld a, 22
        rst $10
        ld a, 10
        rst $10
        ld a, 10
        rst $10
        ld hl, msg_player
        call print_string
        ld a, (p1_count)
        call print_number

        ; Print "CPU: " and score at row 12
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

        ; Print winner message at row 16
        ld a, 22
        rst $10
        ld a, 16
        rst $10
        ld a, 9
        rst $10

        ld a, (winner)
        or a
        jr z, .draw
        cp 1
        jr z, .p1_wins

        ; P2/CPU wins
        ld hl, msg_cpu_wins
        jr .print_winner

.p1_wins:
        ld hl, msg_player_wins
        jr .print_winner

.draw:
        ld hl, msg_draw

.print_winner:
        call print_string

        ; Print "PRESS SPACE" at row 20
        ld a, 22
        rst $10
        ld a, 20
        rst $10
        ld a, 9
        rst $10
        ld hl, msg_space
        call print_string

        ret
