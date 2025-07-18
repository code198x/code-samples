; Pixel Patrol - Lesson 1: C64 Setup and Display (Simple Version)
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
        !text "pixel patrol - lesson 1"
        !byte 0                ; Null terminator