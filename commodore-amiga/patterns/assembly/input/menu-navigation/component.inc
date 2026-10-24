; SPDX-License-Identifier: MIT
; Wrap and Skip Menu Options. Contiguous private bytes: SELECTED, OPTION_COUNT, ENABLED, DELTA, MOVED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
menu_navigation_init:
    clr.b SELECTED
    clr.b OPTION_COUNT
    clr.b ENABLED
    clr.b DELTA
    clr.b MOVED
    clr.b VALID
    rts
menu_navigation_step:
    clr.b MOVED
    clr.b VALID
    moveq #0,d0
    move.b OPTION_COUNT,d0
    beq.s menu_done
    cmp.b #8,d0
    bhi.s menu_done
    moveq #0,d1
    move.b SELECTED,d1
    cmp.b d0,d1
    bhs.s menu_done
    move.b DELTA,d2
    beq.s menu_still
    cmp.b #1,d2
    beq.s menu_start
    cmp.b #255,d2
    bne.s menu_done
menu_start:
    move.b #1,VALID
    subq.w #1,d0
menu_search:
    cmp.b #1,d2
    bne.s menu_previous
    addq.b #1,d1
    cmp.b OPTION_COUNT,d1
    blo.s menu_test
    moveq #0,d1
    bra.s menu_test
menu_previous:
    tst.b d1
    bne.s menu_dec
    move.b OPTION_COUNT,d1
menu_dec:
    subq.b #1,d1
menu_test:
    moveq #0,d3
    move.b ENABLED,d3
    btst d1,d3
    bne.s menu_found
    dbra d0,menu_search
    rts
menu_found:
    cmp.b SELECTED,d1
    beq.s menu_done
    move.b d1,SELECTED
    move.b #1,MOVED
    rts
menu_still:
    move.b #1,VALID
menu_done:
    rts
component_end:
