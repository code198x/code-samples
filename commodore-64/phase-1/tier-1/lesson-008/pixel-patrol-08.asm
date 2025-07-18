; Pixel Patrol - Lesson 8: Basic Game Loop
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-008

; Target: Commodore 64
; Assembler: ACME
; Outcome: Continuous play with proper game structure

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

; Movement constraints
MIN_GRID_X = 0                 ; Leftmost column
MAX_GRID_X = GRID_WIDTH - 1    ; Rightmost column (7)
MIN_GRID_Y = 0                 ; Top row
MAX_GRID_Y = GRID_HEIGHT - 1   ; Bottom row (5)

; Game states
STATE_INIT = 0                 ; Initialization
STATE_PLAYING = 1              ; Main game
STATE_PAUSED = 2               ; Paused (future)

; Timing constants
FRAMES_PER_SECOND = 50         ; PAL timing
FRAME_COUNTER_RESET = 50       ; Reset after 1 second

;===============================================================================
; MAIN PROGRAM
;===============================================================================
*=$0810                        ; Start at decimal 2064

main:
        ; Initialize game state
        lda #STATE_INIT
        sta game_state
        
        ; Jump to game initialization
        jsr game_init
        
        ; Set game to playing state
        lda #STATE_PLAYING
        sta game_state
        
        ; Enter main game loop
        jmp game_loop

;===============================================================================
; GAME INITIALIZATION
;===============================================================================

game_init:
        ; Initialize hardware
        jsr init_screen
        jsr init_sprites
        
        ; Initialize game variables
        jsr init_game_vars
        
        ; Display game UI
        jsr display_game_ui
        
        ; Setup complete
        rts

init_screen:
        ; Set border color to white
        lda #$01               ; White color
        sta $d020              ; VIC-II border color register
        
        ; Set background color to blue
        lda #$06               ; Blue color
        sta $d021              ; VIC-II background color register
        
        ; Clear screen
        jsr clear_screen
        
        rts

init_sprites:
        ; Set up player sprite
        jsr setup_sprite
        
        ; Enable sprite
        lda #$01               ; Enable sprite 0
        sta $d015              ; VIC-II sprite enable register
        
        ; Set sprite color
        lda #$07               ; Yellow
        sta $d027              ; VIC-II sprite 0 color register
        
        rts

init_game_vars:
        ; Initialize grid position (center)
        lda #4                 ; Grid X = 4
        sta grid_x
        lda #3                 ; Grid Y = 3
        sta grid_y
        
        ; Initialize timing
        lda #0
        sta frame_counter
        sta seconds_counter
        
        ; Initialize movement state
        lda #0
        sta boundary_hit
        
        ; Convert initial position
        jsr grid_to_sprite_position
        jsr update_sprite_position
        
        rts

display_game_ui:
        ; Display title
        ldx #0
display_title:
        lda title_text,x
        beq title_done
        sta $0400 + 40*1 + 8,x
        inx
        jmp display_title
title_done:

        ; Display instructions
        ldx #0
display_inst:
        lda instruction_text,x
        beq inst_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp display_inst
inst_done:

        ; Display initial stats
        jsr update_game_stats
        
        rts

;===============================================================================
; MAIN GAME LOOP
;===============================================================================

game_loop:
        ; Wait for frame start
        jsr wait_frame_start
        
        ; Update frame counter
        jsr update_timing
        
        ; Check game state
        lda game_state
        cmp #STATE_PLAYING
        bne skip_game_update
        
        ; Game update cycle
        jsr read_input         ; Get player input
        jsr update_game        ; Update game logic
        jsr update_display     ; Update screen
        
skip_game_update:
        ; End of frame
        jmp game_loop          ; Continue forever

;===============================================================================
; GAME UPDATE CYCLE
;===============================================================================

read_input:
        ; Read joystick
        jsr read_joystick
        rts

update_game:
        ; Update player movement
        jsr move_grid_constrained
        
        ; Convert position
        jsr grid_to_sprite_position
        
        ; Update sprite
        jsr update_sprite_position
        
        ; Update visual feedback
        jsr update_border_color
        
        rts

update_display:
        ; Update position display
        jsr display_current_position
        
        ; Update game statistics
        jsr update_game_stats
        
        rts

;===============================================================================
; TIMING SYSTEM
;===============================================================================

wait_frame_start:
        ; Wait for specific raster line
wait_top:
        lda $d012              ; Current raster line
        cmp #251               ; Wait for line 251
        bne wait_top
        
        ; Wait for it to pass
wait_pass:
        lda $d012
        cmp #252
        bne wait_pass
        
        rts

update_timing:
        ; Increment frame counter
        inc frame_counter
        
        ; Check for second elapsed
        lda frame_counter
        cmp #FRAME_COUNTER_RESET
        bne timing_done
        
        ; Reset frame counter
        lda #0
        sta frame_counter
        
        ; Increment seconds
        inc seconds_counter
        
timing_done:
        rts

;===============================================================================
; GAME STATISTICS
;===============================================================================

update_game_stats:
        ; Display "TIME: XXX"
        ldx #0
display_time_label:
        lda time_label,x
        beq time_label_done
        sta $0400 + 40*22 + 2,x
        inx
        jmp display_time_label
time_label_done:

        ; Display seconds (3 digits)
        lda seconds_counter
        jsr display_byte_decimal
        
        ; Display "MOVES: XXX"
        ldx #0
display_moves_label:
        lda moves_label,x
        beq moves_label_done
        sta $0400 + 40*22 + 20,x
        inx
        jmp display_moves_label
moves_label_done:

        ; Display move count
        lda move_count
        sta temp_byte
        ldx #27                ; Position
        jsr display_byte_at_x
        
        rts

