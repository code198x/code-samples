; TM: existing 20-byte byte-map context. NR: caller-owned 18-byte region.
; NR: srcC,srcR,dstC,dstR,width,height,valid,row,col,scratch,srcPtrLo,Hi,
;     dataWritePort,controlWritePort,nameBaseLo,Hi,descriptorPtrLo,Hi.
; CELL_BYTES is 1 (Graphics I) or 2 (Sega Mode 4). NT_STRIDE is 32.
; Caller owns a stable map/table, VDP latch/ports and name-table rectangle.
; No interrupt changes: exclude concurrent VDP users. See README for timing.
region_draw:
    xor a
    ld (NR+6),a
    ld a,(NR+4)
    or a
    ret z
    ld a,(NR+5)
    or a
    ret z
    ; Compare extent with remaining space, rather than overflowing origin+size.
    ld a,(TM+2)
    ld b,a
    ld a,(NR)
    cp b
    ret nc
    ld c,a
    ld a,b
    sub c
    ld b,a
    ld a,(NR+4)
    cp b
    jr c,region_source_width_ok
    ret nz
region_source_width_ok:
    ld a,(TM+3)
    ld b,a
    ld a,(NR+1)
    cp b
    ret nc
    ld c,a
    ld a,b
    sub c
    ld b,a
    ld a,(NR+5)
    cp b
    jr c,region_source_height_ok
    ret nz
region_source_height_ok:
    ld a,(NR+2)
    cp 32
    ret nc
    ld b,a
    ld a,32
    sub b
    ld b,a
    ld a,(NR+4)
    cp b
    jr c,region_dest_width_ok
    ret nz
region_dest_width_ok:
    ld a,(NR+3)
    cp 24
    ret nc
    ld b,a
    ld a,24
    sub b
    ld b,a
    ld a,(NR+5)
    cp b
    jr c,region_dest_height_ok
    ret nz
region_dest_height_ok:
    ; Preflight every ID before the first OUT: rejection cannot partly draw.
    xor a
    ld (NR+7),a
region_preflight_row:
    call region_source_row
    xor a
    ld (NR+8),a
region_preflight_cell:
    ld a,(TM+14)
    ld b,a
    ld a,(hl)
    cp b
    jr c,region_id_ok
    ret nz
region_id_ok:
    inc hl
    ld a,(NR+8)
    inc a
    ld (NR+8),a
    ld b,a
    ld a,(NR+4)
    cp b
    jr nz,region_preflight_cell
    ld a,(NR+7)
    inc a
    ld (NR+7),a
    ld b,a
    ld a,(NR+5)
    cp b
    jr nz,region_preflight_row
    xor a
    ld (NR+7),a
region_draw_row:
    call region_source_row
    ld (NR+10),hl
    ; Destination and source have independent row strides.
    ld hl,(NR+14)
    ld a,(NR+3)
    ld b,a
    ld a,(NR+7)
    add a,b
    ld b,a
    ld de,NT_STRIDE*CELL_BYTES
    or a
    jr z,region_dest_column
region_dest_rows:
    add hl,de
    djnz region_dest_rows
region_dest_column:
    ld a,(NR+2)
    ld e,a
    ld d,0
    IF CELL_BYTES=2
    sla e
    ENDIF
    add hl,de
    call region_write_address
    ld hl,(NR+10)
    xor a
    ld (NR+8),a
region_draw_cell:
    ld a,(hl)
    push hl
    ld l,a
    ld h,0
    IF CELL_BYTES=2
    add hl,hl
    ENDIF
    ld de,(NR+16)
    add hl,de
    ld a,(NR+12)
    ld c,a
    ld a,(hl)
    call region_out
    IF CELL_BYTES=2
    inc hl
    ld a,(hl)
    call region_out
    ENDIF
    pop hl
    inc hl
    ld a,(NR+8)
    inc a
    ld (NR+8),a
    ld b,a
    ld a,(NR+4)
    cp b
    jr nz,region_draw_cell
    ld a,(NR+7)
    inc a
    ld (NR+7),a
    ld b,a
    ld a,(NR+5)
    cp b
    jp nz,region_draw_row
    ld a,1
    ld (NR+6),a
    ret

region_source_row:
    ld a,(NR)
    ld (TM+4),a
    ld a,(NR+1)
    ld b,a
    ld a,(NR+7)
    add a,b
    ld (TM+5),a
    call tile_locate
    ; tile_locate leaves the computed pointer in TM+8/9, on every CPU port.
    ld hl,(TM+8)
    ret

region_write_address:
    ld a,(NR+13)
    ld c,a
    ld a,l
    call region_out
    ld a,h
    or $40
    call region_out
    ret

region_out:
    ld b,0
    out (c),a
    nop
    nop
    nop
    nop
    ret
