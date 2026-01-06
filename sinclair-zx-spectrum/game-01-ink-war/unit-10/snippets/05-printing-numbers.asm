;───────────────────────────────────────
; Print a number (0-99)
; Input: A = number to print
;───────────────────────────────────────
print_number:
        ld b, 0                 ; Tens counter

.count_tens:
        cp 10                   ; Less than 10?
        jr c, .print_digits     ; Yes, done counting tens
        sub 10                  ; Subtract 10
        inc b                   ; Count it
        jr .count_tens

.print_digits:
        push af                 ; Save units

        ; Print tens (only if non-zero)
        ld a, b
        or a
        jr z, .skip_tens        ; Don't print leading zero
        add a, '0'              ; Convert to ASCII
        rst $10

.skip_tens:
        pop af                  ; Restore units
        add a, '0'              ; Convert to ASCII
        rst $10
        ret
