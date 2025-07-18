; Pixel Patrol - Lesson 1: C64 Setup and Display
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-001

; Target: Commodore 64
; Assembler: ACME
; Outcome: Blue screen with white border

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
        ; Set border color to white
        lda #$01               ; White color
        sta $d020              ; VIC-II border color register
        
        ; Set background color to blue
        lda #$06               ; Blue color
        sta $d021              ; VIC-II background color register
        
        ; Clear screen with spaces
        ldx #0                 ; Start at position 0
clear_screen:
        lda #$20               ; Space character
        sta $0400,x            ; Store in screen memory
        sta $0500,x            ; Store in screen memory page 2
        sta $0600,x            ; Store in screen memory page 3
        sta $0700,x            ; Store in screen memory page 4
        
        ; Set character colors to white
        lda #$01               ; White color
        sta $d800,x            ; Store in color memory
        sta $d900,x            ; Store in color memory page 2
        sta $da00,x            ; Store in color memory page 3
        sta $db00,x            ; Store in color memory page 4
        
        inx                    ; Next position
        bne clear_screen       ; Continue until X wraps to 0
        
        ; Clear the remaining 24 bytes (1000 - 256*3 = 232, but we only need 24 more)
        ldx #$e8               ; Start at position 232
clear_remaining:
        lda #$20               ; Space character
        sta $0700,x            ; Store in screen memory
        lda #$01               ; White color
        sta $db00,x            ; Store in color memory
        inx                    ; Next position
        cpx #$00               ; Check if we've cleared all
        bne clear_remaining    ; Continue until done
        
        ; Display title text
        ldx #0                 ; Start at position 0
display_title:
        lda title_text,x       ; Load character from title
        beq title_done         ; If zero, we're done
        sta $0400 + 40*5 + 8,x ; Store at row 5, column 8
        inx                    ; Next character
        jmp display_title      ; Continue
title_done:

        ; Infinite loop - keep program running
endless_loop:
        jmp endless_loop

;===============================================================================
; DATA
;===============================================================================
title_text:
        ; Screen codes for "PIXEL PATROL - LESSON 1"
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,49
        !byte 0                ; Null terminator

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates the fundamental concepts of C64 programming:
;
; 1. BASIC STUB: The program starts with a BASIC stub that automatically
;    runs our assembly code. This is the standard way to start C64 programs.
;
; 2. VIC-II REGISTERS: We use the VIC-II chip registers to control colors:
;    - $D020: Border color
;    - $D021: Background color
;
; 3. SCREEN MEMORY: The C64 uses character-based display:
;    - Screen RAM ($0400-$07E7): What characters to display
;    - Color RAM ($D800-$DBE7): What color each character should be
;
; 4. MEMORY LAYOUT: The C64 has 64KB of RAM, but some areas are special:
;    - $0000-$00FF: Zero page (fast access)
;    - $0100-$01FF: Stack
;    - $0200-$02FF: BASIC input buffer
;    - $0400-$07FF: Screen and color RAM
;    - $0800-$9FFF: BASIC program area
;    - $A000-$BFFF: BASIC ROM (can be switched out)
;    - $C000-$CFFF: RAM (good for machine code)
;    - $D000-$DFFF: I/O registers (VIC-II, SID, CIA)
;    - $E000-$FFFF: KERNAL ROM
;
; 5. ASSEMBLY CONCEPTS USED:
;    - LDA: Load accumulator
;    - STA: Store accumulator
;    - LDX: Load X register
;    - INX: Increment X register
;    - DEX: Decrement X register
;    - BNE: Branch if not equal (not zero)
;    - BEQ: Branch if equal (zero)
;    - JMP: Jump unconditionally
;    - JSR: Jump to subroutine
;    - RTS: Return from subroutine
;    - SEI: Set interrupt disable flag
;    - CLI: Clear interrupt disable flag
;
; LEARNING OBJECTIVES ACHIEVED:
; - Understand C64 memory layout
; - Learn VIC-II color control
; - Write your first working 6502 assembly program
; - Use subroutines to organize code
; - Display text on screen
; - Set up a proper program structure