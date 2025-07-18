; Pixel Patrol - Lesson 6: Sprite Grid Movement
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-006

; Target: Commodore 64
; Assembler: ACME
; Outcome: Sprite jumps between grid positions

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

; Grid cell size in pixels
GRID_CELL_WIDTH = 32           ; 32 pixels wide
GRID_CELL_HEIGHT = 32          ; 32 pixels tall

; Grid starting position on screen
GRID_START_X = 32              ; X offset for grid
GRID_START_Y = 50              ; Y offset for grid

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

        ; Initialize grid position (center)
        lda #4                 ; Grid X = 4 (center of 8 columns)
        sta grid_x
        lda #3                 ; Grid Y = 3 (center of 6 rows)
        sta grid_y
        
        ; Convert grid to sprite position
        jsr grid_to_sprite_position
        
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
        jsr move_grid          ; Move in grid
        jsr grid_to_sprite_position ; Convert to pixels
        jsr update_sprite_position ; Update hardware
        jsr display_current_position ; Show positions
        jsr wait_frame         ; Wait for next frame
        jmp game_loop          ; Continue forever

;===============================================================================
; GRID TO SPRITE CONVERSION
;===============================================================================

grid_to_sprite_position:
        ; Convert grid X to sprite X
        ; sprite_x = GRID_START_X + (grid_x * GRID_CELL_WIDTH)
        lda grid_x
        asl                    ; × 2
        asl                    ; × 4
        asl                    ; × 8
        asl                    ; × 16
        asl                    ; × 32
        clc
        adc #GRID_START_X
        sta sprite_x
        
        ; Convert grid Y to sprite Y
        ; sprite_y = GRID_START_Y + (grid_y * GRID_CELL_HEIGHT)
        lda grid_y
        asl                    ; × 2
        asl                    ; × 4
        asl                    ; × 8
        asl                    ; × 16
        asl                    ; × 32
        clc
        adc #GRID_START_Y
        sta sprite_y
        
        rts

;===============================================================================
; GRID MOVEMENT
;===============================================================================

move_grid:
        ; Check Up
        lda joystick_state
        and #$01
        bne check_grid_down
        
        ; Move up one grid position
        lda grid_y
        beq check_grid_down    ; Already at top
        dec grid_y
        jsr wait_for_release   ; Prevent repeat
        
check_grid_down:
        ; Check Down
        lda joystick_state
        and #$02
        bne check_grid_left
        
        ; Move down one grid position
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq check_grid_left    ; Already at bottom
        inc grid_y
        jsr wait_for_release
        
check_grid_left:
        ; Check Left
        lda joystick_state
        and #$04
        bne check_grid_right
        
        ; Move left one grid position
        lda grid_x
        beq check_grid_right   ; Already at left edge
        dec grid_x
        jsr wait_for_release
        
check_grid_right:
        ; Check Right
        lda joystick_state
        and #$08
        bne grid_move_done
        
        ; Move right one grid position
        lda grid_x
        cmp #GRID_WIDTH-1
        beq grid_move_done     ; Already at right edge
        inc grid_x
        jsr wait_for_release
        
grid_move_done:
        rts

wait_for_release:
        ; Wait for joystick to return to center
        ; This prevents continuous movement
wait_loop:
        jsr read_joystick_only
        lda joystick_state
        and #$0f               ; Check all directions
        cmp #$0f               ; All bits high = centered
        bne wait_loop
        rts

;===============================================================================
; DISPLAY ROUTINES
;===============================================================================

display_grid_info:
        ; Display "GRID MOVEMENT"
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
        ; Display "GRID: X,Y"
        ldx #0
display_grid_label:
        lda grid_label,x
        beq grid_label_done
        sta $0400 + 40*5 + 2,x
        inx
        jmp display_grid_label
grid_label_done:

        ; Display grid X
        lda grid_x
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*5 + 8
        
        ; Display comma
        lda #44                ; Comma character
        sta $0400 + 40*5 + 9
        
        ; Display grid Y
        lda grid_y
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*5 + 10
        
        ; Display pixel position
        ldx #0
display_pixel_label:
        lda pixel_label,x
        beq pixel_label_done
        sta $0400 + 40*7 + 2,x
        inx
        jmp display_pixel_label
pixel_label_done:

        ; Display sprite X (simple 3-digit)
        lda sprite_x
        jsr display_byte_decimal
        
        ; Display comma
        lda #44                ; Comma
        sta $0400 + 40*7 + 13
        
        ; Display sprite Y
        lda sprite_y
        sta temp_byte
        ldx #14               ; Position after comma
        jsr display_byte_at_x
        
        rts

display_byte_decimal:
        ; Display A as 3-digit decimal at current position
        sta temp_byte
        ldx #10               ; Starting X position
        
display_byte_at_x:
        lda temp_byte
        
        ; Hundreds
        ldx #0
count_hundreds:
        cmp #100
        bcc show_hundreds
        sec
        sbc #100
        inx
        jmp count_hundreds
show_hundreds:
        pha
        txa
        clc
        adc #48
        sta $0400 + 40*7 + 10
        pla
        
        ; Tens
        ldx #0
count_tens:
        cmp #10
        bcc show_tens
        sec
        sbc #10
        inx
        jmp count_tens
show_tens:
        pha
        txa
        clc
        adc #48
        sta $0400 + 40*7 + 11
        pla
        
        ; Ones
        clc
        adc #48
        sta $0400 + 40*7 + 12
        
        rts

;===============================================================================
; INPUT HANDLING
;===============================================================================

read_joystick:
        jsr read_joystick_only
        
        ; Check for keyboard input (QAOP)
        jsr check_keyboard_input
        
        rts

read_joystick_only:
        ; Read joystick port 2 (CIA1 Port A)
        lda $dc00              ; Read CIA1 Port A
        sta joystick_state     ; Store current state
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
        ; Check Q key (Up) - Column 1, Row 6
        lda #%11111101         ; Select column 1
        sta $dc00
        lda $dc01
        and #%01000000         ; Check bit 6 (row 6)
        bne not_q
        lda joystick_state
        and #%11111110         ; Clear joystick up bit
        sta joystick_state
not_q:
        
        ; Check A key (Down) - Column 1, Row 2
        lda #%11111101         ; Select column 1
        sta $dc00
        lda $dc01
        and #%00000100         ; Check bit 2 (row 2)
        bne not_a
        lda joystick_state
        and #%11111101         ; Clear joystick down bit
        sta joystick_state
not_a:
        
        ; Check O key (Left) - Column 2, Row 6
        lda #%11111011         ; Select column 2
        sta $dc00
        lda $dc01
        and #%01000000         ; Check bit 6 (row 6)
        bne not_o
        lda joystick_state
        and #%11111011         ; Clear joystick left bit
        sta joystick_state
not_o:
        
        ; Check P key (Right) - Column 2, Row 1
        lda #%11111011         ; Select column 2
        sta $dc00
        lda $dc01
        and #%00000010         ; Check bit 1 (row 1)
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
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,54
        !byte 0

grid_info_text:
        !byte 7,18,9,4,32,13,15,22,5,13,5,14,20,32,40,10,21,13,16,19,32,2,5,20,23,5,5,14,32,3,5,12,12,19,41
        !byte 0

grid_label:
        !byte 7,18,9,4,58,32
        !byte 0

pixel_label:
        !byte 16,9,24,5,12,58,32
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

grid_x:
        !byte 0
        
grid_y:
        !byte 0

temp_byte:
        !byte 0

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates sprite grid movement:
;
; 1. GRID-BASED MOVEMENT: Sprite jumps between grid cells
;    - Movement by whole grid positions
;    - No smooth pixel movement
;    - Instant positioning at grid centers
;    
; 2. GRID TO SPRITE CONVERSION: Calculate pixel position
;    - sprite_x = GRID_START_X + (grid_x * 32)
;    - sprite_y = GRID_START_Y + (grid_y * 32)
;    - Multiplication by bit shifting (ASL)
;    
; 3. INPUT HANDLING: One move per press
;    - Wait for joystick release
;    - Prevents continuous jumping
;    - Clear, discrete movement
;
; LEARNING OBJECTIVES ACHIEVED:
; - Convert grid to pixel coordinates
; - Implement grid-based movement
; - Use bit shifting for multiplication
; - Create discrete game controls