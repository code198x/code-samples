; SPDX-License-Identifier: MIT
; A Bounded Event Queue. Bind these contiguous private bytes: HEAD, TAIL, COUNT, VALUE, MODE, OK, B0, B1, B2, B3.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
event_queue_init:
    clr.b HEAD
    clr.b TAIL
    clr.b COUNT
    clr.b VALUE
    clr.b MODE
    clr.b OK
    clr.b B0
    clr.b B1
    clr.b B2
    clr.b B3
    rts
event_queue_step:
    clr.b OK
    move.b MODE,d0
    cmp.b #1,d0
    beq.s queue_push
    cmp.b #2,d0
    bne.s queue_done
    tst.b COUNT
    beq.s queue_done
    moveq #0,d0
    move.b HEAD,d0
    lea B0,a0
    move.b 0(a0,d0.w),VALUE
    addq.b #1,d0
    cmp.b #QUEUE_CAP,d0
    blo.s queue_pop_index
    moveq #0,d0
queue_pop_index:
    move.b d0,HEAD
    subq.b #1,COUNT
    bra.s queue_success
queue_push:
    cmp.b #QUEUE_CAP,COUNT
    bhs.s queue_done
    moveq #0,d0
    move.b TAIL,d0
    lea B0,a0
    move.b VALUE,0(a0,d0.w)
    addq.b #1,d0
    cmp.b #QUEUE_CAP,d0
    blo.s queue_push_index
    moveq #0,d0
queue_push_index:
    move.b d0,TAIL
    addq.b #1,COUNT
queue_success:
    move.b #1,OK
queue_done:
    rts
component_end:
