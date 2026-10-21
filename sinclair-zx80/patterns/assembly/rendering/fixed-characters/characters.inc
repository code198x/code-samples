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
; A current, ROM-owned, well-formed display file. Never allocate or extend it.
    ld hl,($400c)
    ld de,(DF_END)
    ld (FC+12),de
    ld a,(hl)
    cp $76
    ret nz
    inc hl
    ld a,(FC+3)
    ld b,a
    or a
    jr z,fc_row_ready
fc_skip_row:
    ld c,33
fc_scan:
    call fc_inside
    ret nc
    ld a,(hl)
    inc hl
    cp $76
    jr z,fc_newline
    dec c
    jr nz,fc_scan
    ret
fc_newline:
    djnz fc_skip_row
fc_row_ready:
    ld a,(FC+2)
    ld b,a
    or a
    jr z,fc_start_ready
fc_skip_column:
    call fc_inside
    ret nc
    ld a,(hl)
    cp $76
    ret z
    inc hl
    djnz fc_skip_column
fc_start_ready:
    ld (FC+10),hl
    ld a,(FC+4)
    ld b,a
    ld de,(FC)
fc_preflight:
    call fc_inside
    ret nc
    ld a,(hl)
    cp $76
    ret z
    ld a,(de)
    and $40
    ret nz
    inc de
    inc hl
    djnz fc_preflight
    ld hl,(FC+10)
    ld de,(FC)
    ld a,(FC+4)
    ld b,a
fc_copy:
    ld a,(de)
    ld (hl),a
    inc de
    inc hl
    djnz fc_copy
    ld a,(FC+4)
    ld (FC+6),a
    ld a,1
    ld (FC+5),a
    ret
; Carry means HL is below the exclusive end. Does not clobber BC/DE/HL.
fc_inside:
    ld a,(FC+13)
    cp h
    jr nz,fc_high
    ld a,(FC+12)
    cp l
fc_high:
    jr z,fc_equal
    ccf
    ret
fc_equal:
    or a
    ret
character_span_end:
