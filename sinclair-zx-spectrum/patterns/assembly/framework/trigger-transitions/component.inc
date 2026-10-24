; SPDX-License-Identifier: MIT
; Report Trigger Enter, Stay and Exit Events. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
trigger_transitions_init:
    ld a,0
    ld (ENTERED),a
    ld (STAYED),a
    ld (EXITED),a
    ld (PREVIOUS),a
    ld (CURRENT),a
    ld (T0),a
    ret
trigger_transitions_step:
; T0 = PREVIOUS ^ 255
    ld a,(PREVIOUS)
    xor 255
    ld (T0),a
; ENTERED = CURRENT & T0
    ld a,(CURRENT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    and c
    ld (ENTERED),a
; T0 = CURRENT ^ 255
    ld a,(CURRENT)
    xor 255
    ld (T0),a
; EXITED = PREVIOUS & T0
    ld a,(PREVIOUS)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    and c
    ld (EXITED),a
; STAYED = CURRENT & PREVIOUS
    ld a,(CURRENT)
    ld b,a
    ld a,(PREVIOUS)
    ld c,a
    ld a,b
    and c
    ld (STAYED),a
; PREVIOUS = CURRENT
    ld a,(CURRENT)
    ld (PREVIOUS),a
    ret
component_end:
