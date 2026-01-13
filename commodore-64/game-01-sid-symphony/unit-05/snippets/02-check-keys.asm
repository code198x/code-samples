; ----------------------------------------------------------------------------
; Check Keys - Now with hit detection
; ----------------------------------------------------------------------------
; Checks if a key is pressed and if there's a matching note in the hit zone.
; Only plays sound and removes note on a successful hit.

check_keys:
            ; Check Z key (track 1)
            lda #$FD
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_x_key

            ; Z pressed - check for hit on track 1
            lda #1
            sta key_pressed
            jsr check_hit
            bcc check_x_key     ; No hit - don't play sound
            jsr play_voice1
            jsr flash_track1_hit

check_x_key:
            ; Check X key (track 2)
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$80
            bne check_c_key

            ; X pressed - check for hit on track 2
            lda #2
            sta key_pressed
            jsr check_hit
            bcc check_c_key     ; No hit - don't play sound
            jsr play_voice2
            jsr flash_track2_hit

check_c_key:
            ; Check C key (track 3)
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_keys_done

            ; C pressed - check for hit on track 3
            lda #3
            sta key_pressed
            jsr check_hit
            bcc check_keys_done ; No hit - don't play sound
            jsr play_voice3
            jsr flash_track3_hit

check_keys_done:
            lda #$FF
            sta CIA1_PRA
            rts
