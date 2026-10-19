; SPDX-License-Identifier: MIT
; Synchronous OCS word-aligned save/draw/restore. No static state.
; D0=width words 0..64, D1=height 0..1024, D2=screen row stride bytes.
; Zero width/height no-op. For other sizes: stride even, 2*width<=stride<=32766.
; Every pointer even, every byte touched in owned chip RAM; buffers do not
; overlap code/stack or one another. Source/saved rows are packed (2*width).
; All routines change D0,D3-D5,A5,CCR; D1,D2,A0-A2 survive.
; Caller owns/enables blitter DMA and excludes other blitter users until return.
; Each operation waits before programming AND before return. No shifts/clipping.
; Save: A0=screen rectangle, A1=packed save buffer.
bob_save:
    tst.w d0
    beq _bob_return
    tst.w d1
    beq _bob_return
    move.w d2,d3
    sub.w d0,d3
    sub.w d0,d3
    moveq #0,d4
    bra _bob_copy
; Restore: A0=packed save buffer, A1=screen rectangle.
bob_restore:
    tst.w d0
    beq _bob_return
    tst.w d1
    beq _bob_return
    moveq #0,d3
    move.w d2,d4
    sub.w d0,d4
    sub.w d0,d4
_bob_copy:
    lea $dff000,a5
    bsr _bob_wait
    move.w #$09f0,$040(a5)
    move.w #0,$042(a5)
    move.w #$ffff,$044(a5)
    move.w #$ffff,$046(a5)
    move.w d3,$064(a5)
    move.w d4,$066(a5)
    move.l a0,$050(a5)
    move.l a1,$054(a5)
    bra _bob_start
; Draw: A0=opaque mask (1=image), A1=image, A2=screen rectangle.
; D = (A AND B) OR (NOT A AND C), minterm $CA. No image-data restriction on
; transparent bits: A chooses whether B or the old C appears.
bob_draw:
    tst.w d0
    beq _bob_return
    tst.w d1
    beq _bob_return
    lea $dff000,a5
    bsr _bob_wait
    move.w #$0fca,$040(a5)
    move.w #0,$042(a5)
    move.w #$ffff,$044(a5)
    move.w #$ffff,$046(a5)
    move.w #0,$064(a5)
    move.w #0,$062(a5)
    move.w d2,d3
    sub.w d0,d3
    sub.w d0,d3
    move.w d3,$060(a5)
    move.w d3,$066(a5)
    move.l a0,$050(a5)
    move.l a1,$04c(a5)
    move.l a2,$048(a5)
    move.l a2,$054(a5)
_bob_start:
    move.w d1,d5
    lsl.w #6,d5
    and.w #63,d0
    or.w d0,d5
    move.w d5,$058(a5)
_bob_wait:
    btst #6,$002(a5)
_bob_busy:
    btst #6,$002(a5)
    bne.s _bob_busy
_bob_return:
    rts
