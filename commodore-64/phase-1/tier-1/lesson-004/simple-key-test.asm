; Simple C64 Keyboard Matrix Scanner
; Press any key to see its matrix position
; Target: Commodore 64, Assembler: ACME

;===============================================================================
; BASIC STUB
;===============================================================================
*=$0801
        !word +                ; Next line address
        !word 10               ; Line number 10
        !byte $9e              ; SYS token
        !text " 2064"          ; Space + address as text
        !byte 0                ; End of line
+       !word 0                ; End of BASIC program

;===============================================================================
; MAIN PROGRAM
;===============================================================================
*=$0810

main:
        ; Set up screen
        lda #$01               ; White border
        sta $d020
        lda #$00               ; Black background
        sta $d021
        
        ; Clear screen
        jsr clear_screen
        
        ; Display header
        ldx #0
header_loop:
        lda header_text,x
        beq header_done
        sta $0400 + 40*2 + 2,x
        inx
        jmp header_loop
header_done:

        ; Display instructions
        ldx #0
inst_loop:
        lda inst_text,x
        beq inst_done
        sta $0400 + 40*4 + 2,x
        inx
        jmp inst_loop
inst_done:

main_loop:
        ; Test all matrix positions
        jsr scan_keyboard
        
        ; Small delay
        ldx #$ff
delay_loop:
        dex
        bne delay_loop
        
        jmp main_loop

;===============================================================================
; KEYBOARD SCANNER
;===============================================================================

scan_keyboard:
        ; Test each column
        ldx #0                  ; Column counter
test_column:
        ; Calculate column mask
        lda #$01
        tay                     ; Y = bit to shift
        cpx #0
        beq got_mask
shift_mask:
        asl
        dey
        bne shift_mask
got_mask:
        eor #$ff                ; Invert for CIA
        sta $dc00               ; Select column
        
        ; Read row data
        lda $dc01
        sta current_row_data
        
        ; Test each row bit
        ldy #0                  ; Row counter
test_row:
        lda current_row_data
        and row_masks,y
        bne next_row            ; Bit is 1 = not pressed
        
        ; Key found! Display position
        stx found_col
        sty found_row
        jsr display_key_info
        
next_row:
        iny
        cpy #8
        bne test_row
        
        inx
        cpx #8
        bne test_column
        
        ; Restore CIA
        lda #$ff
        sta $dc00
        
        rts

;===============================================================================
; DISPLAY ROUTINES
;===============================================================================

display_key_info:
        ; Clear old data
        ldx #0
clear_old:
        lda #$20                ; Space
        sta $0400 + 40*8 + 2,x
        sta $0400 + 40*10 + 2,x
        sta $0400 + 40*12 + 2,x
        inx
        cpx #35
        bne clear_old
        
        ; Display "COLUMN:"
        ldx #0
col_label_loop:
        lda col_label,x
        beq col_label_done
        sta $0400 + 40*8 + 2,x
        inx
        jmp col_label_loop
col_label_done:
        
        ; Display column number
        lda found_col
        clc
        adc #48                 ; Convert to ASCII
        sta $0400 + 40*8 + 10
        
        ; Display "ROW:"
        ldx #0
row_label_loop:
        lda row_label,x
        beq row_label_done
        sta $0400 + 40*10 + 2,x
        inx
        jmp row_label_loop
row_label_done:
        
        ; Display row number
        lda found_row
        clc
        adc #48                 ; Convert to ASCII
        sta $0400 + 40*10 + 8
        
        ; Display "MASKS:"
        ldx #0
mask_label_loop:
        lda mask_label,x
        beq mask_label_done
        sta $0400 + 40*12 + 2,x
        inx
        jmp mask_label_loop
mask_label_done:
        
        ; Display column mask ($DC00)
        lda found_col
        tax
        lda #$01
shift_col_mask:
        cpx #0
        beq got_col_mask
        asl
        dex
        jmp shift_col_mask
got_col_mask:
        eor #$ff
        jsr display_hex_byte
        
        ; Display comma
        lda #44                 ; Comma
        sta $0400 + 40*12 + 12
        
        ; Display row mask ($DC01)
        lda found_row
        tax
        lda row_masks,x
        sta $0400 + 40*12 + 14
        ldx #14
        jsr display_hex_byte
        
        rts

display_hex_byte:
        ; Display A as hex at current position
        pha
        lsr
        lsr
        lsr
        lsr
        jsr hex_digit
        sta $0400 + 40*12 + 9
        pla
        and #$0f
        jsr hex_digit
        sta $0400 + 40*12 + 10
        rts

hex_digit:
        cmp #10
        bcc is_number
        clc
        adc #7                  ; A-F
is_number:
        clc
        adc #48                 ; 0-9
        rts

clear_screen:
        ldx #0
clear_loop:
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$01
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_loop
        rts

;===============================================================================
; DATA
;===============================================================================

header_text:
        !byte 3,54,52,32,11,5,25,2,15,1,18,4,32,13,1,20,18,9,24,32,19,3,1,14,14,5,18
        !byte 0

inst_text:
        !byte 16,18,5,19,19,32,1,14,25,32,11,5,25,32,20,15,32,19,5,5,32,9,20,19,32,16,15,19,9,20,9,15,14
        !byte 0

col_label:
        !byte 3,15,12,21,13,14,58,32
        !byte 0

row_label:
        !byte 18,15,23,58,32
        !byte 0

mask_label:
        !byte 13,1,19,11,19,58,32,36
        !byte 0

row_masks:
        !byte $01, $02, $04, $08, $10, $20, $40, $80

; Variables
found_col:
        !byte 0
found_row:
        !byte 0
current_row_data:
        !byte 0