; Move all active notes left (every MOVE_DELAY frames)
;
; Notes move one column per update. Moving every frame would be
; too fast, so we use a delay counter.

MOVE_DELAY      = 3             ; Move notes every 3 frames

update_notes:
                ; Only move notes every MOVE_DELAY frames
                inc move_counter
                lda move_counter
                cmp #MOVE_DELAY
                bcc .no_move
                lda #0
                sta move_counter

                ldx #0

.update_loop:
                lda note_active,x
                beq .next_note          ; Skip inactive

                ; Erase note at current position
                stx temp_note_idx
                jsr erase_note

                ; Move note left
                ldx temp_note_idx
                dec note_x,x

                ; Check if note has passed the hit zone
                lda note_x,x
                cmp #HIT_START
                bcs .next_note          ; Still on screen

                ; Note passed hit zone - deactivate it (missed!)
                lda #NOTE_INACTIVE
                sta note_active,x

.next_note:
                inx
                cpx #MAX_NOTES
                bne .update_loop

.no_move:       rts

move_counter:   !byte 0
temp_note_idx:  !byte 0
