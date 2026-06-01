; Move all active notes left by one column each frame
; Notes that scroll past column 1 are deactivated

update_notes:
            ldx #0

update_loop:
            lda note_track,x
            beq update_next     ; Skip inactive notes (track = 0)

            jsr erase_note      ; Remove from old position

            dec note_col,x      ; Move left one column
            lda note_col,x
            cmp #1
            bcc update_deactivate  ; Scrolled off left edge?

            jsr draw_note       ; Draw at new position
            jmp update_next

update_deactivate:
            lda #0
            sta note_track,x    ; Mark as inactive

update_next:
            inx
            cpx #MAX_NOTES
            bne update_loop
            rts
