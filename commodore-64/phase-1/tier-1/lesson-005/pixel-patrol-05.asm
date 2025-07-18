; Pixel Patrol - Lesson 5: Grid Position System
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-005

; Target: Commodore 64
; Assembler: ACME
; Outcome: Internal grid tracking system

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
; CONSTANTS
;===============================================================================
; Grid dimensions
GRID_WIDTH = 8                 ; 8 columns
GRID_HEIGHT = 6                ; 6 rows

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

        ; Display grid info
        jsr display_grid_info

        ; Initialize sprite position (pixels)
        lda #160               ; X position (center)
        sta sprite_x
        lda #150               ; Y position (center)
        sta sprite_y
        
        ; Initialize grid position
        lda #4                 ; Grid X = 4 (center of 8 columns)
        sta grid_x
        lda #3                 ; Grid Y = 3 (center of 6 rows)
        sta grid_y
        
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
        jsr move_sprite        ; Move sprite (pixels)
        jsr calculate_grid_position ; Update grid position
        jsr update_sprite_position ; Update hardware position
        jsr display_current_position ; Show grid position
        jsr wait_frame         ; Wait for next frame
        jmp game_loop          ; Continue forever

;===============================================================================
; GRID POSITION SYSTEM
;===============================================================================

calculate_grid_position:
        ; Calculate grid X from sprite X
        ; grid_x = sprite_x / 32
        lda sprite_x
        lsr                    ; Divide by 2
        lsr                    ; Divide by 4
        lsr                    ; Divide by 8
        lsr                    ; Divide by 16
        lsr                    ; Divide by 32
        sta grid_x
        
        ; Calculate grid Y from sprite Y
        ; grid_y = (sprite_y - 50) / 32
        lda sprite_y
        sec
        sbc #50                ; Subtract Y offset
        lsr                    ; Divide by 2
        lsr                    ; Divide by 4
        lsr                    ; Divide by 8
        lsr                    ; Divide by 16
        lsr                    ; Divide by 32
        sta grid_y
        
        rts

display_grid_info:
        ; Display "GRID: 8x6"
        ldx #0
display_grid_text:
        lda grid_info_text,x
        beq grid_info_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp display_grid_text
grid_info_done:
        rts

display_current_position:
        ; Display "POS: X,Y"
        ldx #0
display_pos_label:
        lda pos_label,x
        beq pos_label_done
        sta $0400 + 40*5 + 2,x
        inx
        jmp display_pos_label
pos_label_done:

        ; Display grid X
        lda grid_x
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*5 + 7
        
        ; Display comma
        lda #44                ; Comma character
        sta $0400 + 40*5 + 8
        
        ; Display grid Y
        lda grid_y
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*5 + 9
        
        ; Display pixel position for debugging
        ldx #0
display_pixel_label:
        lda pixel_label,x
        beq pixel_label_done
        sta $0400 + 40*7 + 2,x
        inx
        jmp display_pixel_label
pixel_label_done:

        ; Display pixel X (hundreds)
        lda sprite_x
        ldx #0                 ; Count hundreds
count_hundreds:
        cmp #100
        bcc display_hundreds
        sec
        sbc #100
        inx
        jmp count_hundreds
display_hundreds:
        pha                    ; Save remainder
        txa
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 10
        pla
        
        ; Display pixel X (tens)
        ldx #0                 ; Count tens
count_tens:
        cmp #10
        bcc display_tens
        sec
        sbc #10
        inx
        jmp count_tens
display_tens:
        pha                    ; Save remainder
        txa
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 11
        pla
        
        ; Display pixel X (ones)
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 12
        
        ; Display comma
        lda #44                ; Comma character
        sta $0400 + 40*7 + 13
        
        ; Display pixel Y (similar process)
        lda sprite_y
        ldx #0                 ; Count hundreds
count_y_hundreds:
        cmp #100
        bcc display_y_hundreds
        sec
        sbc #100
        inx
        jmp count_y_hundreds
display_y_hundreds:
        pha                    ; Save remainder
        txa
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 14
        pla
        
        ; Display pixel Y (tens)
        ldx #0                 ; Count tens
count_y_tens:
        cmp #10
        bcc display_y_tens
        sec
        sbc #10
        inx
        jmp count_y_tens
display_y_tens:
        pha                    ; Save remainder
        txa
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 15
        pla
        
        ; Display pixel Y (ones)
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*7 + 16
        
        rts

;===============================================================================
; INPUT HANDLING (Same as lesson 4)
;===============================================================================

read_joystick:
        ; Read joystick port 2 (CIA1 Port A)
        lda $dc00              ; Read CIA1 Port A
        sta joystick_state     ; Store current state
        
        ; Check for keyboard input (QAOP)
        jsr check_keyboard_input
        
        rts

;===============================================================================
; SPRITE MOVEMENT (Same as lesson 4)
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
; SPRITE HANDLING (Same as lesson 4)
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
        ; Check Q key (Up) - Row 1, Column 5
        lda #%11111101         ; Write $FD to $DC00
        sta $dc00
        lda $dc01
        and #%00100000         ; Check bit 5
        bne not_q
        lda joystick_state
        and #%11111110         ; Clear joystick up bit
        sta joystick_state
not_q:
        
        ; Check A key (Down) - Row 1, Column 2
        lda #%11111101         ; Write $FD to $DC00
        sta $dc00
        lda $dc01
        and #%00000100         ; Check bit 2
        bne not_a
        lda joystick_state
        and #%11111101         ; Clear joystick down bit
        sta joystick_state
not_a:
        
        ; Check O key (Left) - Row 2, Column 4
        lda #%11111011         ; Write $FB to $DC00
        sta $dc00
        lda $dc01
        and #%00010000         ; Check bit 4
        bne not_o
        lda joystick_state
        and #%11111011         ; Clear joystick left bit
        sta joystick_state
not_o:
        
        ; Check P key (Right) - Row 2, Column 5
        lda #%11111011         ; Write $FB to $DC00
        sta $dc00
        lda $dc01
        and #%00100000         ; Check bit 5
        bne not_p
        lda joystick_state
        and #%11110111         ; Clear joystick right bit
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
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,53
        !byte 0

grid_info_text:
        !byte 7,18,9,4,58,32,56,24,54,32,40,56,32,3,15,12,21,13,14,19,32,24,32,54,32,18,15,23,19,41
        !byte 0

pos_label:
        !byte 16,15,19,58,32
        !byte 0

pixel_label:
        !byte 16,9,24,5,12,58,32
        !byte 0

sprite_data:
        ; Simple ball sprite (same as lesson 4)
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

grid_x:
        !byte 0
        
grid_y:
        !byte 0

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates grid position tracking:
;
; 1. GRID COORDINATES: Logical position system
;    - 8x6 grid overlaid on screen
;    - Each cell represents 32x32 pixel area
;    - Grid position calculated from pixel position
;    
; 2. POSITION CALCULATION: Convert pixels to grid
;    - grid_x = sprite_x / 32
;    - grid_y = (sprite_y - offset) / 32
;    - Integer division by bit shifting
;    
; 3. DUAL TRACKING: Both systems active
;    - Sprite still moves by pixels
;    - Grid position updates automatically
;    - Foundation for game logic
;
; LEARNING OBJECTIVES ACHIEVED:
; - Understand grid coordinate systems
; - Learn position mapping techniques
; - Implement integer division
; - Track dual position systems