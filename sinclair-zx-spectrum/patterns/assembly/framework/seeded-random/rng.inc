; SPDX-License-Identifier: MIT
; Caller allocates one private writable byte rng_state.
; A=seed byte, external zero deliberately maps to 1. A=next result.
; AF changes; BC/DE/HL/IX/IY survive. No port/interrupt changes.
rng_seed:
    or a
    jr nz,rng_seed_store
    inc a
rng_seed_store:
    ld (rng_state),a
    ret
rng_next:
    ld a,(rng_state)
    srl a
    jr nc,rng_next_store
    xor $b4
rng_next_store:
    ld (rng_state),a
    ret
rng_code_end:
