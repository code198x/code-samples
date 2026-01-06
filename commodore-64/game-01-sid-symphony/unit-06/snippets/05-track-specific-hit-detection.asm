check_hits:
            ; Check X key (track 0)
            lda key_x_prev
            bne +               ; Was already pressed
            lda key_x
            beq +               ; Not pressed now
            lda #$00
            jsr check_hit_on_track
+
            ; Check C key (track 1)
            lda key_c_prev
            bne +
            lda key_c
            beq +
            lda #$01
            jsr check_hit_on_track
+
            ; Check V key (track 2)
            lda key_v_prev
            bne +
            lda key_v
            beq +
            lda #$02
            jsr check_hit_on_track
+           rts

check_hit_on_track:
            sta check_track
            ldx #MAX_NOTES - 1
-           lda note_x,x
            cmp #NOTE_INACTIVE
            beq +
            lda note_track,x
            cmp check_track
            bne +               ; Wrong track
            lda note_x,x
            cmp #HIT_ZONE_COL
            bcc +               ; Before hit zone
            cmp #HIT_ZONE_COL + HIT_ZONE_W
            bcs +               ; After hit zone
            ; HIT!
            jsr erase_note
            lda #NOTE_INACTIVE
            sta note_x,x
            jsr add_score
            jsr update_crowd_hit
            inc streak
            ; ... play sound for this track
            rts
+           dex
            bpl -
            rts
