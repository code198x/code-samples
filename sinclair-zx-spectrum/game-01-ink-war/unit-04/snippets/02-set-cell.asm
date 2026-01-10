; Set a board cell to a player's colour
; Input: B = row (0-7), C = column (0-7), A = player (0/1/2)

set_cell:
        push af                 ; Save player value

        ; Calculate screen position
        ; Screen row = BOARD_TOP + B
        ; Screen column = BOARD_LEFT + C
        ld a, BOARD_TOP
        add a, b                ; A = screen row

        ; Multiply row by 32 (5 shifts left)
        ld l, a
        ld h, 0
        add hl, hl              ; ×2
        add hl, hl              ; ×4
        add hl, hl              ; ×8
        add hl, hl              ; ×16
        add hl, hl              ; ×32

        ; Add column
        ld a, BOARD_LEFT
        add a, c
        ld e, a
        ld d, 0
        add hl, de

        ; Add base address
        ld de, ATTR_START
        add hl, de              ; HL = attribute address

        ; Get colour and write it
        pop af
        call get_player_colour
        ld (hl), a
        ret
