; SPDX-License-Identifier: MIT
; Caller defines RNG_STATE as one private writable zero-page byte.
; rng_seed: A=external byte; zero maps to one. Returns normalized seed in A.
; rng_next: A=next state; requires nonzero state. Does NOT conceal corruption.
; A/flags change, X/Y survive. Decimal flag is unchanged. Not re-entrant.
rng_seed:
    cmp #0
    bne rng_seed_store
    lda #1
rng_seed_store:
    sta RNG_STATE
    rts
rng_next:
    lda RNG_STATE
    lsr
    bcc rng_next_store
    eor #$b4
rng_next_store:
    sta RNG_STATE
    rts
rng_code_end:
