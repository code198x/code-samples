; A0 -> 32-byte even-aligned context. Six request bytes, valid +6,
; backend +7 (0 CPU, 1 blitter), long map/tiles/plane0/plane1 +8/+12/+16/+20,
; byte map width/height/tile count +24/+25/+26; scratch +27..31.
; A0 preserved; D0-D7/A1-A5/CCR clobbered. Caller owns custom chips and DMA.
region_draw:
    clr.b 6(a0)
    cmp.b #1,7(a0)
    bls region_backend_ok
    rts
region_backend_ok:
    move.l 12(a0),d0
    btst #0,d0
    beq region_tiles_aligned
    rts
region_tiles_aligned:
    move.l 16(a0),d0
    btst #0,d0
    beq region_plane0_aligned
    rts
region_plane0_aligned:
    move.l 20(a0),d0
    btst #0,d0
    beq region_plane1_aligned
    rts
region_plane1_aligned:
    tst.b 4(a0)
    bne bounds_nonzero_0
    rts
bounds_nonzero_0:
    move.b 24(a0),d0
    cmp.b 0(a0),d0
    bhi bounds_start_0
    rts
bounds_start_0:
    sub.b 0(a0),d0
    cmp.b 4(a0),d0
    bhs bounds_fit_0
    rts
bounds_fit_0:
    tst.b 5(a0)
    bne bounds_nonzero_1
    rts
bounds_nonzero_1:
    move.b 25(a0),d0
    cmp.b 1(a0),d0
    bhi bounds_start_1
    rts
bounds_start_1:
    sub.b 1(a0),d0
    cmp.b 5(a0),d0
    bhs bounds_fit_1
    rts
bounds_fit_1:
    tst.b 4(a0)
    bne bounds_nonzero_2
    rts
bounds_nonzero_2:
    move.b #SCREEN_COLS,d0
    cmp.b 2(a0),d0
    bhi bounds_start_2
    rts
bounds_start_2:
    sub.b 2(a0),d0
    cmp.b 4(a0),d0
    bhs bounds_fit_2
    rts
bounds_fit_2:
    tst.b 5(a0)
    bne bounds_nonzero_3
    rts
bounds_nonzero_3:
    move.b #SCREEN_ROWS,d0
    cmp.b 3(a0),d0
    bhi bounds_start_3
    rts
bounds_start_3:
    sub.b 3(a0),d0
    cmp.b 5(a0),d0
    bhs bounds_fit_3
    rts
bounds_fit_3:
    clr.b 30(a0)
region_pass:
    clr.b 27(a0)
region_row:
    clr.b 28(a0)
region_cell:
    moveq #0,d0
    move.b 1(a0),d0
    add.b 27(a0),d0
    moveq #0,d1
    move.b 24(a0),d1
    mulu.w d1,d0
    moveq #0,d1
    move.b (a0),d1
    add.b 28(a0),d1
    add.l d1,d0
    movea.l 8(a0),a1
    move.b 0(a1,d0.l),d1
    move.b d1,29(a0)
    cmp.b 26(a0),d1
    blo region_id_ok
    rts
region_id_ok:
    tst.b 30(a0)
    beq region_next
    bsr region_paint
region_next:
    addq.b #1,28(a0)
    move.b 28(a0),d0
    cmp.b 4(a0),d0
    beq region_row_done
    bra region_cell
region_row_done:
    addq.b #1,27(a0)
    move.b 27(a0),d0
    cmp.b 5(a0),d0
    beq region_pass_done
    bra region_row
region_pass_done:
    tst.b 30(a0)
    bne region_success
    move.b #1,30(a0)
    bra region_pass
region_success:
    move.b #1,6(a0)
    rts
region_paint:
    moveq #0,d0
    move.b 29(a0),d0
    lsl.l #5,d0
    movea.l 12(a0),a1
    adda.l d0,a1
    moveq #0,d0
    move.b 3(a0),d0
    add.b 27(a0),d0
    mulu.w #320,d0
    moveq #0,d1
    move.b 2(a0),d1
    add.b 28(a0),d1
    add.w d1,d1
    add.l d1,d0
    movea.l 16(a0),a2
    adda.l d0,a2
    movea.l 20(a0),a3
    adda.l d0,a3
    tst.b 7(a0)
    bne region_blitter
    moveq #7,d4
region_cpu_plane0:
    move.w (a1)+,(a2)
    lea 40(a2),a2
    dbra d4,region_cpu_plane0
    moveq #7,d4
region_cpu_plane1:
    move.w (a1)+,(a3)
    lea 40(a3),a3
    dbra d4,region_cpu_plane1
    rts
region_blitter:
    lea $dff000,a5
    bsr region_blit_plane
    lea 16(a1),a1
    movea.l a3,a2
    bsr region_blit_plane
    rts
    include "../../../../../cross-platform/patterns/rendering/region-architectures/blit-plane.inc"
