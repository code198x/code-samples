; ----------------------------------------------------------------------------
; Update Notes - Now detects misses
; ----------------------------------------------------------------------------

update_notes:
            ldx #0

update_loop:
            lda note_track,x
            beq update_next

            jsr erase_note

            dec note_col,x
            lda note_col,x
            cmp #1
            bcc update_miss     ; Note passed hit zone - MISS!

            jsr draw_note
            jmp update_next

update_miss:
            ; Note fell through - record the miss
            lda note_track,x
            sta miss_track      ; Save which track for flash
            lda #0
            sta note_track,x    ; Deactivate note
            jsr handle_miss     ; Process the miss

update_next:
            inx
            cpx #MAX_NOTES
            bne update_loop
            rts

; ----------------------------------------------------------------------------
; Handle Miss - Negative feedback for missed notes
; ----------------------------------------------------------------------------

handle_miss:
            ; Increment miss counter
            inc miss_count

            ; Play miss sound (harsh noise burst)
            jsr play_miss_sound

            ; Red border flash
            lda #MISS_COL
            sta BORDER
            lda #8              ; Flash for 8 frames
            sta border_flash

            ; Update miss display
            jsr display_misses

            rts