display_byte_decimal:
        ; Display A as 3-digit decimal
        sta temp_byte
        ldx #8                 ; Starting position
        
display_byte_at_x:
        lda temp_byte
        
        ; Hundreds
        ldx #0
        ldy #8                 ; Default position
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
        sta $0400 + 40*22,y
        iny
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
        sta $0400 + 40*22,y
        iny
        pla
        
        ; Ones
        clc
        adc #48
        sta $0400 + 40*22,y
        
        rts

;===============================================================================
; MOVEMENT WITH CONSTRAINTS (Enhanced from lesson 7)
;===============================================================================

move_grid_constrained:
        ; Store if we actually moved
        lda #0
        sta moved_flag
        
        ; Check Up
        lda joystick_state
        and #$01
        bne check_grid_down
        
        jsr try_move_up
        
check_grid_down:
        lda joystick_state
        and #$02
        bne check_grid_left
        
        jsr try_move_down
        
check_grid_left:
        lda joystick_state
        and #$04
        bne check_grid_right
        
        jsr try_move_left
        
check_grid_right:
        lda joystick_state
        and #$08
        bne grid_move_done
        
        jsr try_move_right
        
grid_move_done:
        ; If we moved, increment counter
        lda moved_flag
        beq no_move_count
        inc move_count
        
no_move_count:
        rts

try_move_up:
        lda grid_y
        cmp #MIN_GRID_Y
        beq hit_boundary
        
        dec grid_y
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

try_move_down:
        lda grid_y
        cmp #MAX_GRID_Y
        beq hit_boundary
        
        inc grid_y
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

try_move_left:
        lda grid_x
        cmp #MIN_GRID_X
        beq hit_boundary
        
        dec grid_x
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

try_move_right:
        lda grid_x
        cmp #MAX_GRID_X
        beq hit_boundary
        
        inc grid_x
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

hit_boundary:
        lda #$10               ; Flash duration
        sta boundary_hit
        jsr wait_for_release
        rts

wait_for_release:
        lda #0
        sta boundary_hit
        
wait_loop:
        jsr read_joystick_only
        lda joystick_state
        and #$0f
        cmp #$0f
        bne wait_loop
        rts

;===============================================================================
; DISPLAY ROUTINES
;===============================================================================

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

        ; Display coordinates
        lda grid_x
        clc
        adc #48
        sta $0400 + 40*5 + 7
        
        lda #44                ; Comma
        sta $0400 + 40*5 + 8
        
        lda grid_y
        clc
        adc #48
        sta $0400 + 40*5 + 9
        
        rts

update_border_color:
        lda boundary_hit
        beq normal_border
        
        lda #$02               ; Red
        sta $d020
        dec boundary_hit
        rts
        
normal_border:
        lda #$01               ; White
        sta $d020
        rts

;===============================================================================
; REUSABLE SUBROUTINES (From previous lessons)
;===============================================================================

grid_to_sprite_position:
        lda grid_x
        asl
        asl
        asl
        asl
        asl
        clc
        adc #GRID_START_X
        sta sprite_x
        
        lda grid_y
        asl
        asl
        asl
        asl
        asl
        clc
        adc #GRID_START_Y
        sta sprite_y
        
        rts

update_sprite_position:
        lda sprite_x
        sta $d000
        lda sprite_y
        sta $d001
        
        lda sprite_x
        cmp #255
        bcc no_msb
        
        lda $d010
        ora #$01
        sta $d010
        jmp msb_done
        
no_msb:
        lda $d010
        and #$fe
        sta $d010
        
msb_done:
        rts

read_joystick:
        jsr read_joystick_only
        jsr check_keyboard_input
        rts

read_joystick_only:
        lda $dc00
        sta joystick_state
        rts

setup_sprite:
        lda #$0d
        sta $07f8
        
        ldx #0
copy_sprite:
        lda sprite_data,x
        sta $0340,x
        inx
        cpx #63
        bne copy_sprite
        
        rts

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
        
        lda #$ff
        sta $dc00
        
        rts

clear_screen:
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
        
        rts

;===============================================================================
; DATA
;===============================================================================

title_text:
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,56
        !byte 0

instruction_text:
        !byte 21,19,5,32,10,15,25,19,20,9,3,11,32,20,15,32,13,15,22,5,32,9,14,32,7,18,9,4
        !byte 0

time_label:
        !byte 20,9,13,5,58,32
        !byte 0

moves_label:
        !byte 13,15,22,5,19,58,32
        !byte 0

pos_label:
        !byte 16,15,19,58,32
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

boundary_hit:
        !byte 0

game_state:
        !byte 0

frame_counter:
        !byte 0

seconds_counter:
        !byte 0

move_count:
        !byte 0

moved_flag:
        !byte 0

temp_byte:
        !byte 0

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates a complete game loop:
;
; 1. GAME STRUCTURE: Organized initialization and main loop
;    - Separate init phase from game loop
;    - Clear state management
;    - Modular subroutine organization
;    
; 2. UPDATE CYCLE: Read-Update-Display pattern
;    - Read input first
;    - Update game logic
;    - Display changes
;    - Consistent frame timing
;    
; 3. TIMING SYSTEM: Frame counting and statistics
;    - Count frames for timing
;    - Track elapsed seconds
;    - Count player moves
;    - Professional game feel
;    
; 4. GAME STATE: Foundation for complex games
;    - STATE_INIT for setup
;    - STATE_PLAYING for main game
;    - Ready for pause, menu, etc.
;
; LEARNING OBJECTIVES ACHIEVED:
; - Implement proper game loop structure
; - Create frame-based timing system
; - Track game statistics
; - Build modular, maintainable code