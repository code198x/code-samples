; Pixel Patrol - Lesson 4: Basic Sprite Movement
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-004

; Target: Commodore 64
; Assembler: ACME
; Outcome: Sprite moves with joystick input

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
        jsr clear_screen
        
        ; Display title
        ldx #0
display_title:
        lda title_text,x
        beq title_done
        sta $0400 + 40*1 + 8,x
        inx
        jmp display_title
title_done:

        ; Initialize sprite position
        lda #160               ; X position (center)
        sta sprite_x
        lda #150               ; Y position (center)
        sta sprite_y
        
        ; Set up sprite
        jsr setup_sprite
        
        ; Update sprite position
        jsr update_sprite_position
        
        ; Enable sprite
        lda #$01               ; Enable sprite 0
        sta $d015              ; VIC-II sprite enable register
        
        ; Set sprite color
        lda #$07               ; Yellow
        sta $d027              ; VIC-II sprite 0 color register

        ; Main game loop
game_loop:
        jsr read_joystick      ; Read joystick input
        jsr move_sprite        ; Move sprite based on input
        jsr update_sprite_position ; Update hardware position
        jsr wait_frame         ; Wait for next frame
        jmp game_loop          ; Continue forever

;===============================================================================
; INPUT HANDLING
;===============================================================================

read_joystick:
        ; Read joystick port 2 (CIA1 Port A)
        lda $dc00              ; Read CIA1 Port A
        sta joystick_state     ; Store current state
        
        ; Check for keyboard input (QAOP)
        jsr check_keyboard_input
        
        rts

;===============================================================================
; SPRITE MOVEMENT
;===============================================================================

move_sprite:
        ; Check Up (bit 0 clear means pressed)
        lda joystick_state
        and #$01
        bne check_down
        
        ; Move up
        lda sprite_y
        sec
        sbc #2                 ; Move 2 pixels up
        sta sprite_y
        
check_down:
        ; Check Down (bit 1 clear means pressed)
        lda joystick_state
        and #$02
        bne check_left
        
        ; Move down
        lda sprite_y
        clc
        adc #2                 ; Move 2 pixels down
        sta sprite_y
        
check_left:
        ; Check Left (bit 2 clear means pressed)
        lda joystick_state
        and #$04
        bne check_right
        
        ; Move left
        lda sprite_x
        sec
        sbc #2                 ; Move 2 pixels left
        sta sprite_x
        
check_right:
        ; Check Right (bit 3 clear means pressed)
        lda joystick_state
        and #$08
        bne move_done
        
        ; Move right
        lda sprite_x
        clc
        adc #2                 ; Move 2 pixels right
        sta sprite_x
        
move_done:
        rts

;===============================================================================
; SPRITE HANDLING
;===============================================================================

update_sprite_position:
        ; Set sprite X position
        lda sprite_x
        sta $d000              ; Sprite 0 X position
        
        ; Set sprite Y position
        lda sprite_y
        sta $d001              ; Sprite 0 Y position
        
        ; Handle X MSB if needed
        lda sprite_x
        cmp #255
        bcc no_msb
        
        ; Set X MSB
        lda $d010
        ora #$01
        sta $d010
        jmp msb_done
        
no_msb:
        ; Clear X MSB
        lda $d010
        and #$fe
        sta $d010
        
msb_done:
        rts

setup_sprite:
        ; Set sprite pointer
        lda #$0d               ; Use block 13
        sta $07f8              ; Sprite 0 pointer
        
        ; Copy sprite data
        ldx #0
copy_sprite:
        lda sprite_data,x
        sta $0340,x            ; Block 13 = $0340
        inx
        cpx #63
        bne copy_sprite
        
        rts

;===============================================================================
; UTILITY SUBROUTINES
;===============================================================================

check_keyboard_input:
        ; Check Q key (Up) - Row 7, Bit 1
        lda #%01111111
        sta $dc00
        lda $dc01
        and #%00000010
        bne not_q
        lda joystick_state
        and #%11111110
        sta joystick_state
not_q:
        
        ; Check A key (Down) - Row 1, Bit 5
        lda #%11111101
        sta $dc00
        lda $dc01
        and #%00100000
        bne not_a
        lda joystick_state
        and #%11111101
        sta joystick_state
not_a:
        
        ; Check O key (Left) - Row 4, Bit 1
        lda #%11101111
        sta $dc00
        lda $dc01
        and #%00000010
        bne not_o
        lda joystick_state
        and #%11111011
        sta joystick_state
not_o:
        
        ; Check P key (Right) - Row 5, Bit 6
        lda #%11011111
        sta $dc00
        lda $dc01
        and #%01000000
        bne not_p
        lda joystick_state
        and #%11110111
        sta joystick_state
not_p:
        
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

wait_frame:
        ; Wait for raster line 250
wait_raster:
        lda $d012
        cmp #250
        bne wait_raster
        rts

;===============================================================================
; DATA
;===============================================================================

title_text:
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,52
        !byte 0

sprite_data:
        ; Simple ball sprite
        !byte %00000000, %01111110, %00000000
        !byte %00000001, %11111111, %10000000
        !byte %00000011, %11111111, %11000000
        !byte %00000111, %11111111, %11100000
        !byte %00001111, %11111111, %11110000
        !byte %00011111, %11111111, %11111000
        !byte %00011111, %11111111, %11111000
        !byte %00111111, %11111111, %11111100
        !byte %00111111, %11111111, %11111100
        !byte %01111111, %11111111, %11111110
        !byte %01111111, %11111111, %11111110
        !byte %01111111, %11111111, %11111110
        !byte %01111111, %11111111, %11111110
        !byte %01111111, %11111111, %11111110
        !byte %01111111, %11111111, %11111110
        !byte %00111111, %11111111, %11111100
        !byte %00111111, %11111111, %11111100
        !byte %00011111, %11111111, %11111000
        !byte %00011111, %11111111, %11111000
        !byte %00001111, %11111111, %11110000
        !byte %00000111, %11111111, %11100000
        !byte %00000000, %00000000, %00000000

; Variables
joystick_state:
        !byte $ff
        
sprite_x:
        !byte 0
        
sprite_y:
        !byte 0

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates basic sprite movement:
;
; 1. SPRITE POSITIONING: Direct pixel-based movement
;    - sprite_x and sprite_y variables track position
;    - Movement by 2 pixels per frame
;    - No grid constraints yet
;    
; 2. JOYSTICK RESPONSE: Immediate movement on input
;    - Check each direction bit
;    - Move sprite directly
;    - Simple and responsive
;    
; 3. CONTINUOUS MOVEMENT: Sprite moves while joystick held
;    - No movement state machine
;    - Direct position updates
;    - Foundation for future enhancements
;
; LEARNING OBJECTIVES ACHIEVED:
; - Understand basic sprite movement
; - Learn joystick-to-movement mapping  
; - Implement pixel-based positioning
; - Create responsive controls