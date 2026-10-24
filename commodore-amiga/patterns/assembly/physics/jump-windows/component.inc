; SPDX-License-Identifier: MIT
; Jump Buffering and Coyote Time. Contiguous private bytes: JUMPED, COYOTE, BUFFER, GROUNDED, PRESSED.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
jump_windows_init:
    clr.b JUMPED
    clr.b COYOTE
    clr.b BUFFER
    clr.b GROUNDED
    clr.b PRESSED
    rts
jump_windows_step:
    clr.b JUMPED
    tst.b COYOTE
    beq.s jump_buffer
    subq.b #1,COYOTE
jump_buffer:
    tst.b BUFFER
    beq.s jump_ground
    subq.b #1,BUFFER
jump_ground:
    tst.b GROUNDED
    beq.s jump_press
    move.b #COYOTE_STEPS,COYOTE
jump_press:
    tst.b PRESSED
    beq.s jump_test
    move.b #BUFFER_STEPS,BUFFER
jump_test:
    tst.b COYOTE
    beq.s jump_done
    tst.b BUFFER
    beq.s jump_done
    move.b #1,JUMPED
    clr.b COYOTE
    clr.b BUFFER
jump_done:
    rts
component_end:
