; A0 points at 24-byte context. D0-D2/A1/CCR clobbered; A0 preserved.
tile_locate:
    clr.b 9(a0)
    moveq #0,d0
    move.b 6(a0),d0
    cmp.b 4(a0),d0
    bcc tile_locate_done
    moveq #0,d1
    move.b 7(a0),d1
    cmp.b 5(a0),d1
    bcc tile_locate_done
    moveq #0,d2
    move.b 4(a0),d2
    mulu.w d2,d1
    add.l d0,d1
    add.l (a0),d1
    movea.l d1,a1
    move.l a1,16(a0)
    move.b #1,9(a0)
tile_locate_done:
    rts

tile_get:
    bsr tile_locate
    tst.b 9(a0)
    beq tile_get_invalid
    move.b (a1),8(a0)
    rts
tile_get_invalid:
    clr.b 8(a0)
    rts

tile_set:
    clr.b 9(a0)
    move.b 8(a0),d0
    cmp.b 11(a0),d0
    bhi tile_set_done
    bsr tile_locate
    tst.b 9(a0)
    beq tile_set_done
    move.b 8(a0),(a1)
tile_set_done:
    rts

tile_property:
    clr.b 9(a0)
    clr.b 10(a0)
    moveq #0,d0
    move.b 8(a0),d0
    cmp.b 11(a0),d0
    bhi tile_property_done
    movea.l 12(a0),a1
    move.b (a1,d0.w),10(a0)
    move.b #1,9(a0)
tile_property_done:
    rts

tile_pixel8:
    clr.b 9(a0)
    clr.b 8(a0)
    move.w 20(a0),d0
    lsr.w #3,d0
    cmp.w #255,d0
    bhi tile_pixel_done
    move.b d0,6(a0)
    move.w 22(a0),d0
    lsr.w #3,d0
    cmp.w #255,d0
    bhi tile_pixel_done
    move.b d0,7(a0)
    bsr tile_get
tile_pixel_done:
    rts
