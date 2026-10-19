; Pasmo syntax. Supply print_char: A=ASCII, B=row, C=column; preserve BC/DE/HL.
; Inputs must fit the display: two digits C<=30, three digits C<=29.
; Callers own coordinates and display; no memory allocation or ROM calls here.
; print_two_digits A=0.numeric_99, print_three_digits HL=0.numeric_999.
; Both preserve B/DE and return C advanced by their digit count; AF changes.
; print_three_digits also changes HL to the remainder after hundreds.
; print_number A=0.numeric_99 advances C by one or two; preserves B/DE/HL.
; print_score_bcd needs a valid packed-BCD score_bcd byte and C<=30; C advances2.
; =============================================================================
; NUMERIC DISPLAY - ZX SPECTRUM
; Print 0-99 as two decimal digits
; Taught: Game 1 (Ink War), Unit 4
; =============================================================================

; Print two-digit number
; Input: A = number (0-99), B = row, C = column
; Output: Advances C by 2
print_two_digits:
    push    de

    ; Extract tens digit by repeated subtraction
    ld      d, 0                ; D = tens counter
numeric_tens_loop:
    cp      10
    jr      c, numeric_print           ; Less than 10? Done counting
    sub     10
    inc     d
    jr      numeric_tens_loop

numeric_print:
    push    af                  ; Save units digit

    ; Print tens digit
    ld      a, d
    add     a, '0'              ; Convert to ASCII
    call    print_char
    inc     c                   ; Next column

    ; Print units digit
    pop     af
    add     a, '0'
    call    print_char
    inc     c

    pop     de
    ret

; Print three-digit number
; Input: HL = number (0-999), B = row, C = column
print_three_digits:
    push    de

    ; Extract hundreds
    ld      d, 0
numeric_hundreds:
    ld      a, h
    or      a
    jr      nz, numeric_sub_hundred
    ld      a, l
    cp      100
    jr      c, numeric_print_hundreds
numeric_sub_hundred:
    ld      a, l
    sub     100
    ld      l, a
    ld      a, h
    sbc     a, 0
    ld      h, a
    inc     d
    jr      numeric_hundreds

numeric_print_hundreds:
    ld      a, d
    add     a, '0'
    call    print_char
    inc     c

    ; Now L contains 0-99, use two-digit routine
    ld      a, l
    call    print_two_digits

    pop     de
    ret

; Print number without leading zeros
; Input: A = number (0-99), B = row, C = column
print_number:
    push    de

    ld      d, 0
numeric_tens:
    cp      10
    jr      c, numeric_check_tens
    sub     10
    inc     d
    jr      numeric_tens

numeric_check_tens:
    push    af

    ; Only print tens if non-zero
    ld      a, d
    or      a
    jr      z, numeric_skip_tens

    add     a, '0'
    call    print_char
    inc     c

numeric_skip_tens:
    pop     af
    add     a, '0'
    call    print_char
    inc     c

    pop     de
    ret

; Add 10 to a two-digit BCD score
add_ten_bcd:
    ld      a, (score_bcd)
    add     a, $10              ; Add 1 to the tens digit
    daa                         ; Adjust to keep BCD form
    ld      (score_bcd), a
    ret

; To print, just split the byte and add '0' to each nibble
print_score_bcd:
    ld      a, (score_bcd)
    push    af
    rrca
    rrca
    rrca
    rrca                        ; A = high nibble
    and     $0f
    add     a, '0'
    call    print_char
    inc     c
    pop     af
    and     $0f                 ; A = low nibble
    add     a, '0'
    call    print_char
    inc     c
    ret
