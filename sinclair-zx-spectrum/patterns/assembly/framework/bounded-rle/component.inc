; SPDX-License-Identifier: MIT
; Decode Bounded RLE Data. Contiguous private bytes: WRITTEN, ERROR, INPUT_START, INPUT_END, OUTPUT_LIMIT, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
bounded_rle_init:
    xor a
    ld (WRITTEN),a
    ld (ERROR),a
    ld (INPUT_START),a
    ld (INPUT_END),a
    ld (OUTPUT_LIMIT),a
    ld (BUF0),a
    ld (BUF1),a
    ld (BUF2),a
    ld (BUF3),a
    ld (BUF4),a
    ld (BUF5),a
    ld (BUF6),a
    ld (BUF7),a
    ret
bounded_rle_step:
    xor a
    ld (WRITTEN),a
    ld (ERROR),a
    ld a,(INPUT_END)
    cp STREAM_BYTES+1
    jr nc,rle_bounds
    ld b,a
    ld a,(INPUT_START)
    cp b
    jr c,rle_check_output
    jr z,rle_check_output
rle_bounds:
    ld a,1
    jr rle_error
rle_check_output:
    ld a,(OUTPUT_LIMIT)
    cp 9
    jr nc,rle_bounds
    ld a,(INPUT_START)
    ld e,a
    ld d,0
    ld hl,rle_stream
    add hl,de
    ld a,(INPUT_END)
    sub e
    ld b,a
    ld de,BUF0
rle_pair:
    ld a,b
    or a
    ret z
    cp 2
    jr c,rle_truncated
    ld a,(hl)
    inc hl
    dec b
    or a
    jr z,rle_zero
    ld c,a
    ld a,(hl)
    inc hl
    dec b
rle_copy:
    push af
    push bc
    ld a,(OUTPUT_LIMIT)
    ld b,a
    ld a,(WRITTEN)
    cp b
    pop bc
    jr nc,rle_full
    pop af
    ld (de),a
    inc de
    push af
    ld a,(WRITTEN)
    inc a
    ld (WRITTEN),a
    pop af
    dec c
    jr nz,rle_copy
    jr rle_pair
rle_full:
    pop af
    ld a,4
    jr rle_error
rle_truncated:
    ld a,2
    jr rle_error
rle_zero:
    ld a,3
rle_error:
    ld (ERROR),a
    ret
component_end:
