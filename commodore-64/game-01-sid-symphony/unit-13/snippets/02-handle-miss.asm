; Handle miss - note left hit zone or wrong key pressed
;
; For implicit misses (called from update_notes):
;   X = note index, we read track from note_track array
;
; For explicit misses (called from handle_input):
;   miss_track already set by caller

handle_miss:
                ; Increment miss counter
                inc miss_count

                ; Get the track from the note
                lda note_track,x
                sta miss_track

                ; Set flash timer for miss (red)
                cmp #1
                bne .not_t1
                lda #10
                sta miss_t1_timer
                jmp .play_miss
.not_t1:
                cmp #2
                bne .not_t2
                lda #10
                sta miss_t2_timer
                jmp .play_miss
.not_t2:
                lda #10
                sta miss_t3_timer

.play_miss:
                ; Play miss sound (noise burst)
                lda #$80                ; Noise waveform
                sta SID_V3_CTRL
                lda #$20                ; Low frequency noise
                sta SID_V3_FREQ_HI
                lda #$00
                sta SID_V3_FREQ_LO
                lda #$0a                ; Quick attack/decay
                sta SID_V3_AD
                lda #$00
                sta SID_V3_SR
                lda #$81                ; Gate on
                sta SID_V3_CTRL
                rts

; Handle explicit miss (key pressed with no note)
handle_explicit_miss:
                inc miss_count

                ; Set flash timer based on track
                lda miss_track
                cmp #1
                bne .exp_not_t1
                lda #10
                sta miss_t1_timer
                jmp .exp_sound
.exp_not_t1:
                cmp #2
                bne .exp_not_t2
                lda #10
                sta miss_t2_timer
                jmp .exp_sound
.exp_not_t2:
                lda #10
                sta miss_t3_timer

.exp_sound:
                ; Play miss sound (same noise burst)
                lda #$80
                sta SID_V3_CTRL
                lda #$10
                sta SID_V3_FREQ_HI
                lda #$81
                sta SID_V3_CTRL
                rts
