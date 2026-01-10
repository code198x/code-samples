; Draw scores on screen
; Calls count_cells first, then prints labels and numbers

; Score display positions
SCORE_ROW   equ 4           ; Row for score display
P1_LABEL_COL equ 2          ; "P1:" label
P1_SCORE_COL equ 5          ; Score value
P2_LABEL_COL equ 26         ; "P2:" label
P2_SCORE_COL equ 29         ; Score value

draw_scores:
        ; Count cells first
        call count_cells

        ; Set up attributes for score area
        call setup_score_area

        ; Print "P1:" label
        ld b, SCORE_ROW
        ld c, P1_LABEL_COL
        ld a, 'P'
        call print_char
        ld b, SCORE_ROW
        ld c, P1_LABEL_COL + 1
        ld a, '1'
        call print_char
        ld b, SCORE_ROW
        ld c, P1_LABEL_COL + 2
        ld a, ':'
        call print_char

        ; Print P1 score (two digits)
        ld a, (p1_score)
        ld b, SCORE_ROW
        ld c, P1_SCORE_COL
        call print_two_digit

        ; Print "P2:" label
        ld b, SCORE_ROW
        ld c, P2_LABEL_COL
        ld a, 'P'
        call print_char
        ld b, SCORE_ROW
        ld c, P2_LABEL_COL + 1
        ld a, '2'
        call print_char
        ld b, SCORE_ROW
        ld c, P2_LABEL_COL + 2
        ld a, ':'
        call print_char

        ; Print P2 score (two digits)
        ld a, (p2_score)
        ld b, SCORE_ROW
        ld c, P2_SCORE_COL
        call print_two_digit

        ret

; Set attributes for score area
setup_score_area:
        ; P1 score area - red on black
        ld hl, ATTR_START + (SCORE_ROW * ATTR_WIDTH) + P1_LABEL_COL
        ld a, %00000010     ; Black paper, red ink
        ld b, 5             ; "P1:XX" = 5 chars
p1_attr_loop:
        ld (hl), a
        inc hl
        djnz p1_attr_loop

        ; P2 score area - cyan on black
        ld hl, ATTR_START + (SCORE_ROW * ATTR_WIDTH) + P2_LABEL_COL
        ld a, %00000101     ; Black paper, cyan ink
        ld b, 5             ; "P2:XX" = 5 chars
p2_attr_loop:
        ld (hl), a
        inc hl
        djnz p2_attr_loop

        ret
