; Commodore 64 Keyboard Matrix Test Program
; Find correct matrix positions for Q, O, and P keys
; Test all 64 possible combinations (8 columns × 8 rows)

; Target: Commodore 64
; Assembler: ACME

;===============================================================================
; BASIC STUB - Auto-run our program
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
*=$0810                        ; Start at decimal 2064

main:
        ; Set border to white, background to blue
        lda #$01
        sta $d020
        lda #$06
        sta $d021
        
        ; Clear screen
        jsr clear_screen
        
        ; Display instructions
        jsr display_instructions
        
        ; Start testing
        jsr keyboard_matrix_test
        
        ; Return to BASIC
        rts

;===============================================================================
; KEYBOARD MATRIX TEST
;===============================================================================

keyboard_matrix_test:
        ; Test Q key first
        jsr test_q_key
        
        ; Wait for user to press SPACE
        jsr wait_for_space
        
        ; Test O key
        jsr test_o_key
        
        ; Wait for user to press SPACE
        jsr wait_for_space
        
        ; Test P key
        jsr test_p_key
        
        rts

;===============================================================================
; TEST Q KEY
;===============================================================================

test_q_key:
        ; Clear screen and show Q test header
        jsr clear_screen
        ldx #0
show_q_header:
        lda q_test_header,x
        beq q_header_done
        sta $0400 + 40*1 + 2,x
        inx
        jmp show_q_header
q_header_done:

        ; Display instructions
        ldx #0
show_q_instructions:
        lda q_instructions,x
        beq q_instructions_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp show_q_instructions
q_instructions_done:

        ; Test all 64 combinations
        lda #0
        sta current_column
        sta current_row
        
q_test_loop:
        ; Calculate column mask (bit to clear)
        lda current_column
        tax
        lda column_masks,x
        sta column_mask
        
        ; Calculate row mask (bit to check)
        lda current_row
        tax
        lda row_masks,x
        sta row_mask
        
        ; Test this position
        lda column_mask
        sta $dc00              ; Select column
        lda $dc01              ; Read rows
        and row_mask           ; Check specific row
        beq q_key_found        ; If 0, key is pressed
        
        ; Key not found, try next position
        inc current_row
        lda current_row
        cmp #8
        bne q_test_loop
        
        ; Move to next column
        lda #0
        sta current_row
        inc current_column
        lda current_column
        cmp #8
        bne q_test_loop
        
        ; Key not found in any position
        jmp q_not_found
        
q_key_found:
        ; Display result
        jsr display_q_result
        rts
        
q_not_found:
        ; Display "not found" message
        ldx #0
show_q_not_found:
        lda q_not_found_msg,x
        beq q_not_found_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp show_q_not_found
q_not_found_done:
        rts

;===============================================================================
; TEST O KEY
;===============================================================================

test_o_key:
        ; Clear screen and show O test header
        jsr clear_screen
        ldx #0
show_o_header:
        lda o_test_header,x
        beq o_header_done
        sta $0400 + 40*1 + 2,x
        inx
        jmp show_o_header
o_header_done:

        ; Display instructions
        ldx #0
show_o_instructions:
        lda o_instructions,x
        beq o_instructions_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp show_o_instructions
o_instructions_done:

        ; Test all 64 combinations
        lda #0
        sta current_column
        sta current_row
        
o_test_loop:
        ; Calculate column mask (bit to clear)
        lda current_column
        tax
        lda column_masks,x
        sta column_mask
        
        ; Calculate row mask (bit to check)
        lda current_row
        tax
        lda row_masks,x
        sta row_mask
        
        ; Test this position
        lda column_mask
        sta $dc00              ; Select column
        lda $dc01              ; Read rows
        and row_mask           ; Check specific row
        beq o_key_found        ; If 0, key is pressed
        
        ; Key not found, try next position
        inc current_row
        lda current_row
        cmp #8
        bne o_test_loop
        
        ; Move to next column
        lda #0
        sta current_row
        inc current_column
        lda current_column
        cmp #8
        bne o_test_loop
        
        ; Key not found in any position
        jmp o_not_found
        
o_key_found:
        ; Display result
        jsr display_o_result
        rts
        
o_not_found:
        ; Display "not found" message
        ldx #0
show_o_not_found:
        lda o_not_found_msg,x
        beq o_not_found_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp show_o_not_found
o_not_found_done:
        rts

;===============================================================================
; TEST P KEY
;===============================================================================

test_p_key:
        ; Clear screen and show P test header
        jsr clear_screen
        ldx #0
show_p_header:
        lda p_test_header,x
        beq p_header_done
        sta $0400 + 40*1 + 2,x
        inx
        jmp show_p_header
p_header_done:

        ; Display instructions
        ldx #0
show_p_instructions:
        lda p_instructions,x
        beq p_instructions_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp show_p_instructions
p_instructions_done:

        ; Test all 64 combinations
        lda #0
        sta current_column
        sta current_row
        
p_test_loop:
        ; Calculate column mask (bit to clear)
        lda current_column
        tax
        lda column_masks,x
        sta column_mask
        
        ; Calculate row mask (bit to check)
        lda current_row
        tax
        lda row_masks,x
        sta row_mask
        
        ; Test this position
        lda column_mask
        sta $dc00              ; Select column
        lda $dc01              ; Read rows
        and row_mask           ; Check specific row
        beq p_key_found        ; If 0, key is pressed
        
        ; Key not found, try next position
        inc current_row
        lda current_row
        cmp #8
        bne p_test_loop
        
        ; Move to next column
        lda #0
        sta current_row
        inc current_column
        lda current_column
        cmp #8
        bne p_test_loop
        
        ; Key not found in any position
        jmp p_not_found
        
p_key_found:
        ; Display result
        jsr display_p_result
        rts
        
p_not_found:
        ; Display "not found" message
        ldx #0
show_p_not_found:
        lda p_not_found_msg,x
        beq p_not_found_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp show_p_not_found
p_not_found_done:
        rts

;===============================================================================
; DISPLAY RESULTS
;===============================================================================

display_q_result:
        ; Show "Q FOUND AT:"
        ldx #0
show_q_found:
        lda q_found_msg,x
        beq q_found_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp show_q_found
q_found_done:

        ; Show column number
        lda current_column
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 2
        
        ; Show row number
        lda current_row
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 10
        
        ; Show column mask in hex
        lda column_mask
        jsr display_hex_byte
        sta $0400 + 40*8 + 2
        stx $0400 + 40*8 + 3
        
        ; Show row mask in hex
        lda row_mask
        jsr display_hex_byte
        sta $0400 + 40*8 + 12
        stx $0400 + 40*8 + 13
        
        rts

display_o_result:
        ; Show "O FOUND AT:"
        ldx #0
show_o_found:
        lda o_found_msg,x
        beq o_found_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp show_o_found
o_found_done:

        ; Show column number
        lda current_column
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 2
        
        ; Show row number
        lda current_row
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 10
        
        ; Show column mask in hex
        lda column_mask
        jsr display_hex_byte
        sta $0400 + 40*8 + 2
        stx $0400 + 40*8 + 3
        
        ; Show row mask in hex
        lda row_mask
        jsr display_hex_byte
        sta $0400 + 40*8 + 12
        stx $0400 + 40*8 + 13
        
        rts

display_p_result:
        ; Show "P FOUND AT:"
        ldx #0
show_p_found:
        lda p_found_msg,x
        beq p_found_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp show_p_found
p_found_done:

        ; Show column number
        lda current_column
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 2
        
        ; Show row number
        lda current_row
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 10
        
        ; Show column mask in hex
        lda column_mask
        jsr display_hex_byte
        sta $0400 + 40*8 + 2
        stx $0400 + 40*8 + 3
        
        ; Show row mask in hex
        lda row_mask
        jsr display_hex_byte
        sta $0400 + 40*8 + 12
        stx $0400 + 40*8 + 13
        
        rts

;===============================================================================
; UTILITY FUNCTIONS
;===============================================================================

display_hex_byte:
        ; Convert byte in A to two hex digits
        ; Returns: A = first digit, X = second digit
        pha
        lsr
        lsr
        lsr
        lsr
        jsr hex_to_ascii
        tax
        pla
        and #$0f
        jsr hex_to_ascii
        pha
        txa
        tax
        pla
        rts

hex_to_ascii:
        ; Convert hex digit (0-15) to ASCII
        cmp #10
        bcc hex_digit
        clc
        adc #55                ; A-F
        rts
hex_digit:
        clc
        adc #48                ; 0-9
        rts

wait_for_space:
        ; Wait for SPACE key press
wait_space_loop:
        ; Check SPACE key - Column 4, Row 4
        lda #%11101111         ; Select column 4
        sta $dc00
        lda $dc01
        and #%00010000         ; Check bit 4 (row 4)
        beq space_pressed      ; If 0, space is pressed
        jmp wait_space_loop
        
space_pressed:
        ; Wait for space to be released
wait_space_release:
        lda #%11101111         ; Select column 4
        sta $dc00
        lda $dc01
        and #%00010000         ; Check bit 4 (row 4)
        beq wait_space_release ; If still 0, space still pressed
        
        ; Restore CIA1 Port A
        lda #$ff
        sta $dc00
        rts

clear_screen:
        ldx #0
clear_loop:
        lda #$20               ; Space character
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$01               ; White color
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_loop
        rts

display_instructions:
        ldx #0
show_instructions:
        lda instructions,x
        beq instructions_done
        sta $0400 + 40*1 + 2,x
        inx
        jmp show_instructions
instructions_done:
        rts

;===============================================================================
; DATA TABLES
;===============================================================================

; Column masks (which bit to clear in $DC00)
column_masks:
        !byte %11111110        ; Column 0
        !byte %11111101        ; Column 1
        !byte %11111011        ; Column 2
        !byte %11110111        ; Column 3
        !byte %11101111        ; Column 4
        !byte %11011111        ; Column 5
        !byte %10111111        ; Column 6
        !byte %01111111        ; Column 7

; Row masks (which bit to check in $DC01)
row_masks:
        !byte %00000001        ; Row 0
        !byte %00000010        ; Row 1
        !byte %00000100        ; Row 2
        !byte %00001000        ; Row 3
        !byte %00010000        ; Row 4
        !byte %00100000        ; Row 5
        !byte %01000000        ; Row 6
        !byte %10000000        ; Row 7

;===============================================================================
; TEXT MESSAGES
;===============================================================================

instructions:
        !text "KEYBOARD MATRIX TEST - PRESS SPACE TO CONTINUE"
        !byte 0

q_test_header:
        !text "TESTING Q KEY - HOLD Q AND PRESS SPACE"
        !byte 0

q_instructions:
        !text "1. HOLD DOWN THE Q KEY"
        !byte 0

o_test_header:
        !text "TESTING O KEY - HOLD O AND PRESS SPACE"
        !byte 0

o_instructions:
        !text "1. HOLD DOWN THE O KEY"
        !byte 0

p_test_header:
        !text "TESTING P KEY - HOLD P AND PRESS SPACE"
        !byte 0

p_instructions:
        !text "1. HOLD DOWN THE P KEY"
        !byte 0

q_found_msg:
        !text "Q FOUND AT:"
        !byte 0

o_found_msg:
        !text "O FOUND AT:"
        !byte 0

p_found_msg:
        !text "P FOUND AT:"
        !byte 0

q_not_found_msg:
        !text "Q KEY NOT FOUND - CHECK CONNECTION"
        !byte 0

o_not_found_msg:
        !text "O KEY NOT FOUND - CHECK CONNECTION"
        !byte 0

p_not_found_msg:
        !text "P KEY NOT FOUND - CHECK CONNECTION"
        !byte 0

;===============================================================================
; VARIABLES
;===============================================================================

current_column:
        !byte 0

current_row:
        !byte 0

column_mask:
        !byte 0

row_mask:
        !byte 0

;===============================================================================
; EXPLANATION
;===============================================================================

; This program systematically tests all 64 possible keyboard matrix 
; positions (8 columns × 8 rows) to find where Q, O, and P keys are located.
;
; How it works:
; 1. For each key, it loops through all combinations of column and row
; 2. Sets the appropriate column mask in $DC00
; 3. Reads $DC01 and checks the appropriate row bit
; 4. If the bit is 0 (active low), the key is found at that position
; 5. Displays the results showing column, row, and hex values
;
; Usage:
; 1. Run the program
; 2. When prompted, hold down Q and press SPACE
; 3. Program will find and display Q's matrix position
; 4. Repeat for O and P keys
;
; Results will show:
; - Column number (0-7)
; - Row number (0-7)  
; - Column mask in hex (value to write to $DC00)
; - Row mask in hex (bit to check in $DC01)