; Neon Nexus - Lesson 1: Your First Game World
; Complete program with arena setup and ready indicator
; Assemble with: acme -f cbm -o neon1.prg complete.s

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
        jsr setup_arena
        jsr show_ready
        rts

setup_arena:
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

show_ready:
        ; Put a star in the top-left corner
        lda #$2a        ; Star character
        sta $0400       ; Screen memory start
        
        ; Make it white
        lda #$01        ; White color
        sta $d800       ; Color RAM start
        
        rts