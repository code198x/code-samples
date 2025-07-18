; Pixel Patrol - Lesson 4: Grid-Based Movement
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-004

; Target: Commodore 64
; Assembler: ACME
; Outcome: Player sprite with grid-based movement system (Foundation phase)

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
GRID_WIDTH = 8                 ; 8 columns in grid
GRID_HEIGHT = 6                ; 6 rows in grid
GRID_CELL_WIDTH = 32           ; 32 pixels per grid cell
GRID_CELL_HEIGHT = 32          ; 32 pixels per grid cell
GRID_START_X = 32              ; Starting X position for grid
GRID_START_Y = 64              ; Starting Y position for grid

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
        
        ; Display title and UI
        jsr display_ui
        
        ; Initialize grid position (center of grid)
        lda #3                 ; Grid X = 3 (center of 8 columns)
        sta grid_x
        lda #2                 ; Grid Y = 2 (center of 6 rows)
        sta grid_y
        
        ; Set initial movement state
        lda #0                 ; Not moving
        sta moving_state
        
        ; Set up sprites
        jsr setup_player_sprite
        
        ; Update sprite position to match grid
        jsr update_sprite_position

        ; Enable sprite (player only)
        lda #$01               ; Enable sprite 0
        sta $d015              ; VIC-II sprite enable register
        
        ; Set sprite color
        lda #$07               ; Yellow for player
        sta $d027              ; VIC-II sprite 0 color register

        ; Main game loop
game_loop:
        jsr read_input         ; Read joystick input
        jsr update_movement    ; Handle grid movement
        jsr wait_frame         ; Wait for next frame
        jmp game_loop          ; Continue forever

;===============================================================================
; GRID MOVEMENT SYSTEM
;===============================================================================

