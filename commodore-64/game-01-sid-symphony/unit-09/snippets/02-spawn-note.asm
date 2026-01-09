; Spawn a new note - find free slot and initialise it
;
; Input: spawn_track (1-3), spawn_note_val
; Output: New note in first available slot

SPAWN_COLUMN    = 39            ; Notes spawn at right edge

spawn_note:
                ; Find a free slot in active notes
                ldx #0
.find_slot:
                lda note_active,x
                beq .found_slot     ; Found inactive slot
                inx
                cpx #MAX_NOTES
                bne .find_slot
                rts                 ; No free slots, skip this note

.found_slot:
                ; Activate this slot
                lda #NOTE_ACTIVE
                sta note_active,x

                ; Set position to right edge
                lda #SPAWN_COLUMN
                sta note_x,x

                ; Set track
                lda spawn_track
                sta note_track,x

                ; Set note value (for later sound)
                lda spawn_note_val
                sta note_value,x

                rts
