; Original region-drawing diagnostic for sega-sg-1000. Reusable routines below.
TM equ $c320
NR equ $c334
RESULT equ $c354
CELL_BYTES equ 1
NT_STRIDE equ 32
org 0
jp start
db 0,0,0
db $be,$be
org $100
start:
    di
    ld sp,$c3f0
    call initialise_context
    call initialise_video
example_call:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,main_rectangle
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80 ; nonzero diagnostic marker, including rejected calls
    ld (RESULT+1),a
verification_cases:
case_source_right:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_source_right
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+2),a
case_source_bottom:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_source_bottom
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+3),a
case_destination_right:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_destination_right
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+4),a
case_destination_bottom:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_destination_bottom
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+5),a
case_zero_width:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_zero_width
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+6),a
case_zero_height:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_zero_height
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+7),a
case_large_width:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_large_width
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+8),a
case_large_origin:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_large_origin
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+9),a
case_invalid_id:
    ld hl,bad_map
    ld (TM),hl
    ld a,2
    ld (TM+2),a
    ld a,1
    ld (TM+3),a
    ld hl,rect_invalid_id
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+10),a
case_source_x_edge:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_source_x_edge
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+11),a
case_source_y_edge:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_source_y_edge
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+12),a
case_source_y_large:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_source_y_large
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+13),a
case_dest_x_edge:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_dest_x_edge
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+14),a
case_dest_y_edge:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_dest_y_edge
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+15),a
case_dest_x_large:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_dest_x_large
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+16),a
case_dest_y_large:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_dest_y_large
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+17),a
case_height_large:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_height_large
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+18),a
case_redraw:
    ld hl,single_map
    ld (TM),hl
    ld a,1
    ld (TM+2),a
    ld a,1
    ld (TM+3),a
    ld hl,rect_redraw
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+19),a
case_source_corner:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_source_corner
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+20),a
case_logical_corner:
    ld hl,main_map
    ld (TM),hl
    ld a,12
    ld (TM+2),a
    ld a,8
    ld (TM+3),a
    ld hl,rect_logical_corner
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+21),a
case_handheld_corner:
    ld hl,single_map
    ld (TM),hl
    ld a,1
    ld (TM+2),a
    ld a,1
    ld (TM+3),a
    ld hl,rect_handheld_corner
    ld de,NR
    ld bc,6
    ldir
    call region_draw
    ld a,(NR+6)
    or $80
    ld (RESULT+22),a
    call copy_name_table
    ld a,$c0
    ld e,1
    call write_register
    ld a,239
    ld (RESULT),a
finished:
    halt
    jp finished
initialise_context:
    ld a,3
    ld (TM+14),a
    ld a,$be
    ld (NR+12),a
    ld a,$bf
    ld (NR+13),a
    ld hl,$1800
    ld (NR+14),hl
    ld hl,descriptors
    ld (NR+16),hl
    ret
initialise_video:
    ld hl,registers
    ld e,0
    ld d,8
register_loop:
    ld a,(hl)
    call write_register
    inc hl
    inc e
    dec d
    jr nz,register_loop
    ld hl,0
    call region_write_address
    ld de,$4000
clear_video:
    ld a,(NR+12)
    ld c,a
    xor a
    call region_out
    dec de
    ld a,d
    or e
    jr nz,clear_video
    ld hl,0
    call region_write_address
    ld hl,patterns
    ld de,256
load_patterns:
    ld a,(NR+12)
    ld c,a
    ld a,(hl)
    call region_out
    inc hl
    dec de
    ld a,d
    or e
    jr nz,load_patterns
    ld hl,$2000
    call region_write_address
    ld hl,colours
    ld d,4
load_colours:
    ld a,(NR+12)
    ld c,a
    ld a,(hl)
    call region_out
    inc hl
    dec d
    jr nz,load_colours
    ld hl,$1b00
    call region_write_address
    ld a,(NR+12)
    ld c,a
    ld a,$d0
    call region_out
    ret
write_register:
    push af
    ld a,(NR+13)
    ld c,a
    pop af
    call region_out
    ld a,e
    or $80
    call region_out
    ret
copy_name_table:
    ld a,(NR+13)
    ld c,a
    ld a,$00
    call region_out
    ld a,$18
    call region_out
    ld a,$be
    ld c,a
    ld b,0
    ld hl,$c000
    ld de,800
read_video:
    in a,(c)
    ld (hl),a
    nop
    nop
    nop
    nop
    inc hl
    dec de
    ld a,d
    or e
    jr nz,read_video
    ret
registers:
    db 0,$80,6,$80,0,$36,7,$f1
main_rectangle:
    db 2,1,8,5,7,5
rect_source_right:
    db 11,1,16,5,2,1
rect_source_bottom:
    db 0,7,16,5,2,2
rect_destination_right:
    db 0,0,31,5,2,1
rect_destination_bottom:
    db 0,0,16,23,2,2
rect_zero_width:
    db 0,0,16,5,0,1
rect_zero_height:
    db 0,0,16,5,1,0
rect_large_width:
    db 0,0,16,5,255,1
rect_large_origin:
    db 255,255,16,5,1,1
rect_invalid_id:
    db 0,0,16,5,2,1
rect_source_x_edge:
    db 12,0,16,5,1,1
rect_source_y_edge:
    db 0,8,16,5,1,1
rect_source_y_large:
    db 0,255,16,5,1,1
rect_dest_x_edge:
    db 0,0,32,5,1,1
rect_dest_y_edge:
    db 0,0,16,24,1,1
rect_dest_x_large:
    db 0,0,255,5,1,1
rect_dest_y_large:
    db 0,0,16,255,1,1
rect_height_large:
    db 0,0,16,5,1,255
rect_redraw:
    db 0,0,10,7,1,1
rect_source_corner:
    db 11,7,22,12,1,1
rect_logical_corner:
    db 1,0,31,23,1,1
rect_handheld_corner:
    db 0,0,25,20,1,1
org $0ff0
main_map:
    db 0,1,2,3,0,1,2,3,0,1,2,3
    db 2,3,0,1,2,3,0,1,2,3,0,1
    db 0,1,2,3,0,1,2,3,0,1,2,3
    db 2,3,0,1,2,3,0,1,2,3,0,1
    db 0,1,2,3,0,1,2,3,0,1,2,3
    db 2,3,0,1,2,3,0,1,2,3,0,1
    db 0,1,2,3,0,1,2,3,0,1,2,3
    db 2,3,0,1,2,3,0,1,2,3,0,1
bad_map:
    db 1,4
single_map:
    db 3
descriptors:
    db 0,8,16,24
colours:
    db $f1,$31,$81,$b1
patterns:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $aa,$55,$aa,$55,$aa,$55,$aa,$55,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $81,$42,$24,$18,$18,$24,$42,$81,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $08,$0c,$fe,$ff,$fe,$0c,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    include "../../../../../cross-platform/patterns/rendering/tile-map/z80.inc"
    include "../../../../../cross-platform/patterns/rendering/tile-region/region.inc"
