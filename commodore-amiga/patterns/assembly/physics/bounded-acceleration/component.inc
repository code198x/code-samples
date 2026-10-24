; SPDX-License-Identifier: MIT
; Bounded Signed Acceleration. Contiguous private bytes: VEL_LO, VEL_HI, ACC_LO, ACC_HI, LIMIT_LO, LIMIT_HI, CLIPPED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
bounded_acceleration_init:
    clr.b VEL_LO
    clr.b VEL_HI
    clr.b ACC_LO
    clr.b ACC_HI
    clr.b LIMIT_LO
    clr.b LIMIT_HI
    clr.b CLIPPED
    clr.b VALID
    rts
bounded_acceleration_step:
    clr.b CLIPPED
    clr.b VALID
    tst.b LIMIT_HI
    bpl.s accel_valid
    rts
accel_valid:
    move.b #1,VALID
    moveq #0,d0
    move.b VEL_HI,d0
    lsl.w #8,d0
    move.b VEL_LO,d0
    ext.l d0
    moveq #0,d1
    move.b ACC_HI,d1
    lsl.w #8,d1
    move.b ACC_LO,d1
    ext.l d1
    add.l d1,d0
    moveq #0,d2
    move.b LIMIT_HI,d2
    lsl.w #8,d2
    move.b LIMIT_LO,d2
    cmp.l d2,d0
    bgt.s accel_positive
    neg.l d2
    cmp.l d2,d0
    bge.s accel_store
    move.l d2,d0
    bra.s accel_clip
accel_positive:
    move.l d2,d0
accel_clip:
    move.b #1,CLIPPED
accel_store:
    move.b d0,VEL_LO
    lsr.w #8,d0
    move.b d0,VEL_HI
accel_done:
    rts
component_end:
