; Neon Nexus - Lesson 1: Your First Game World  
; Step 6: BASIC area with proper stub for RUN command
; Assemble with: acme -f cbm -o neon1.prg step6-basic-stub.s

*= $0801

; BASIC stub: 10 SYS 2061
!word next_line
!word 10
!byte $9e
!text "2061"
!byte 0
next_line:
!word 0

; Start of our program
start:
        ; Set border color to dark blue
        lda #$06     
        sta $d020
        
        ; Set background color to black
        lda #$00
        sta $d021
        
        ; Clear the screen
        lda #$93
        jsr $ffd2
        
        rts