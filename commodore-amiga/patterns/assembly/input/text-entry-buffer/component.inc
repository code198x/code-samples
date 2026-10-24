; SPDX-License-Identifier: MIT
; A Counted Text-entry Buffer. Contiguous private bytes: LENGTH, STATUS, KEY, MODE, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
text_entry_buffer_init:
    clr.b LENGTH
    clr.b STATUS
    clr.b KEY
    clr.b MODE
    clr.b BUF0
    clr.b BUF1
    clr.b BUF2
    clr.b BUF3
    clr.b BUF4
    clr.b BUF5
    clr.b BUF6
    clr.b BUF7
    rts
text_entry_buffer_step:
    clr.b STATUS
    cmp.b #2,MODE
    beq.s text_clear
    cmp.b #TEXT_CAP,LENGTH
    bhi.s text_bad
    tst.b MODE
    beq.s text_append
    cmp.b #1,MODE
    bne.s text_bad
    tst.b LENGTH
    beq.s text_done
    subq.b #1,LENGTH
    moveq #0,d0
    move.b LENGTH,d0
    lea BUF0,a0
    clr.b 0(a0,d0.w)
    bra.s text_changed
text_append:
    move.b KEY,d1
    cmp.b #32,d1
    blo.s text_bad_key
    cmp.b #126,d1
    bhi.s text_bad_key
    cmp.b #TEXT_CAP,LENGTH
    bhs.s text_done
    moveq #0,d0
    move.b LENGTH,d0
    lea BUF0,a0
    move.b d1,0(a0,d0.w)
    addq.b #1,LENGTH
text_changed:
    move.b #1,STATUS
text_done:
    rts
text_bad_key:
    move.b #2,STATUS
    rts
text_bad:
    move.b #3,STATUS
    rts
text_clear:
    lea BUF0,a0
    moveq #7,d0
text_clear_loop:
    clr.b (a0)+
    dbra d0,text_clear_loop
    clr.b LENGTH
    bra.s text_changed
component_end:
