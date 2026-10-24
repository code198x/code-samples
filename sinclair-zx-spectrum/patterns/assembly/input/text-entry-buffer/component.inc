; SPDX-License-Identifier: MIT
; A Counted Text-entry Buffer. Contiguous private bytes: LENGTH, STATUS, KEY, MODE, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
text_entry_buffer_init:
    xor a
    ld (LENGTH),a
    ld (STATUS),a
    ld (KEY),a
    ld (MODE),a
    ld (BUF0),a
    ld (BUF1),a
    ld (BUF2),a
    ld (BUF3),a
    ld (BUF4),a
    ld (BUF5),a
    ld (BUF6),a
    ld (BUF7),a
    ret
text_entry_buffer_step:
    xor a
    ld (STATUS),a
    ld a,(MODE)
    cp 2
    jr z,text_clear
    ld a,(LENGTH)
    cp TEXT_CAP+1
    jr nc,text_bad
    ld a,(MODE)
    or a
    jr z,text_append
    cp 1
    jr nz,text_bad
    ld a,(LENGTH)
    or a
    ret z
    dec a
    ld (LENGTH),a
    ld e,a
    ld d,0
    ld hl,BUF0
    add hl,de
    ld (hl),0
    jr text_changed
text_append:
    ld a,(KEY)
    cp 32
    jr c,text_bad_key
    cp 127
    jr nc,text_bad_key
    ld b,a
    ld a,(LENGTH)
    cp TEXT_CAP
    ret nc
    ld e,a
    ld d,0
    ld hl,BUF0
    add hl,de
    ld (hl),b
    ld a,(LENGTH)
    inc a
    ld (LENGTH),a
text_changed:
    ld a,1
    ld (STATUS),a
    ret
text_bad_key:
    ld a,2
    ld (STATUS),a
    ret
text_bad:
    ld a,3
    ld (STATUS),a
    ret
text_clear:
    ld hl,BUF0
    ld b,8
    xor a
text_clear_loop:
    ld (hl),a
    inc hl
    djnz text_clear_loop
    ld (LENGTH),a
    jr text_changed
component_end:
