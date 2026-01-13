; ----------------------------------------------------------------------------
; Check Hit - Find a note in the hit zone for the pressed track
; ----------------------------------------------------------------------------
; Input: key_pressed = track number (1-3)
; Output: Carry set if hit found, X = note index
;         Carry clear if no hit
; Side effect: Removes hit note from play

check_hit:
            ldx #0

check_hit_loop:
            ; Check if this note slot is active
            lda note_track,x
            beq check_hit_next  ; Empty slot - skip

            ; Check if note is on the pressed track
            cmp key_pressed
            bne check_hit_next  ; Wrong track - skip

            ; Check if note is in the hit zone
            lda note_col,x
            cmp #HIT_ZONE_MIN
            bcc check_hit_next  ; Too far left - skip
            cmp #HIT_ZONE_MAX+1
            bcs check_hit_next  ; Too far right - skip

            ; HIT! Note is in zone on correct track
            ; Erase the note from screen
            jsr erase_note

            ; Deactivate the note
            lda #0
            sta note_track,x

            ; Return with carry set (hit found)
            sec
            rts

check_hit_next:
            inx
            cpx #MAX_NOTES
            bne check_hit_loop

            ; No hit found - return with carry clear
            clc
            rts
