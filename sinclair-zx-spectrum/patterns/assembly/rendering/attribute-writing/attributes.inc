; ZX Spectrum attributes, Pasmo syntax. Caller supplies stack and writable display.
; Coordinates are character cells: B=row 0..23, C=column 0..31, A=attribute.
; set_attribute preserves AF/BC/DE; changes HL. No ROM or interrupt dependency.
ATTR_BASE equ $5800
set_attribute:
    push af
    push bc
    ld l,b
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,c
    or l                       ; column occupies the five zero low bits
    ld l,a
    ld bc,ATTR_BASE
    add hl,bc
    pop bc
    pop af
    ld (hl),a
    ret

; B/C=start row/column; D=height, E=width, A=attribute.
; Zero width or height is a no-op. Otherwise row+height<=24, column+width<=32.
; No clipping: caller validates those bounds before entry.
; Preserves AF/BC/DE; changes HL. Maximum additional stack: 16 bytes including
; set_attribute's return address and saves (plus this routine's return address).
fill_attributes:
    push af
    ld a,d
    or a
    jr z,fill_empty
    ld a,e
    or a
    jr z,fill_empty
    pop af
    push af
    push bc
    push de
fill_next_row:
    push bc                    ; remember the left edge, not the current column
    push de                    ; remember width before consuming its counter
fill_next_column:
    call set_attribute         ; A and both loop counters survive
    inc c
    dec e
    jr nz,fill_next_column
    pop de
    pop bc
    inc b
    dec d
    jr nz,fill_next_row
    pop de
    pop bc
fill_empty:
    pop af
    ret

; A=row 0..23, E=attribute. Changes AF/BC/HL; preserves DE.
fill_row:
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld bc,ATTR_BASE
    add hl,bc
    ld b,32
fill_row_byte:
    ld (hl),e
    inc hl
    djnz fill_row_byte
    ret
