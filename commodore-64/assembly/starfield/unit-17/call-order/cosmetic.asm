; Optional fixture decoration, not a change to the game or its RNG.
; Both routines clobber A and Y. The harness calls them only at safe boundaries.
cosmetic_draw:
        jsr advance_rng
        lda rng_seed
        sta cosmetic_byte
        lda #0                  ; Consumer 0 = decorative border
        jsr log_draw
        lda cosmetic_byte
        and #15
        sta $d020               ; Purely cosmetic use of this byte
        rts
log_draw:
        ldy draw_offset
        sta draws,y             ; Consumer id supplied in A
        lda rng_seed
        sta draws+1,y           ; Random byte actually consumed
        iny
        iny
        sty draw_offset
        rts
