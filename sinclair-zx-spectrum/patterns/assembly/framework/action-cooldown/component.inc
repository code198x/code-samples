; SPDX-License-Identifier: MIT
; REMAINING/REQUEST/AVAILABLE/GRANTED: four private bytes, PERIOD0..255.
; AF changes; BC/DE/HL/IX/IY survive. tick once/update even without input;
; try commits a request only if ready and available (nonzero inputs true).
; GRANTED clears on tick/try. Caller owns truthful resource availability,
; immediate effect creation, input policy and one mutation owner. No waits/I/O.
cooldown_init:
    xor a
    ld (REMAINING),a
    ld (REQUEST),a
    ld (AVAILABLE),a
    ld (GRANTED),a
    ret
cooldown_tick:
    xor a
    ld (GRANTED),a
    ld a,(REMAINING)
    or a
    ret z
    dec a
    ld (REMAINING),a
    ret
cooldown_try:
    xor a
    ld (GRANTED),a
    ld a,(REQUEST)
    or a
    ret z
    ld a,(AVAILABLE)
    or a
    ret z
    ld a,(REMAINING)
    or a
    ret nz
    ld a,1
    ld (GRANTED),a
    ld a,PERIOD
    ld (REMAINING),a
    ret
component_end:
