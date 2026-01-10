; Print a null-terminated string
; Input: HL = string pointer, B = row, C = column

print_string:
        ld a, (hl)
        or a                ; Check for null terminator
        ret z               ; Return if end of string

        push hl
        push bc
        call print_char     ; Print current character
        pop bc
        pop hl

        inc hl              ; Next character in string
        inc c               ; Next column on screen
        jr print_string     ; Continue until null

; Example usage:
;   ld hl, msg_red_wins
;   ld b, WINNER_ROW
;   ld c, WINNER_COL
;   call print_string
