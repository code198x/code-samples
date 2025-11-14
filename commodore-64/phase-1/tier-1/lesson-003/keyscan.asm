; Keyboard Scanner - Shows actual scan codes for pressed keys
; This will help us find the REAL keyboard matrix values

        * = $0801
        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810

init:
        ; Setup CIA
        lda #$ff
        sta $dc02       ; Port A = output
        lda #$00
        sta $dc03       ; Port B = input

        ; Clear screen
        lda #$93
        jsr $ffd2

        ; Print header
        ldx #$00
phead:  lda header,x
        beq scan_start
        jsr $ffd2
        inx
        jmp phead

scan_start:
        ; Scan all 8 rows
        ldx #$00        ; Row counter

scan_row:
        ; Calculate row mask (bit X = 0, all others = 1)
        ; Row 0=$FE, Row 1=$FD, Row 2=$FB, etc.
        lda #$fe        ; Start with row 0 mask
        cpx #$00        ; Check if row 0
        beq apply_mask  ; If row 0, no rotation needed

        ; Rotate left X times to get mask for row X
        txa             ; Copy row number to A
        tay             ; Y = number of rotations needed
        lda #$fe        ; Reload the mask
        sec             ; Set carry for rotation
make_mask:
        rol             ; Rotate the mask left
        dey             ; Decrement rotation counter
        bne make_mask   ; Continue until Y=0

apply_mask:
        ; Write row mask to $DC00
        sta $dc00
        sta row_mask

        ; Read columns from $DC01
        lda $dc01
        sta col_data

        ; Check if any key pressed in this row
        cmp #$ff
        beq next_row

        ; Key pressed! Print the values
        lda #$0d
        jsr $ffd2       ; Newline

        ; Print "ROW: $"
        ldy #$00
prow:   lda row_msg,y
        beq prow_done
        jsr $ffd2
        iny
        jmp prow

prow_done:
        lda row_mask
        jsr print_hex

        ; Print " COL: $"
        ldy #$00
pcol:   lda col_msg,y
        beq pcol_done
        jsr $ffd2
        iny
        jmp pcol

pcol_done:
        lda col_data
        jsr print_hex

next_row:
        inx
        cpx #$08
        bne scan_row

        jmp scan_start

print_hex:
        pha
        lsr
        lsr
        lsr
        lsr
        jsr print_nib
        pla
        and #$0f
print_nib:
        cmp #$0a
        bcc is_digit
        adc #$06
is_digit:
        adc #$30
        jmp $ffd2

row_mask: !byte $00
col_data: !byte $00

header: !text "KEYBOARD SCANNER", $0d
        !text "PRESS KEYS...", $0d, $00

row_msg: !text "ROW: $", $00
col_msg: !text " COL: $", $00
