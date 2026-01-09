; Restore hit zone colours with priority
;
; Priority order (highest to lowest):
;   1. Hit flash (white) - player successfully hit a note
;   2. Miss flash (red) - player missed a note
;   3. Normal colour - no active flash

restore_hitzones:
                ; Track 1
                lda flash_t1_timer      ; Hit flash active?
                beq .t1_check_miss
                dec flash_t1_timer
                lda #TRACK1_ROW
                ldy #COL_WHITE          ; Hit = white
                jsr set_hitzone_colour
                jmp .check_t2

.t1_check_miss:
                lda miss_t1_timer       ; Miss flash active?
                beq .t1_normal
                dec miss_t1_timer
                lda #TRACK1_ROW
                ldy #COL_RED            ; Miss = red
                jsr set_hitzone_colour
                jmp .check_t2

.t1_normal:
                lda #TRACK1_ROW
                ldy #COL_CYAN           ; Normal track colour
                jsr set_hitzone_colour

.check_t2:
                ; ... repeat for tracks 2 and 3 ...

; Helper: set all hit zone cells to the specified colour
set_hitzone_colour:
                sty flash_colour
                jsr calc_row_addr       ; Get screen/colour pointers
                ldy #HIT_START
.loop:
                lda flash_colour
                sta (colour_ptr),y
                iny
                cpy #HIT_END
                bne .loop
                rts
