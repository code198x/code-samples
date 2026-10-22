; Qualified SCREEN 0, 40 columns, default name table at VRAM $0000.
; BIOS LDIRVM copies eight bytes; all main registers/flags may change.
; Caller owns these eight cells and label's two mutable digits, not the cursor.
show_turn:
    ld a,(turn_count)
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld (label+6),a
    ld a,(turn_count)
    and 15
    call hex_digit
    ld (label+7),a
    ld hl,label
    ld de,0
    ld bc,8
    call $005C
    ret
hex_digit:
    cp 10
    jr c,digit
    add a,7
digit:
    add a,48
    ret
label:
    db "TURN $00"
