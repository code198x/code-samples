; Sprite 0: normal size, single-colour white, in front of the background.
; Input: A = X low byte, X = X high bit (0 or 1), Y = raster Y (0..255).
; Requires: VIC bank 0, screen $0400, complete shape at $2000, I/O visible.
; Owns sprite 0; preserves bits 1..7 of shared sprite registers.
; Clobbers A and flags; preserves X and Y. Caller excludes competing writers.
sprite0_show:
    sta $d000
    sty $d001
    lda $d010
    and #$fe
    cpx #0
    beq x_ready
    ora #1
x_ready:
    sta $d010
    lda #$80                 ; ($2000 - bank base $0000) / 64
    sta $07f8                ; screen $0400 + $3f8
    lda #1
    sta $d027
    lda $d017
    and #$fe
    sta $d017                ; no vertical expansion
    lda $d01d
    and #$fe
    sta $d01d                ; no horizontal expansion
    lda $d01c
    and #$fe
    sta $d01c                ; single-colour
    lda $d01b
    and #$fe
    sta $d01b                ; in front of background
    lda $d015
    ora #1
    sta $d015
    rts
