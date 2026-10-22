; DELIBERATELY BROKEN: diagnostic fault only, not reusable code.
; Byte map, caller-owned TM..TM+19 context. AF/BC/DE/HL clobbered.
; Only instructions shared with SM83; the GB file uses its source syntax.
tile_locate:
    xor a
    ld (TM+7),a
    ld a,(TM+2)
    ld b,a
    ld a,(TM+4)
    cp b
    ret nc
    ld a,(TM+3)
    ld b,a
    ld a,(TM+5)
    cp b
    ret nc
    ld b,a
    ld a,(TM)
    ld l,a
    ld a,(TM+1)
    ld h,a
    ld a,6
    ld e,a
    ld d,0
    ld a,b
    or a
    jr z,tile_column
tile_rows:
    add hl,de
    dec b
    jr nz,tile_rows
tile_column:
    ld a,(TM+4)
    ld e,a
    add hl,de
    ld a,l
    ld (TM+8),a
    ld a,h
    ld (TM+9),a
    ld a,1
    ld (TM+7),a
    ret

tile_get:
    call tile_locate
    ld a,(TM+7)
    or a
    jr z,tile_get_invalid
    ld a,(TM+8)
    ld l,a
    ld a,(TM+9)
    ld h,a
    ld a,(hl)
    ld (TM+6),a
    ret
tile_get_invalid:
    xor a
    ld (TM+6),a
    ret

tile_set:
    xor a
    ld (TM+7),a
    ld a,(TM+14)
    ld b,a
    ld a,(TM+6)
    cp b
    jr c,tile_set_id_ok
    jr z,tile_set_id_ok
    ret
tile_set_id_ok:
    call tile_locate
    ld a,(TM+7)
    or a
    ret z
    ld a,(TM+8)
    ld l,a
    ld a,(TM+9)
    ld h,a
    ld a,(TM+6)
    ld (hl),a
    ret

tile_property:
    xor a
    ld (TM+7),a
    ld (TM+11),a
    ld a,(TM+14)
    ld b,a
    ld a,(TM+6)
    cp b
    jr c,tile_property_ok
    jr z,tile_property_ok
    ret
tile_property_ok:
    ld e,a
    ld d,0
    ld a,(TM+12)
    ld l,a
    ld a,(TM+13)
    ld h,a
    add hl,de
    ld a,(hl)
    ld (TM+11),a
    ld a,1
    ld (TM+7),a
    ret

tile_pixel8:
    xor a
    ld (TM+7),a
    ld (TM+6),a
    ld a,(TM+16)
    ld l,a
    ld a,(TM+17)
    ld h,a
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    ld a,h
    or a
    ret nz
    ld a,l
    ld (TM+4),a
    ld a,(TM+18)
    ld l,a
    ld a,(TM+19)
    ld h,a
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    ld a,h
    or a
    ret nz
    ld a,l
    ld (TM+5),a
    jp tile_get
