start:
    di
    xor a
    out ($fe),a
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),a
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),71
    ldir
    call exercise_rng
    ld a,SEED
    if BROKEN
    ld (rng_state),a ; deliberate bypass of the external-zero policy
    else
    call rng_seed
    endif
    ld hl,preview
    ld b,8
preview_next:
    call rng_next
    ld (hl),a
    inc hl
    djnz preview_next
    ld de,$4000
    ld ix,preview
    ld b,8
preview_show:
    ld a,(ix+0)
    push bc
    call show_byte
    ld a,32
    call show_char
    pop bc
    inc ix
    djnz preview_show
    ld a,165
    ld (ready),a
hold:
    jp hold
