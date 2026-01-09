; Check if song data triggers a new note this beat
;
; Called every frame, but only spawns on new beats (frame_counter = 0)
; Advances song_position when a note is spawned

check_spawn_notes:
                ; Only check on new beat
                lda frame_counter
                bne .no_spawn

                ; Check if current beat matches next song event
                ldx song_position
                lda song_beats,x
                cmp #END_MARKER
                beq .no_spawn       ; End of song

                cmp beat_counter
                bne .no_spawn       ; Not time yet

                ; Time to spawn! Get track and note value
                lda song_tracks,x
                sta spawn_track
                lda song_notes,x
                sta spawn_note_val

                ; Advance song position
                inc song_position

                ; Spawn the note
                jsr spawn_note

.no_spawn:      rts
