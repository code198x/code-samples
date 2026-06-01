; ----------------------------------------------------------------------------
; Check Hit - Find note and determine hit quality
; ----------------------------------------------------------------------------
; Input: key_pressed = track number (1-3)
; Output: Carry set if hit, hit_quality set (1=good, 2=perfect)
;         Carry clear if no hit

check_hit:
            ldx #0

check_hit_loop:
            lda note_track,x
            beq check_hit_next

            cmp key_pressed
            bne check_hit_next

            lda note_col,x
            cmp #HIT_ZONE_MIN
            bcc check_hit_next
            cmp #HIT_ZONE_MAX+1
            bcs check_hit_next

            ; HIT! Determine quality based on position
            ; Centre columns (3-4) = perfect, edges (2, 5) = good
            cmp #HIT_ZONE_CENTRE
            bcc hit_good            ; Column 2 = good
            cmp #HIT_ZONE_CENTRE+2
            bcs hit_good            ; Column 5 = good

            ; Perfect hit (columns 3-4)
            lda #2
            sta hit_quality
            jmp hit_found

hit_good:
            ; Good hit (columns 2 or 5)
            lda #1
            sta hit_quality

hit_found:
            jsr erase_note
            lda #0
            sta note_track,x
            sec
            rts

check_hit_next:
            inx
            cpx #MAX_NOTES
            bne check_hit_loop

            lda #0
            sta hit_quality
            clc
            rts
