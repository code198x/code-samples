check_song:
            lda song_playing
            beq +                   ; Song ended

            dec next_note_timer
            bne +                   ; Not time yet

            ; Time! Read track and spawn note
            ldy #$01
            lda (song_ptr),y
            jsr spawn_note_on_track

            ; Advance pointer by 2
            clc
            lda song_ptr
            adc #$02
            sta song_ptr
            bcc ++
            inc song_ptr + 1
++
            ; Read next delta
            ldy #$00
            lda (song_ptr),y
            beq +++                 ; 0 = end marker
            sta next_note_timer
+           rts

+++         ; Song ended
            lda #$00
            sta song_playing
            rts
