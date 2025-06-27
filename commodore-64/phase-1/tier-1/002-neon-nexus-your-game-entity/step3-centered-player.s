; Neon Nexus - Lesson 2: Your Game Entity
; Step 3: Player centered on screen
; Assemble with: acme -f cbm -o player.prg step3-centered-player.s

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
        jsr create_player
        rts

setup_arena:
        ; Set up arena colors
        lda #$06        ; Dark blue border
        sta $d020
        lda #$00        ; Black background
        sta $d021
        
        ; Clear screen
        lda #$93
        jsr $ffd2
        
        rts

create_player:
        ; Put player at center of screen
        ; Center = row 12, column 20
        ; Position = (12 * 40) + 20 = 480 + 20 = 500
        
        lda #$5a        ; Diamond character
        sta $0400 + 500 ; Center position
        
        ; Make it bright yellow
        lda #$07        ; Yellow color
        sta $d800 + 500 ; Color at same position
        
        rts