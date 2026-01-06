;──────────────────────────────────────────────────────────────
; Print null-terminated string at HL
;──────────────────────────────────────────────────────────────
print_string:
            ld a, (hl)
            or a
            ret z               ; Zero byte = end of string
            rst 16              ; Print character
            inc hl
            jr print_string
