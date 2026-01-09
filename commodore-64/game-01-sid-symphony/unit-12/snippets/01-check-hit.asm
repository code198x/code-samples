; Check for hit - find note in hit zone on given track
;
; Input: A = track number (1, 2, or 3)
; Output: Carry set if hit, clear if miss
;
; A "hit" requires:
;   1. An active note
;   2. On the correct track
;   3. In the hit zone (columns HIT_START to HIT_END-1)

HIT_START       = 3             ; Hit zone starts here
HIT_END         = 7             ; Hit zone ends here (exclusive)

check_hit:
                sta hit_track

                ; Search all active notes for one on this track in hit zone
                ldx #0
.search:
                lda note_active,x
                beq .next               ; Skip inactive notes

                ; Check if on correct track
                lda note_track,x
                cmp hit_track
                bne .next               ; Wrong track

                ; Check if in hit zone (columns HIT_START to HIT_END-1)
                lda note_x,x
                cmp #HIT_START
                bcc .next               ; Too far left (x < 3)
                cmp #HIT_END
                bcs .next               ; Too far right (x >= 7)

                ; HIT! This note matches
                stx hit_note_idx
                jsr play_hit_note
                jsr add_score

                ; Deactivate the note (remove from play)
                ldx hit_note_idx
                lda #0
                sta note_active,x

                sec                     ; Carry SET = hit found
                rts

.next:
                inx
                cpx #MAX_NOTES
                bne .search

                clc                     ; Carry CLEAR = no hit
                rts
