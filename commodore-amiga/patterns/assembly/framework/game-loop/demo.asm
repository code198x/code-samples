; A500 OCS PAL, KS1.3, boot ADF. Physical port 2 Fire adds CPU work.
; Takes over custom IRQ/DMA and background colour; chip-memory executable.
; Reuses the input reader from the verified input/sound caller. Reset to leave.
    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    bclr #7,$bfe201
    clr.w updates
    clr.w slow
    move.w #$cafe,ready
main_loop:
    bsr wait_frame
    bsr read_controls
    move.w controls,d0
    and.w #$0010,d0
    move.w d0,slow
    bsr update_game
    bsr draw_screen
    bsr expensive_work
frame_done:
    bra.s main_loop
update_game:
    addq.w #1,updates
    rts
draw_screen:
    move.w updates,d0
    lsr.w #3,d0
    and.w #7,d0
    lsl.w #8,d0
    or.w #$0030,d0
    move.w d0,$180(a5)
    rts
expensive_work:
    tst.w slow
    beq.s work_done
    move.w #60000,d0
work_inner:
    dbra d0,work_inner
work_done:
    rts
signature: dc.b "198XLOOPAMIGA!",0,0,0
    even
ready: dc.w 0
updates: dc.w 0
slow: dc.w 0
    include "frame.inc"
    include "../input-to-sound/input.inc"
program_end:
