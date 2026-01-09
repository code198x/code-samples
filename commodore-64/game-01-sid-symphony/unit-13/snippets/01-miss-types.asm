; Two types of misses in a rhythm game
;
; 1. IMPLICIT MISS: Note leaves hit zone without being hit
;    Detected in update_notes when note_x < HIT_START
;
; 2. EXPLICIT MISS: Player presses key when no note is there
;    Detected in handle_input when check_hit returns carry clear

; In update_notes - detecting implicit misses:
update_notes:
                ; ... movement code ...

                lda note_x,x
                cmp #HIT_START
                bcs .next_note          ; Still in play

                ; Note left hit zone without being hit - MISS!
                jsr handle_miss
                lda #NOTE_INACTIVE
                sta note_active,x

; In handle_input - detecting explicit misses:
handle_input:
                lda key_x_pressed
                beq .no_x
                lda #1
                sta miss_track          ; Store track for potential miss
                jsr check_hit
                bcc .miss_x             ; No hit - explicit miss
                ; ... hit handling ...
                jmp .no_x
.miss_x:
                jsr handle_explicit_miss

.no_x:
                ; ... repeat for C and V keys ...
