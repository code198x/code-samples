; SPDX-License-Identifier: MIT
; One caller-owned writable byte rng_state. Word-aligned code.
; Seed uses D0.B, zero maps to 1; returns zero-extended byte in D0.
; Next requires nonzero state and exposes an unexpected zero unchanged.
; D0/CCR change; D1-D7/A0-A6 survive. No chipset/IRQ ownership.
rng_seed:
    andi.l #$ff,d0
    bne.s rng_seed_store
    moveq #1,d0
rng_seed_store:
    move.b d0,rng_state
    rts
rng_next:
    moveq #0,d0
    move.b rng_state,d0
    lsr.b #1,d0
    bcc.s rng_next_store
    eori.b #$b4,d0
rng_next_store:
    move.b d0,rng_state
    rts
rng_code_end:
