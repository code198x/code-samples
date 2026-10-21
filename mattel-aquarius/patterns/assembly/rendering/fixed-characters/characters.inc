; Define FC (24 private bytes). Source and request must not alias output.
; +0 source word, +2 x, +3 y, +4 count, +5 accepted, +6 writes,
; +7 Aquarius colour (ignored on Sinclair). Inputs +0..4 and +7 survive.
; AF/BC/DE/HL clobbered; IX/IY and interrupt state unchanged.
character_span:
    xor a
    ld (FC+5),a
    ld (FC+6),a
    ld a,(FC+2)
    cp COLS
    ret nc
    ld b,a
    ld a,COLS
    sub b
    ld b,a
    ld a,(FC+4)
    or a
    ret z
    cp b
    jr c,fc_count_fit
    ret nz
fc_count_fit:
    ld a,(FC+3)
    cp ROWS
    ret nc
; Cell zero repeats into the surround: preserve it as a caller-owned border.
    ld a,(FC+2)
    ld b,a
    ld a,(FC+3)
    or b
    ret z
    ld hl,$3000
    ld a,(FC+3)
    ld b,a
    or a
    jr z,fc_row_ready
    ld de,40
fc_next_row:
    add hl,de
    djnz fc_next_row
fc_row_ready:
    ld a,(FC+2)
    ld e,a
    ld d,0
    add hl,de
    ld de,(FC)
    ld a,(FC+4)
    ld b,a
fc_copy:
    ld a,(de)
    ld (hl),a
    inc h
    inc h
    inc h
    inc h
    ld a,(FC+7)
    ld (hl),a
    dec h
    dec h
    dec h
    dec h
    inc de
    inc hl
    djnz fc_copy
    ld a,(FC+4)
    ld (FC+6),a
    ld a,1
    ld (FC+5),a
    ret
character_span_end:
