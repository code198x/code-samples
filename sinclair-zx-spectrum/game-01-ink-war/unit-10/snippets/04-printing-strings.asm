;───────────────────────────────────────
; Print null-terminated string
; Input: HL = address of string
;───────────────────────────────────────
print_string:
        ld a, (hl)
        or a
        ret z                   ; Zero byte = end of string
        rst $10                 ; Print character
        inc hl
        jr print_string