read_input:
        ; Only accept input if not currently moving
        lda moving_state
        bne input_done         ; If moving, ignore input
        
        ; Read joystick port 2 (CIA1 Port A)
        lda $dc00              ; Read CIA1 Port A
        sta joystick_state     ; Store current state
        
        ; Check for keyboard input (QAOP)
        jsr check_keyboard_input
        
        ; Check Up (bit 0 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$01               ; Check bit 0 (Up)
        bne check_down         ; If bit set, not pressed
        
        ; Try to move up
        jsr try_move_up
        jmp input_done
        
check_down:
        ; Check Down (bit 1 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$02               ; Check bit 1 (Down)
        bne check_left         ; If bit set, not pressed
        
        ; Try to move down
        jsr try_move_down
        jmp input_done
        
check_left:
        ; Check Left (bit 2 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$04               ; Check bit 2 (Left)
        bne check_right        ; If bit set, not pressed
        
        ; Try to move left
        jsr try_move_left
        jmp input_done
        
check_right:
        ; Check Right (bit 3 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$08               ; Check bit 3 (Right)
        bne input_done         ; If bit set, not pressed
        
        ; Try to move right
        jsr try_move_right
        
input_done:
        rts

try_move_up:
        ; Check if we can move up
        lda grid_y             ; Get current Y position
        beq cannot_move        ; If at top (Y=0), can't move up
        
        ; Move up one grid position
        dec grid_y             ; Decrease Y position
        jsr start_movement     ; Start movement animation
        
cannot_move:
        rts

try_move_down:
        ; Check if we can move down
        lda grid_y             ; Get current Y position
        cmp #GRID_HEIGHT-1     ; Compare with bottom edge
        beq cannot_move        ; If at bottom, can't move down
        
        ; Move down one grid position
        inc grid_y             ; Increase Y position
        jsr start_movement     ; Start movement animation
        rts

try_move_left:
        ; Check if we can move left
        lda grid_x             ; Get current X position
        beq cannot_move        ; If at left edge (X=0), can't move left
        
        ; Move left one grid position
        dec grid_x             ; Decrease X position
        jsr start_movement     ; Start movement animation
        rts

try_move_right:
        ; Check if we can move right
        lda grid_x             ; Get current X position
        cmp #GRID_WIDTH-1      ; Compare with right edge
        beq cannot_move        ; If at right edge, can't move right
        
        ; Move right one grid position
        inc grid_x             ; Increase X position
        jsr start_movement     ; Start movement animation
        rts

start_movement:
        ; Start movement animation
        lda #1                 ; Set moving state
        sta moving_state
        
        lda #16                ; Set movement counter (16 frames for smooth movement)
        sta movement_counter
        
        rts

update_movement:
        ; Check if we're currently moving
        lda moving_state
        beq not_moving         ; If not moving, skip
        
        ; Decrement movement counter
        dec movement_counter
        bne still_moving       ; If not zero, still moving
        
        ; Movement complete
        lda #0                 ; Clear moving state
        sta moving_state
        
        ; Update final sprite position
        jsr update_sprite_position
        
        rts
        
still_moving:
        ; Update sprite position for smooth movement
        jsr update_sprite_position
        
not_moving:
        rts

update_sprite_position:
        ; Calculate pixel position from grid position
        ; X position = GRID_START_X + (grid_x * GRID_CELL_WIDTH)
        lda grid_x             ; Get grid X position
        ldx #GRID_CELL_WIDTH   ; Get cell width
        jsr multiply_a_by_x    ; Multiply A by X
        clc
        adc #GRID_START_X      ; Add grid start X
        sta sprite_pixel_x     ; Store pixel X position
        
        ; Y position = GRID_START_Y + (grid_y * GRID_CELL_HEIGHT)
        lda grid_y             ; Get grid Y position
        ldx #GRID_CELL_HEIGHT  ; Get cell height
        jsr multiply_a_by_x    ; Multiply A by X
        clc
        adc #GRID_START_Y      ; Add grid start Y
        sta sprite_pixel_y     ; Store pixel Y position
        
        ; If we're moving, interpolate between positions
        lda moving_state
        beq set_sprite_position ; If not moving, use exact position
        
        ; TODO: Add smooth interpolation here (for lessons 9-16)
        ; For now, just use the target position
        
set_sprite_position:
        ; Set sprite hardware position
        lda sprite_pixel_x     ; Get pixel X position
        sta $d000              ; Set sprite 0 X position
        
        lda sprite_pixel_y     ; Get pixel Y position
        sta $d001              ; Set sprite 0 Y position
        
        ; Handle X MSB if needed
        lda sprite_pixel_x     ; Get pixel X position
        cmp #255               ; Check if > 255
        bcc no_msb             ; If < 255, no MSB needed
        
        lda $d010              ; Get X MSB register
        ora #$01               ; Set bit 0 (sprite 0 X MSB)
        sta $d010              ; Store back
        jmp msb_done
        
no_msb:
        lda $d010              ; Get X MSB register
        and #$fe               ; Clear bit 0 (sprite 0 X MSB)
        sta $d010              ; Store back
        
msb_done:
        rts

multiply_a_by_x:
        ; Simple multiplication routine (A = A * X)
        ; Only works for small values, sufficient for grid positioning
        sta temp_a             ; Store A
        lda #0                 ; Clear result
        
mult_loop:
        clc
        adc temp_a             ; Add original A value
        dex                    ; Decrement counter
        bne mult_loop          ; Continue until X = 0
        
        rts


;===============================================================================
; UTILITY SUBROUTINES
;===============================================================================

check_keyboard_input:
        ; Check keyboard input (same as previous lessons)
        ; Check Q key (Up)
        lda #%01111111
        sta $dc00
        lda $dc01
        and #%01000000
        bne not_q
        lda joystick_state
        and #%11111110
        sta joystick_state
not_q:
        
        ; Check A key (Down)
        lda #%11111101
        sta $dc00
        lda $dc01
        and #%00000100
        bne not_a
        lda joystick_state
        and #%11111101
        sta joystick_state
not_a:
        
        ; Check O key (Left)
        lda #%11110111
        sta $dc00
        lda $dc01
        and #%01000000
        bne not_o
        lda joystick_state
        and #%11111011
        sta joystick_state
not_o:
        
        ; Check P key (Right)
        lda #%11111101
        sta $dc00
        lda $dc01
        and #%00100000
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
        ; Clear screen (same as previous lessons)
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
        
        ldx #$e8
clear_remaining:
        lda #$20
        sta $0700,x
        lda #$01
        sta $db00,x
        inx
        cpx #$00
        bne clear_remaining
        
        rts

display_ui:
        ; Display title and instructions
        ldx #0
display_title:
        lda title_text,x
        beq title_done
        sta $0400 + 40*1 + 8,x
        inx
        jmp display_title
title_done:
        
        ldx #0
display_instructions:
        lda instruction_text,x
        beq instructions_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp display_instructions
instructions_done:
        
        rts

setup_player_sprite:
        ; Set up player sprite (same as previous lessons)
        lda #$0d
        sta $07f8
        
        ldx #0
copy_player_sprite:
        lda player_sprite_data,x
        sta $0340,x
        inx
        cpx #63
        bne copy_player_sprite
        
        rts


wait_frame:
        ; Wait for next frame (same as previous lessons)
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

instruction_text:
        !byte 13,15,22,5,32,9,14,32,7,18,9,4,32,16,15,19,9,20,9,15,14,19,33
        !byte 0

player_sprite_data:
        ; Player sprite (same as previous lessons)
        !byte %00000000, %01111110, %00000000
        !byte %00000000, %11111111, %00000000
        !byte %00000001, %11111111, %10000000
        !byte %00000011, %11111111, %11000000
        !byte %00000111, %11111111, %11100000
        !byte %00001111, %11111111, %11110000
        !byte %00011111, %11111111, %11111000
        !byte %00111111, %11111111, %11111100
        !byte %01111111, %11111111, %11111110
        !byte %11111111, %11111111, %11111111
        !byte %11111111, %11111111, %11111111
        !byte %11111111, %11111111, %11111111
        !byte %11111111, %11111111, %11111111
        !byte %11111111, %11111111, %11111111
        !byte %11111111, %11111111, %11111111
        !byte %11111111, %11111111, %11111111
        !byte %01111111, %11111111, %11111110
        !byte %00111111, %11111111, %11111100
        !byte %11001111, %11111111, %11110011
        !byte %11100111, %11111111, %11100111
        !byte %11110000, %00000000, %00001111
        !byte %00000000, %00000000, %00000000


; Variable storage
joystick_state:
        !byte $ff

grid_x:
        !byte 0
grid_y:
        !byte 0

sprite_pixel_x:
        !byte 0
sprite_pixel_y:
        !byte 0

moving_state:
        !byte 0
movement_counter:
        !byte 0

temp_a:
        !byte 0

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates grid-based movement system:
;
; 1. GRID COORDINATE SYSTEM: The game uses a logical grid overlay
;    - 8x6 grid of positions (GRID_WIDTH x GRID_HEIGHT)
;    - Each grid cell is 32x32 pixels
;    - Grid coordinates are separate from pixel coordinates
;    
; 2. DISCRETE MOVEMENT: Player moves one grid cell at a time
;    - Input is only accepted when not currently moving
;    - Movement is validated against grid boundaries
;    - Smooth animation between grid positions (foundation for lessons 9-16)
;    
; 3. GRID-TO-PIXEL CONVERSION: Logical coordinates converted to hardware positions
;    - Grid position multiplied by cell size
;    - Added to grid start offset for final pixel position
;    - Hardware sprite positioned at calculated pixel coordinates
;    
; 4. MOVEMENT STATE MACHINE: Tracks current movement status
;    - moving_state: 0=stationary, 1=moving
;    - movement_counter: frames remaining in current movement
;    - Prevents new input during movement animation
;
; LEARNING OBJECTIVES ACHIEVED:
; - Understand grid-based game design principles
; - Learn coordinate system conversion techniques
; - Implement discrete movement with validation
; - Create professional game state management
; - Build foundation for smooth animation system