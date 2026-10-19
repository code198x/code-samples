; SPDX-License-Identifier: MIT
; draw_clipped: D0.w signed X in 16-pixel words, D1.w signed Y in rows.
; A0=opaque mask (1 selects image), A1=image, A2=320x256 one-plane bitmap.
; Source is exactly 32x16, four bytes per row (64 bytes each). Even chip-RAM
; pointers, all ranges owned/disjoint. Caller enables/owns blitter throughout.
; Preserves D0-D7/A0-A5 (CCR changes); 68 stack bytes plus return/IRQ needs.
; Synchronous, no shift/clipping within a word, no OS/copper/IRQ ownership.
draw_clipped:
    movem.l d0-d7/a0-a5,-(sp)
    move.w d1,d6
    moveq #2,d1
    moveq #20,d2
    bsr clip_axis
    tst.w d2
    beq draw_clipped_exit
    movem.l d0-d2,-(sp)
    move.w d6,d0
    moveq #16,d1
    move.w #256,d2
    bsr clip_axis
    movem.l (sp)+,d5-d7
    tst.w d2
    beq draw_clipped_exit
    ; Y outputs D0 destination, D1 source skip, D2 count.
    ; X outputs D5 destination, D6 source skip, D7 count.
    lsl.w #2,d1
    add.w d6,d1
    add.w d6,d1
    adda.w d1,a0
    adda.w d1,a1
    mulu.w #40,d0
    add.w d5,d0
    add.w d5,d0
    adda.l d0,a2
    lea $dff000,a5
    bsr clipped_wait
    move.w #$0fca,$040(a5)
    move.w #0,$042(a5)
    move.w #$ffff,$044(a5)
    move.w #$ffff,$046(a5)
    moveq #4,d3
    sub.w d7,d3
    sub.w d7,d3
    move.w d3,$064(a5)
    move.w d3,$062(a5)
    moveq #40,d3
    sub.w d7,d3
    sub.w d7,d3
    move.w d3,$060(a5)
    move.w d3,$066(a5)
    move.l a0,$050(a5)
    move.l a1,$04c(a5)
    move.l a2,$048(a5)
    move.l a2,$054(a5)
    lsl.w #6,d2
    or.w d7,d2
    move.w d2,$058(a5)
    bsr clipped_wait
draw_clipped_exit:
    movem.l (sp)+,d0-d7/a0-a5
    rts
clipped_wait:
    btst #6,$002(a5)
clipped_busy:
    btst #6,$002(a5)
    bne.s clipped_busy
    rts
