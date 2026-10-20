; Original CPU/RAM diagnostic: not a display or stock-OS loader.
    section code,code
TM equ $2000
RESULT equ $2040
MAP equ $20f0
start:
    move.w #$2700,sr
    move.b #3,$bfe201
    move.b #2,$bfe001          ; remove reset ROM overlay before using RAM/stack
    lea $7f000,sp
    lea TM,a0
    moveq #0,d0
    moveq #23,d1
clear_context:
    move.b d0,(a0)+
    dbra d1,clear_context
    lea TM,a0
    lea initial_map(pc),a1
    lea MAP,a2
    moveq #34,d0
copy_map:
    move.b (a1)+,(a2)+
    dbra d0,copy_map
    move.b #$a5,MAP+35
    move.l #MAP,(a0)
    move.b #7,4(a0)
    move.b #5,5(a0)
    move.b #3,11(a0)
    move.l #(properties+$f80008),12(a0)
    move.b #0,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_0
    move.b #255,8(a0)
valid_0:
    move.b 8(a0),RESULT+0
    move.b #1,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_1
    move.b #255,8(a0)
valid_1:
    move.b 8(a0),RESULT+1
    move.b #2,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_2
    move.b #255,8(a0)
valid_2:
    move.b 8(a0),RESULT+2
    move.b #3,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_3
    move.b #255,8(a0)
valid_3:
    move.b 8(a0),RESULT+3
    move.b #4,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_4
    move.b #255,8(a0)
valid_4:
    move.b 8(a0),RESULT+4
    move.b #5,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_5
    move.b #255,8(a0)
valid_5:
    move.b 8(a0),RESULT+5
    move.b #6,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_6
    move.b #255,8(a0)
valid_6:
    move.b 8(a0),RESULT+6
    move.b #0,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_7
    move.b #255,8(a0)
valid_7:
    move.b 8(a0),RESULT+7
    move.b #1,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_8
    move.b #255,8(a0)
valid_8:
    move.b 8(a0),RESULT+8
    move.b #2,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_9
    move.b #255,8(a0)
valid_9:
    move.b 8(a0),RESULT+9
    move.b #3,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_10
    move.b #255,8(a0)
valid_10:
    move.b 8(a0),RESULT+10
    move.b #4,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_11
    move.b #255,8(a0)
valid_11:
    move.b 8(a0),RESULT+11
    move.b #5,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_12
    move.b #255,8(a0)
valid_12:
    move.b 8(a0),RESULT+12
    move.b #6,6(a0)
    move.b #1,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_13
    move.b #255,8(a0)
valid_13:
    move.b 8(a0),RESULT+13
    move.b #0,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_14
    move.b #255,8(a0)
valid_14:
    move.b 8(a0),RESULT+14
    move.b #1,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_15
    move.b #255,8(a0)
valid_15:
    move.b 8(a0),RESULT+15
    move.b #2,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_16
    move.b #255,8(a0)
valid_16:
    move.b 8(a0),RESULT+16
    move.b #3,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_17
    move.b #255,8(a0)
valid_17:
    move.b 8(a0),RESULT+17
    move.b #4,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_18
    move.b #255,8(a0)
valid_18:
    move.b 8(a0),RESULT+18
    move.b #5,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_19
    move.b #255,8(a0)
valid_19:
    move.b 8(a0),RESULT+19
    move.b #6,6(a0)
    move.b #2,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_20
    move.b #255,8(a0)
valid_20:
    move.b 8(a0),RESULT+20
    move.b #0,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_21
    move.b #255,8(a0)
valid_21:
    move.b 8(a0),RESULT+21
    move.b #1,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_22
    move.b #255,8(a0)
valid_22:
    move.b 8(a0),RESULT+22
    move.b #2,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_23
    move.b #255,8(a0)
valid_23:
    move.b 8(a0),RESULT+23
    move.b #3,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_24
    move.b #255,8(a0)
valid_24:
    move.b 8(a0),RESULT+24
    move.b #4,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_25
    move.b #255,8(a0)
valid_25:
    move.b 8(a0),RESULT+25
    move.b #5,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_26
    move.b #255,8(a0)
