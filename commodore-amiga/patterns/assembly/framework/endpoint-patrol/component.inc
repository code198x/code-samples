; SPDX-License-Identifier: MIT
; Patrol Between Two Endpoints. Bind these contiguous private bytes: POSITION, LOWER, UPPER, DIRECTION.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
endpoint_patrol_init:
    clr.b POSITION
    clr.b LOWER
    clr.b UPPER
    clr.b DIRECTION
    rts
endpoint_patrol_step:
    move.b LOWER,d0
    cmp.b UPPER,d0
    bne.s patrol_range
    move.b d0,POSITION
    clr.b DIRECTION
    rts
patrol_range:
    cmp.b POSITION,d0
    beq.s patrol_positive
    move.b UPPER,d0
    cmp.b POSITION,d0
    beq.s patrol_negative
    tst.b DIRECTION
    beq.s patrol_positive
patrol_negative:
    move.b #1,DIRECTION
    subq.b #1,POSITION
    rts
patrol_positive:
    clr.b DIRECTION
    addq.b #1,POSITION
    rts
component_end:
