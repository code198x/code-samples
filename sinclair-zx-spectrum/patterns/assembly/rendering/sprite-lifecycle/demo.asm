org $8000
SPRITE_W equ 2
start:
    di
    ld sp,$ff00
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),71
    ldir
    ld d,64
    ld b,64
paint_line:
    push bc
    ld e,0
    call pixel_addr
    ld b,32
paint_byte:
    ld a,d
    and 7
    jr nz,paint_ready
    ld a,$55
paint_ready:
    ld (hl),a
    inc hl
    djnz paint_byte
    inc d
    pop bc
    djnz paint_line
    call draw_objects
    ld hl,$cafe
    ld (ready),hl
    im 1
    ei
main:
    halt
    ; Reverse the order in which the previous frame was saved/drawn.
    ld de,(old_b)
    ld hl,under_b
    ld bc,$0210
    call restore_rect
    ld de,(old_a)
    ld hl,under_a
    ld bc,$0210
    call restore_rect
    ld a,(tick)
    inc a
    ld (tick),a
    and 3
    jr nz,no_move
    ld a,(column)
    add a,8
    cp 176
    jr c,column_ready
    ld a,64
column_ready:
    ld (column),a
no_move:
    call draw_objects
    ld a,(updates)
    inc a
    ld (updates),a
    jr main
draw_objects:
    ld d,80
    ld a,(column)
    ld e,a
    call pixel_addr
    ld (old_a),hl
    ex de,hl
    ld hl,under_a
    ld bc,$0210
    call save_rect
    ld de,(old_a)
    ld hl,shape_a
    ld c,16
    call draw_sprite
    ld d,88
    ld e,120
    call pixel_addr
    ld (old_b),hl
    ex de,hl
    ld hl,under_b
    ld bc,$0210
    call save_rect
    ld de,(old_b)
    ld hl,shape_b
    ld c,16
    call draw_sprite
    ret
ready: defw 0
updates: defb 0
tick: defb 0
column: defb 64
old_a: defw 0
old_b: defw 0
under_a: defs 32,0
under_b: defs 32,0
include "background.inc"
include "shapes.inc"
include "../masked-sprites/masked.inc"
include "../bitmap-addressing/bitmap-addressing.inc"
end start