valid_26:
    move.b 8(a0),RESULT+26
    move.b #6,6(a0)
    move.b #3,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_27
    move.b #255,8(a0)
valid_27:
    move.b 8(a0),RESULT+27
    move.b #0,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_28
    move.b #255,8(a0)
valid_28:
    move.b 8(a0),RESULT+28
    move.b #1,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_29
    move.b #255,8(a0)
valid_29:
    move.b 8(a0),RESULT+29
    move.b #2,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_30
    move.b #255,8(a0)
valid_30:
    move.b 8(a0),RESULT+30
    move.b #3,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_31
    move.b #255,8(a0)
valid_31:
    move.b 8(a0),RESULT+31
    move.b #4,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_32
    move.b #255,8(a0)
valid_32:
    move.b 8(a0),RESULT+32
    move.b #5,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_33
    move.b #255,8(a0)
valid_33:
    move.b 8(a0),RESULT+33
    move.b #6,6(a0)
    move.b #4,7(a0)
    bsr tile_get
    cmp.b #1,9(a0)
    beq valid_34
    move.b #255,8(a0)
valid_34:
    move.b 8(a0),RESULT+34
    clr.b RESULT+35
    clr.b RESULT+36
    move.b #7,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    move.b 9(a0),d0
    or.b 8(a0),d0
    or.b d0,RESULT+35
    move.b #0,6(a0)
    move.b #5,7(a0)
    bsr tile_get
    move.b 9(a0),d0
    or.b 8(a0),d0
    or.b d0,RESULT+35
    move.b #255,6(a0)
    move.b #0,7(a0)
    bsr tile_get
    move.b 9(a0),d0
    or.b 8(a0),d0
    or.b d0,RESULT+35
    move.b #0,6(a0)
    move.b #255,7(a0)
    bsr tile_get
    move.b 9(a0),d0
    or.b 8(a0),d0
    or.b d0,RESULT+35
    move.b #7,6(a0)
    move.b #0,7(a0)
    move.b #1,8(a0)
    bsr tile_set
    move.b 9(a0),d0
    or.b d0,RESULT+36
    move.b #0,6(a0)
    move.b #5,7(a0)
    move.b #1,8(a0)
    bsr tile_set
    move.b 9(a0),d0
    or.b d0,RESULT+36
    move.b #255,6(a0)
    move.b #0,7(a0)
    move.b #1,8(a0)
    bsr tile_set
    move.b 9(a0),d0
    or.b d0,RESULT+36
    move.b #0,6(a0)
    move.b #255,7(a0)
    move.b #1,8(a0)
    bsr tile_set
    move.b 9(a0),d0
    or.b d0,RESULT+36
    move.b #0,6(a0)
    move.b #0,7(a0)
    move.b #255,8(a0)
    bsr tile_set
    move.b 9(a0),d0
    or.b d0,RESULT+36
    move.b #1,RESULT+37
    lea initial_map(pc),a1
    lea MAP,a2
    moveq #34,d0
check_unchanged:
    move.b (a1)+,d1
    cmp.b (a2)+,d1
    beq same_cell
    clr.b RESULT+37
same_cell:
    dbra d0,check_unchanged
    cmp.b #$a5,MAP+35
    beq guard_ok
    clr.b RESULT+37
guard_ok:
    move.b #255,8(a0)
    bsr tile_property
    move.b 9(a0),d0
    or.b 10(a0),d0
    beq property_rejected
    clr.b RESULT+37
property_rejected:
    move.b #0,6(a0)
    move.b #0,7(a0)
    move.b #3,8(a0)
    bsr tile_set
    move.b 9(a0),RESULT+38
    bsr tile_get
    move.b 8(a0),RESULT+39
    bsr tile_property
    move.b 10(a0),RESULT+40
    move.w #31,20(a0)
    move.w #23,22(a0)
    bsr tile_pixel8
    move.b 8(a0),RESULT+41
    move.w #2048,20(a0)
    bsr tile_pixel8
    move.b 9(a0),RESULT+42
    move.b #239,RESULT+43
done:
    bra done
    include "../../../../../cross-platform/patterns/rendering/tile-map/m68000.inc"
initial_map:
    dc.b 0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2
properties:
    dc.b 0,1,2,4
    even
