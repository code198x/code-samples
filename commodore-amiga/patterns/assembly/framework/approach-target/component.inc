; SPDX-License-Identifier: MIT
; Approach a Target Without Overshoot. Bind these contiguous private bytes: POSITION, TARGET, STEP, ARRIVED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
approach_target_init:
    clr.b POSITION
    clr.b TARGET
    clr.b STEP
    clr.b ARRIVED
    rts
approach_target_step:
    clr.b ARRIVED
    moveq #0,d0
    move.b POSITION,d0
    moveq #0,d1
    move.b TARGET,d1
    cmp.w d1,d0
    beq.s approach_arrived
    blo.s approach_up
    sub.w d1,d0
    moveq #0,d2
    move.b STEP,d2
    cmp.w d2,d0
    bls.s approach_snap
    sub.b d2,POSITION
    rts
approach_up:
    sub.w d0,d1
    moveq #0,d2
    move.b STEP,d2
    cmp.w d2,d1
    bls.s approach_snap
    add.b d2,POSITION
    rts
approach_snap:
    move.b TARGET,POSITION
approach_arrived:
    move.b #1,ARRIVED
    rts
component_end:
