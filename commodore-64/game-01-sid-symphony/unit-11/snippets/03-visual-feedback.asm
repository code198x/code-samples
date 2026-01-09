; Visual feedback when keys are pressed
;
; Flash the hit zone briefly to confirm input was registered.
; Uses a timer that counts down each frame.

flash_t1_timer: !byte 0         ; Track 1 flash countdown
flash_t2_timer: !byte 0
flash_t3_timer: !byte 0

handle_input:
                ; Check X key (track 1)
                lda key_x_pressed
                beq .no_x
                lda #10                 ; Flash for 10 frames
                sta flash_t1_timer

.no_x:
                ; Check C key (track 2)
                lda key_c_pressed
                beq .no_c
                lda #10
                sta flash_t2_timer

.no_c:
                ; Check V key (track 3)
                lda key_v_pressed
                beq .no_v
                lda #10
                sta flash_t3_timer

.no_v:          rts

; In draw_tracks, check timers and use brighter colour if flashing:
;   lda flash_t1_timer
;   beq .normal_colour
;   dec flash_t1_timer
;   lda #COL_WHITE      ; Flash colour
;   jmp .draw_hitzone
; .normal_colour:
;   lda #COL_CYAN       ; Normal colour
