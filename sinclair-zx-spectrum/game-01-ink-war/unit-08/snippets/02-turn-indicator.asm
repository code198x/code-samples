; Draw turn indicator - coloured bar showing whose turn

INDICATOR_ROW equ 2         ; Above the board
INDICATOR_COL equ 12        ; Aligned with board

draw_turn_indicator:
        ; Calculate address
        ld hl, ATTR_START + (INDICATOR_ROW * 32) + INDICATOR_COL

        ; Get current player's colour
        ld a, (current_player)
        cp PLAYER1
        jr nz, ind_p2
        ld a, P1_ATTR       ; Red
        jr draw_ind
ind_p2:
        ld a, P2_ATTR       ; Blue
draw_ind:
        ld b, 8             ; 8 cells wide
ind_loop:
        ld (hl), a
        inc hl
        djnz ind_loop
        ret

; Red bar = Player 1's turn
; Blue bar = Player 2's turn
