; Determine who won and display the result

determine_winner:
        ; Compare scores
        ld a, (p1_score)
        ld b, a
        ld a, (p2_score)

        ; Compare P1 vs P2
        cp b                ; A (P2) - B (P1)
        jr z, result_draw   ; Equal - draw
        jr c, result_p1     ; P2 < P1 - P1 wins
                            ; Otherwise P2 > P1 - P2 wins

result_p2:
        ld a, WINNER_P2
        ld (winner), a
        ld hl, msg_blu_wins
        ld a, %00000101     ; Cyan ink for message
        jr show_winner

result_p1:
        ld a, WINNER_P1
        ld (winner), a
        ld hl, msg_red_wins
        ld a, %00000010     ; Red ink for message
        jr show_winner

result_draw:
        ld a, WINNER_DRAW
        ld (winner), a
        ld hl, msg_draw
        ld a, %00000111     ; White ink for message

show_winner:
        ; ... set attributes and print message
