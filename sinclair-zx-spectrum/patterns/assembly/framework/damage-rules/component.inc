; SPDX-License-Identifier: MIT
; Private byte fields HEALTH/REMAINING/AMOUNT/APPLIED/KILLED.
; AF/BC change; DE/HL/IX/IY survive. PERIOD0..255, init health3.
; One call/entity/simulation update. Tick before aggregated damage.
; Saturate health0, accepted/death pulses clear on the next step.
; No I/O/IRQ/wait/sampler ownership; single owner.
damage_init:
    ld a,3
    ld (HEALTH),a
    xor a
    ld (REMAINING),a
    ld (AMOUNT),a
    ld (APPLIED),a
    ld (KILLED),a
    ret
damage_step:
    xor a
    ld (APPLIED),a
    ld (KILLED),a
    ld a,(REMAINING)
    or a
    jr z,damage_after_tick
    dec a
    ld (REMAINING),a
damage_after_tick:
    ld a,(HEALTH)
    or a
    ret z
    ld b,a
    ld a,(REMAINING)
    or a
    ret nz
    ld a,(AMOUNT)
    or a
    ret z
    cp b
    jr nc,damage_fatal
    ld c,a
    ld a,b
    sub c
    ld (HEALTH),a
    ld a,PERIOD
    ld (REMAINING),a
    ld a,1
    ld (APPLIED),a
    ret
damage_fatal:
    xor a
    ld (HEALTH),a
    ld (REMAINING),a
    inc a
    ld (APPLIED),a
    ld (KILLED),a
    ret
component_end:
