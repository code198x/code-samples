; SPDX-License-Identifier: MIT
; Report Trigger Enter, Stay and Exit Events. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
trigger_transitions_init:
    move.b #0,d0
    move.b d0,ENTERED
    move.b d0,STAYED
    move.b d0,EXITED
    move.b d0,PREVIOUS
    move.b d0,CURRENT
    move.b d0,T0
    rts
trigger_transitions_step:
; T0 = PREVIOUS ^ 255
    move.b PREVIOUS,d0
    eor.b #255,d0
    move.b d0,T0
; ENTERED = CURRENT & T0
    move.b CURRENT,d0
    move.b T0,d1
    and.b d1,d0
    move.b d0,ENTERED
; T0 = CURRENT ^ 255
    move.b CURRENT,d0
    eor.b #255,d0
    move.b d0,T0
; EXITED = PREVIOUS & T0
    move.b PREVIOUS,d0
    move.b T0,d1
    and.b d1,d0
    move.b d0,EXITED
; STAYED = CURRENT & PREVIOUS
    move.b CURRENT,d0
    move.b PREVIOUS,d1
    and.b d1,d0
    move.b d0,STAYED
; PREVIOUS = CURRENT
    move.b CURRENT,d0
    move.b d0,PREVIOUS
    rts
component_end:
