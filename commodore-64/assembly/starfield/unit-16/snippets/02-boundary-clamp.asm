        ; UP (bit 0) — clamp to Y >= 50
        lda $dc00
        and #%00000001
        bne not_up
        lda $d001
        cmp #52                 ; 50 + 2 (room for 2-pixel move)
        bcc not_up
        dec $d001
        dec $d001
not_up:

        ; DOWN (bit 1) — clamp to Y <= 234
        lda $dc00
        and #%00000010
        bne not_down
        lda $d001
        cmp #233                ; 234 - 1 (room for 2-pixel move)
        bcs not_down
        inc $d001
        inc $d001
not_down:

        ; LEFT (bit 2) — 9-bit clamp to X >= 24
        lda $dc00
        and #%00000100
        bne not_left

        ; Check left boundary
        lda $d010
        and #$01
        bne left_ok             ; MSB set, X >= 256, safe to move left
        lda $d000
        cmp #26                 ; 24 + 2 (room for 2-pixel move)
        bcc not_left            ; Too close to left edge

left_ok:
        ; Decrement 1 — check for $00 wrap
        lda $d000
        bne +
        lda $d010               ; Low byte is $00 — toggle bit 8
        eor #$01
        sta $d010
+       dec $d000

        ; Decrement 2
        lda $d000
        bne +
        lda $d010
        eor #$01
        sta $d010
+       dec $d000

not_left:
