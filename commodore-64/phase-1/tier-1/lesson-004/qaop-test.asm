; QAOP Key Test Program
; Simple test to find correct matrix positions
; Target: Commodore 64, Assembler: ACME

;===============================================================================
; BASIC STUB
;===============================================================================
*=$0801
        !word +                
        !word 10               
        !byte $9e              
        !text " 2064"          
        !byte 0                
+       !word 0                

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
        
        ; Display simple instructions
        lda #17                ; Q
        sta $0400 + 40*5 + 10
        lda #32                ; Space
        sta $0400 + 40*5 + 11
        lda #45                ; =
        sta $0400 + 40*5 + 12
        lda #32                ; Space
        sta $0400 + 40*5 + 13
        lda #21                ; U
        sta $0400 + 40*5 + 14
        lda #16                ; P
        sta $0400 + 40*5 + 15
        
        lda #1                 ; A
        sta $0400 + 40*7 + 10
        lda #32                ; Space
        sta $0400 + 40*7 + 11
        lda #45                ; =
        sta $0400 + 40*7 + 12
        lda #32                ; Space
        sta $0400 + 40*7 + 13
        lda #4                 ; D
        sta $0400 + 40*7 + 14
        lda #15                ; O
        sta $0400 + 40*7 + 15
        lda #23                ; W
        sta $0400 + 40*7 + 16
        lda #14                ; N
        sta $0400 + 40*7 + 17

main_loop:
        ; Test all possible combinations for Q, O, P
        jsr test_qaop_keys
        jmp main_loop

;===============================================================================
; KEY TESTING
;===============================================================================

test_qaop_keys:
        ; Test Q key - try different positions
        ; Position 1: Column 7, Row 6 (common position for Q)
        lda #%01111111         ; Select column 7
        sta $dc00
        lda $dc01
        and #%01000000         ; Check row 6
        bne not_q1
        ; Q found at 7,6 - show on screen
        lda #49                ; "1"
        sta $0400 + 40*10 + 10
        jmp test_o
not_q1:
        
        ; Position 2: Column 7, Row 1
        lda #%01111111         ; Select column 7  
        sta $dc00
        lda $dc01
        and #%00000010         ; Check row 1
        bne not_q2
        ; Q found at 7,1 - show on screen
        lda #50                ; "2"
        sta $0400 + 40*10 + 10
        jmp test_o
not_q2:
        
        ; Position 3: Column 7, Row 7
        lda #%01111111         ; Select column 7
        sta $dc00
        lda $dc01
        and #%10000000         ; Check row 7
        bne not_q3
        ; Q found at 7,7 - show on screen
        lda #51                ; "3"
        sta $0400 + 40*10 + 10
        jmp test_o
not_q3:

test_o:
        ; Test O key - try different positions
        ; Position 1: Column 6, Row 6
        lda #%10111111         ; Select column 6
        sta $dc00
        lda $dc01
        and #%01000000         ; Check row 6
        bne not_o1
        ; O found at 6,6 - show on screen
        lda #49                ; "1"
        sta $0400 + 40*12 + 10
        jmp test_p
not_o1:
        
        ; Position 2: Column 6, Row 1
        lda #%10111111         ; Select column 6
        sta $dc00
        lda $dc01
        and #%00000010         ; Check row 1
        bne not_o2
        ; O found at 6,1 - show on screen
        lda #50                ; "2"
        sta $0400 + 40*12 + 10
        jmp test_p
not_o2:
        
        ; Position 3: Column 6, Row 4
        lda #%10111111         ; Select column 6
        sta $dc00
        lda $dc01
        and #%00010000         ; Check row 4
        bne not_o3
        ; O found at 6,4 - show on screen
        lda #51                ; "3"
        sta $0400 + 40*12 + 10
        jmp test_p
not_o3:

test_p:
        ; Test P key - try different positions
        ; Position 1: Column 5, Row 6
        lda #%11011111         ; Select column 5
        sta $dc00
        lda $dc01
        and #%01000000         ; Check row 6
        bne not_p1
        ; P found at 5,6 - show on screen
        lda #49                ; "1"
        sta $0400 + 40*14 + 10
        jmp test_done
not_p1:
        
        ; Position 2: Column 5, Row 1
        lda #%11011111         ; Select column 5
        sta $dc00
        lda $dc01
        and #%00000010         ; Check row 1
        bne not_p2
        ; P found at 5,1 - show on screen
        lda #50                ; "2"
        sta $0400 + 40*14 + 10
        jmp test_done
not_p2:
        
        ; Position 3: Column 5, Row 5
        lda #%11011111         ; Select column 5
        sta $dc00
        lda $dc01
        and #%00100000         ; Check row 5
        bne not_p3
        ; P found at 5,5 - show on screen
        lda #51                ; "3"
        sta $0400 + 40*14 + 10
        jmp test_done
not_p3:

test_done:
        ; Restore CIA
        lda #$ff
        sta $dc00
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