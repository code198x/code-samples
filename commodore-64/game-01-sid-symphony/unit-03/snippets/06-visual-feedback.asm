update_flash:
            ; Hit flash takes priority
            lda hit_flash
            beq .no_hit
            dec hit_flash
            ldx #HIT_ZONE_W - 1
.hit_loop:
            lda #COL_HIT
            sta COLOUR + (ROW_TRACK2 * 40),x
            dex
            bpl .hit_loop
            rts

.no_hit:
            ; Miss flash
            lda miss_flash
            beq .no_miss
            dec miss_flash
            ldx #HIT_ZONE_W - 1
.miss_loop:
            lda #COL_MISS
            sta COLOUR + (ROW_TRACK2 * 40),x
            dex
            bpl .miss_loop
            rts

.no_miss:
            ; Restore normal colour
            ldx #HIT_ZONE_W - 1
.restore_loop:
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK2 * 40),x
            dex
            bpl .restore_loop
            rts
