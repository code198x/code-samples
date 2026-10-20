ORG 0
NR EQU 15360
RESULT EQU 15424
MAP EQU 15600
MAP_W EQU 12
MAP_H EQU 8
TILE_COUNT EQU 4
SCREEN_COLS EQU 40
SCREEN_ROWS EQU 25
SCREEN EQU $3000
COLOUR EQU $3400
start:
    di
    ld sp,$3ff0
    ld hl,12288
    ld de,12289
    ld bc,1023
    ld (hl),0
    ldir
    ld hl,13312
    ld de,13313
    ld bc,1023
    ld (hl),240
    ldir
    ld hl,15872
    ld de,15873
    ld bc,15
    ld (hl),165
    ldir
    ld hl,15888
    ld de,15889
    ld bc,15
    ld (hl),165
    ldir
    ld hl,initial_map
    ld de,MAP
    ld bc,96
    ldir
case_0:
    ld a,2
    ld (NR+0),a
    ld a,1
    ld (NR+1),a
    ld a,4
    ld (NR+2),a
    ld a,3
    ld (NR+3),a
    ld a,5
    ld (NR+4),a
    ld a,3
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+1),a
case_1:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,6
    ld (NR+2),a
    ld a,4
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+2),a
case_2:
    ld a,11
    ld (NR+0),a
    ld a,7
    ld (NR+1),a
    ld a,39
    ld (NR+2),a
    ld a,24
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+3),a
case_3:
    ld a,12
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+4),a
case_4:
    ld a,0
    ld (NR+0),a
    ld a,8
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+5),a
case_5:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,40
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+6),a
case_6:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,25
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+7),a
case_7:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,0
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+8),a
case_8:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,0
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+9),a
case_9:
    ld a,11
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,2
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+10),a
case_10:
    ld a,0
    ld (NR+0),a
    ld a,7
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,2
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+11),a
case_11:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,39
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,2
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+12),a
case_12:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,24
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,2
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+13),a
case_13:
    ld a,255
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,2
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+14),a
case_14:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,255
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,2
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+15),a
case_15:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,255
    ld (NR+3),a
    ld a,1
    ld (NR+4),a
    ld a,2
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+16),a
case_16:
    ld a,0
    ld (NR+0),a
    ld a,0
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,255
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+17),a
case_17:
    ld a,4
    ld (MAP+13),a
    ld a,0
    ld (NR+0),a
    ld a,1
    ld (NR+1),a
    ld a,0
    ld (NR+2),a
    ld a,0
    ld (NR+3),a
    ld a,2
    ld (NR+4),a
    ld a,1
    ld (NR+5),a
    call region_draw
    ld a,(NR+6)
    or 128
    ld (RESULT+18),a
diagnostic_done:
    ld a,239
    ld (RESULT),a
halt:
    jr halt
initial_map:
DB 0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1
glyph_codes:
DB 0,3,1,2
tile_colours:
DB $f0,$f0,$10,$80
INCLUDE "../../../../../cross-platform/patterns/rendering/character-regions/z80.inc"
