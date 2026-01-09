; Calculate screen address for a given row
; Input: A = row number (0-24)
; Output: screen_ptr and colour_ptr set to row start
;
; Key insight: row * 40 requires 16-bit maths!
; Row 17 * 40 = 680, which exceeds 255.
; We use: row * 40 = row * 8 + row * 32

screen_ptr      = $fb           ; Zero page pointer
colour_ptr      = $fd           ; Zero page pointer

calc_row_addr:
                sta temp_row

                ; Start with row in 16-bit format
                sta temp_lo
                lda #0
                sta temp_hi

                ; Shift left 3 times: row * 8
                asl temp_lo         ; Shift low byte
                rol temp_hi         ; Rotate carry into high byte
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi         ; Now temp = row * 8

                ; Save row * 8
                lda temp_lo
                sta save_lo
                lda temp_hi
                sta save_hi

                ; Shift left 2 more times: row * 32
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi         ; Now temp = row * 32

                ; Add row * 8 to get row * 40
                clc
                lda save_lo
                adc temp_lo
                sta temp_lo
                lda save_hi
                adc temp_hi
                sta temp_hi         ; Now temp = row * 40

                ; Add screen base ($0400)
                clc
                lda temp_lo
                adc #<SCREEN
                sta screen_ptr
                lda temp_hi
                adc #>SCREEN
                sta screen_ptr+1

                ; Add colour base ($D800)
                clc
                lda temp_lo
                adc #<COLOUR
                sta colour_ptr
                lda temp_hi
                adc #>COLOUR
                sta colour_ptr+1

                rts

temp_row:       !byte 0
temp_lo:        !byte 0
temp_hi:        !byte 0
save_lo:        !byte 0
save_hi:        !byte 0
