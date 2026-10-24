; SPDX-License-Identifier: MIT
; Land on a One-way Platform. Contiguous private bytes: LANDED, SNAP, ACTOR_X, ACTOR_W, PREV_BOTTOM, NEW_BOTTOM, PLATFORM_X, PLATFORM_W, PLATFORM_Y, DROP.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
one_way_platform_init:
    clr.b LANDED
    clr.b SNAP
    clr.b ACTOR_X
    clr.b ACTOR_W
    clr.b PREV_BOTTOM
    clr.b NEW_BOTTOM
    clr.b PLATFORM_X
    clr.b PLATFORM_W
    clr.b PLATFORM_Y
    clr.b DROP
    rts
one_way_platform_step:
    clr.b LANDED
    move.b NEW_BOTTOM,SNAP
    tst.b DROP
    bne.s platform_done
    tst.b ACTOR_W
    beq.s platform_done
    tst.b PLATFORM_W
    beq.s platform_done
    move.b PREV_BOTTOM,d0
    cmp.b PLATFORM_Y,d0
    bhi.s platform_done
    move.b NEW_BOTTOM,d0
    cmp.b PLATFORM_Y,d0
    blo.s platform_done
    moveq #0,d0
    move.b PLATFORM_X,d0
    moveq #0,d1
    move.b PLATFORM_W,d1
    add.w d1,d0
    moveq #0,d1
    move.b ACTOR_X,d1
    cmp.w d0,d1
    bhs.s platform_done
    moveq #0,d0
    move.b ACTOR_W,d0
    add.w d1,d0
    moveq #0,d1
    move.b PLATFORM_X,d1
    cmp.w d0,d1
    bhs.s platform_done
    move.b #1,LANDED
    move.b PLATFORM_Y,SNAP
platform_done:
    rts
component_end:
