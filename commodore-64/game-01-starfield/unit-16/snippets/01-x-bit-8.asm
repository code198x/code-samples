        ; RIGHT (bit 3) — 9-bit clamp to X <= 320
        lda $dc00
        and #%00001000
        bne not_right

        ; Check right boundary
        lda $d010
        and #$01
        beq right_ok            ; MSB clear, X < 256, safe to move right
        lda $d000
        cmp #63                 ; 320 - 256 - 2 + 1 (room for 2-pixel move)
        bcs not_right           ; Too close to right edge

right_ok:
        ; Increment 1 — check for $FF wrap
        inc $d000
        bne +
        lda $d010               ; Low byte wrapped to $00 — toggle bit 8
        eor #$01
        sta $d010
+
        ; Increment 2
        inc $d000
        bne +
        lda $d010
        eor #$01
        sta $d010
+

not_right:
