; Neon Nexus - Lesson 2: Your Game Entity
; Complete program with positioned player entity
; Assemble with: acme -f cbm -o player.prg complete.s

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
        
game_loop:
        jmp game_loop   ; Keep running

setup_arena:
        ; Set up arena colors
        lda #$06        ; Dark blue border
        sta $d020
        lda #$00        ; Black background
        sta $d021
        
        ; Clear screen manually
        lda #$20        ; Space character
        ldx #$00
clear_loop:
        sta $0400,x     ; Screen page 1
        sta $0500,x     ; Screen page 2
        sta $0600,x     ; Screen page 3
        sta $0700,x     ; Screen page 4
        inx
        bne clear_loop
        
        rts

create_player:
        ; Calculate screen position
        jsr calculate_screen_pos
        
        ; Place character at calculated position
        lda #$5a        ; Diamond character
        ldy #$00
        sta ($fb),y     ; Indirect addressing!
        
        ; Calculate color RAM position
        lda #$00
        sta $fd
        lda #$d8        ; High byte for color RAM
        sta $fe
        
        ; Add same Y*40+X offset
        ldy player_y
        beq add_x_color
        
multiply_y_color:
        lda $fd
        clc
        adc #40
        sta $fd
        bcc no_carry_color
        inc $fe
no_carry_color:
        dey
        bne multiply_y_color
        
add_x_color:
        lda $fd
        clc
        adc player_x
        sta $fd
        bcc place_color
        inc $fe
        
place_color:
        ; Set color
        lda #$07        ; Yellow
        ldy #$00
        sta ($fd),y
        
        rts

calculate_screen_pos:
        ; Calculate screen address from player_x and player_y
        ; Formula: $0400 + (Y * 40) + X
        
        ; Start with base screen address
        lda #$00
        sta $fb         ; Low byte
        lda #$04        ; High byte ($0400)
        sta $fc
        
        ; Add Y offset (Y * 40)
        ldy player_y
        beq add_x       ; Skip if Y=0
        
multiply_y:
        ; Add 40 for each row
        lda $fb
        clc
        adc #40
        sta $fb
        bcc no_carry
        inc $fc         ; Handle carry to high byte
no_carry:
        dey
        bne multiply_y
        
add_x:
        ; Add X offset
        lda $fb
        clc
        adc player_x
        sta $fb
        bcc done
        inc $fc
done:
        rts

; Player data (at end to avoid breaking BASIC stub)
player_x:   !byte 20    ; X position (column)
player_y:   !byte 12    ; Y position (row)