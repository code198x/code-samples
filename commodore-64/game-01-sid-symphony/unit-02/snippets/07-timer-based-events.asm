; Spawn timer
            dec spawn_timer
            bne .no_spawn
            lda #SPAWN_INTERVAL
            sta spawn_timer
            jsr spawn_note
.no_spawn:

            ; Move timer
            dec move_timer
            bne .no_move
            lda #NOTE_SPEED
            sta move_timer
            jsr move_notes
.no_move:
