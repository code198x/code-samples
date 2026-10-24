; SPDX-License-Identifier: MIT
; Decode Bounded RLE Data. Contiguous private bytes: WRITTEN, ERROR, INPUT_START, INPUT_END, OUTPUT_LIMIT, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
bounded_rle_init:
    clr.b WRITTEN
    clr.b ERROR
    clr.b INPUT_START
    clr.b INPUT_END
    clr.b OUTPUT_LIMIT
    clr.b BUF0
    clr.b BUF1
    clr.b BUF2
    clr.b BUF3
    clr.b BUF4
    clr.b BUF5
    clr.b BUF6
    clr.b BUF7
    rts
bounded_rle_step:
    clr.b WRITTEN
    clr.b ERROR
    cmp.b #STREAM_BYTES,INPUT_END
    bhi.s rle_bounds
    move.b INPUT_START,d0
    cmp.b INPUT_END,d0
    bhi.s rle_bounds
    cmp.b #8,OUTPUT_LIMIT
    bls.s rle_start
rle_bounds:
    move.b #1,ERROR
    rts
rle_start:
    moveq #0,d0
    move.b INPUT_START,d0
    moveq #0,d3
    lea rle_stream,a0
    lea BUF0,a1
rle_pair:
    cmp.b INPUT_END,d0
    beq.s rle_done
    move.w d0,d1
    addq.w #1,d1
    cmp.b INPUT_END,d1
    bhs.s rle_truncated
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    beq.s rle_zero
    addq.w #1,d0
    move.b 0(a0,d0.w),d2
    addq.w #1,d0
rle_copy:
    cmp.b OUTPUT_LIMIT,d3
    bhs.s rle_full
    move.b d2,0(a1,d3.w)
    addq.w #1,d3
    subq.b #1,d1
    bne.s rle_copy
    bra.s rle_pair
rle_full:
    move.b #4,ERROR
    bra.s rle_done
rle_truncated:
    move.b #2,ERROR
    bra.s rle_done
rle_zero:
    move.b #3,ERROR
rle_done:
    move.b d3,WRITTEN
    rts
component_end:
