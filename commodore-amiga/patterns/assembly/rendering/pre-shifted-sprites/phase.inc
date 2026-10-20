; SPDX-License-Identifier: MIT
; draw_pixel_sprite: D0.w signed PIXEL X, D1.w Y, A2 screen, A3 phase table.
; Table has 16 pairs of opaque-mask/image chip-RAM pointers for a 16x16 source,
; padded to 32x16 at each phase. Reuses the qualified clipped bob renderer.
; D0-D7/A0-A5 survive, CCR changes. Own/enable blitter; even owned chip spans.
; Saves 36 bytes in addition to the nested renderer's 68, plus returns/IRQs.
draw_pixel_sprite:
    movem.l d0-d3/a0-a4,-(sp)
    move.w d0,d3
    and.w #15,d3
    lsl.w #3,d3
    asr.w #4,d0
    move.l (a3,d3.w),a0
    lea 4(a3),a4
    move.l (a4,d3.w),a1
    bsr draw_clipped
    movem.l (sp)+,d0-d3/a0-a4
    rts
