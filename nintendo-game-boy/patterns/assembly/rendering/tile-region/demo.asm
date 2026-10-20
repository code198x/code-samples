SECTION "Header", ROM0[$100]
    nop
    jp start
    ds $134-@,0
    db "REGIONDRAW"
    ds $150-@,0
SECTION "Code", ROM0[$150]
DEF NR EQU 49152
DEF RESULT EQU 49216
DEF MAP EQU 49392
DEF MAP_W EQU 12
DEF MAP_H EQU 8
DEF TILE_COUNT EQU 4
DEF SCREEN_COLS EQU 32
DEF SCREEN_ROWS EQU 32
DEF BG_MAP EQU 38912
start:
    di
    ld sp,$fffe
    ; Enter VBlank before disabling a running LCD. Cold reset may already be off.
    ld a,[$ff40]
    bit 7,a
    jr z,lcd_disabled
wait_vblank:
    ld a,[$ff44]
    cp 145
    jr c,wait_vblank
    xor a
    ld [$ff40],a
lcd_disabled:
    xor a
    ld [$ff42],a
    ld [$ff43],a
    ld hl,BG_MAP
    ld bc,1024
clear_map:
    ld [hl],a
    inc hl
    dec bc
    ld a,b
    or c
    jr z,map_cleared
    xor a
    jr clear_map
map_cleared:
    ld hl,TILES
    ld de,$8000
    ld b,64
upload_tiles:
    ld a,[hl]
    inc hl
    ld [de],a
    inc de
    dec b
    jr nz,upload_tiles
    ld a,$e4
    ld [$ff47],a
    ld hl,initial_map
    ld de,MAP
    ld b,96
copy_map:
    ld a,[hl]
    inc hl
    ld [de],a
    inc de
    dec b
    jr nz,copy_map
    ld hl,$97f0
    ld b,16
    ld a,$a5
set_guard:
    ld [hl],a
    inc hl
    dec b
    jr nz,set_guard
    ld hl,$9c00
    ld b,16
    ld a,$a5
set_after_guard:
    ld [hl],a
    inc hl
    dec b
    jr nz,set_after_guard
case_0:
    ld a,2
    ld [NR+0],a
    ld a,1
    ld [NR+1],a
    ld a,4
    ld [NR+2],a
    ld a,3
    ld [NR+3],a
    ld a,5
    ld [NR+4],a
    ld a,3
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+1],a
case_1:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,6
    ld [NR+2],a
    ld a,4
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+2],a
case_2:
    ld a,11
    ld [NR+0],a
    ld a,7
    ld [NR+1],a
    ld a,31
    ld [NR+2],a
    ld a,31
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+3],a
case_3:
    ld a,12
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+4],a
case_4:
    ld a,0
    ld [NR+0],a
    ld a,8
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+5],a
case_5:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,32
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+6],a
case_6:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,32
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+7],a
case_7:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,0
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+8],a
case_8:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,0
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+9],a
case_9:
    ld a,11
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,2
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+10],a
case_10:
    ld a,0
    ld [NR+0],a
    ld a,7
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,2
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+11],a
case_11:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,31
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,2
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+12],a
case_12:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,31
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,2
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+13],a
case_13:
    ld a,255
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,2
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+14],a
case_14:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,255
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,2
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+15],a
case_15:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,255
    ld [NR+3],a
    ld a,1
    ld [NR+4],a
    ld a,2
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+16],a
case_16:
    ld a,0
    ld [NR+0],a
    ld a,0
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,255
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+17],a
case_17:
    ld a,255
    ld [MAP+13],a
    ld a,0
    ld [NR+0],a
    ld a,1
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,2
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+18],a
diagnostic_done:
    ld a,$91
    ld [$ff40],a
    ; A valid map request must be rejected while the LCD owns VRAM.
    xor a
    ld [MAP+13],a
    ld a,0
    ld [NR+0],a
    ld a,1
    ld [NR+1],a
    ld a,0
    ld [NR+2],a
    ld a,0
    ld [NR+3],a
    ld a,2
    ld [NR+4],a
    ld a,1
    ld [NR+5],a
    call region_draw
    ld a,[NR+6]
    or 128
    ld [RESULT+19],a
    ld a,239
    ld [RESULT],a
finished:
    halt
    jp finished
INCLUDE "../../../../../cross-platform/patterns/rendering/region-architectures/sm83.inc"
initial_map:
    db 0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1
TILES:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 170,0,85,0,170,0,85,0,170,0,85,0,170,0,85,0
    db 0,255,0,129,0,129,0,129,0,129,0,129,0,129,0,255
    db 129,129,66,66,36,36,24,24,24,24,36,36,66,66,129,129
