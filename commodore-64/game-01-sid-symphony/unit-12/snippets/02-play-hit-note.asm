; Play hit note on SID
;
; Uses the note_value to look up frequency in freq_table.
; Plays on the correct voice based on track.

play_hit_note:
                ldx hit_note_idx
                lda note_value,x        ; Get note frequency index
                asl                     ; *2 for word table lookup
                tax

                lda hit_track
                cmp #1
                bne .not_v1

                ; Voice 1 (track 1)
                lda freq_table,x
                sta SID_V1_FREQ_LO
                lda freq_table+1,x
                sta SID_V1_FREQ_HI
                lda #$41                ; Pulse wave, gate on
                sta SID_V1_CTRL
                rts

.not_v1:        cmp #2
                bne .not_v2

                ; Voice 2 (track 2)
                lda freq_table,x
                sta SID_V2_FREQ_LO
                lda freq_table+1,x
                sta SID_V2_FREQ_HI
                lda #$41
                sta SID_V2_CTRL
                rts

.not_v2:
                ; Voice 3 (track 3)
                lda freq_table,x
                sta SID_V3_FREQ_LO
                lda freq_table+1,x
                sta SID_V3_FREQ_HI
                lda #$41
                sta SID_V3_CTRL
                rts
