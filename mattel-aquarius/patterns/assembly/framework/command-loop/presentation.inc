; Normal Aquarius text screen: first usable cell is $3029.
; Writes eight cells, no cursor or colour changes. AF/BC/DE/HL changed.
show_turn:
    ld hl,label
    ld de,$3029
    ld bc,6
    ldir
    ld a,(turn_count)
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld ($302F),a
    ld a,(turn_count)
    and 15
    call hex_digit
    ld ($3030),a
    ret
hex_digit:
    cp 10
    jr c,digit
    add a,7
digit:
    add a,48
    ret
label:
    db "TURN $"
