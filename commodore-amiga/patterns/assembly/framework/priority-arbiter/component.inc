; SPDX-License-Identifier: MIT
; Choose the Highest-priority Request. Bind these contiguous private bytes: PRESENT, ID, PRIORITY, REQUEST_ID, REQUEST_PRIORITY, ACCEPTED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
priority_arbiter_init:
    clr.b PRESENT
    clr.b ID
    clr.b PRIORITY
    clr.b REQUEST_ID
    clr.b REQUEST_PRIORITY
    clr.b ACCEPTED
    rts
priority_arbiter_step:
    clr.b ACCEPTED
    tst.b PRESENT
    beq.s arbiter_accept
    move.b REQUEST_PRIORITY,d0
    cmp.b PRIORITY,d0
    bls.s arbiter_done
arbiter_accept:
    move.b REQUEST_ID,ID
    move.b REQUEST_PRIORITY,PRIORITY
    move.b #1,PRESENT
    move.b #1,ACCEPTED
arbiter_done:
    rts
component_end:
