; Pixel Patrol - Lesson 7: Movement Constraints
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-007

; Target: Commodore 64
; Assembler: ACME
; Outcome: Sprite stays within grid bounds

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

; Wrap-around mode flag
WRAP_MODE = 0                  ; 0 = constrain, 1 = wrap

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

        ; Display constraint info
        jsr display_constraint_info

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
        jsr move_grid_constrained ; Move with constraints
        jsr grid_to_sprite_position ; Convert to pixels
        jsr update_sprite_position ; Update hardware
        jsr display_current_position ; Show positions
        jsr update_border_color ; Visual feedback
        jsr wait_frame         ; Wait for next frame
        jmp game_loop          ; Continue forever

;===============================================================================
; CONSTRAINED MOVEMENT
;===============================================================================

move_grid_constrained:
        ; Store old position for visual feedback
        lda grid_x
        sta old_grid_x
        lda grid_y
        sta old_grid_y
        
        ; Check Up
        lda joystick_state
        and #$01
        bne check_grid_down
        
        ; Try to move up
        jsr try_move_up
        
check_grid_down:
        ; Check Down
        lda joystick_state
        and #$02
        bne check_grid_left
        
        ; Try to move down
        jsr try_move_down
        
check_grid_left:
        ; Check Left
        lda joystick_state
        and #$04
        bne check_grid_right
        
        ; Try to move left
        jsr try_move_left
        
check_grid_right:
        ; Check Right
        lda joystick_state
        and #$08
        bne grid_move_done
        
        ; Try to move right
        jsr try_move_right
        
grid_move_done:
        rts

try_move_up:
        lda grid_y
        cmp #MIN_GRID_Y        ; At top edge?
        beq check_wrap_up      ; Check wrap mode
        
        ; Can move up
        dec grid_y
        jsr wait_for_release
        rts
        
check_wrap_up:
        lda #WRAP_MODE
        beq hit_boundary       ; No wrap, hit boundary
        
        ; Wrap to bottom
        lda #MAX_GRID_Y
        sta grid_y
        jsr wait_for_release
        rts

try_move_down:
        lda grid_y
        cmp #MAX_GRID_Y        ; At bottom edge?
        beq check_wrap_down    ; Check wrap mode
        
        ; Can move down
        inc grid_y
        jsr wait_for_release
        rts
        
check_wrap_down:
        lda #WRAP_MODE
        beq hit_boundary       ; No wrap, hit boundary
        
        ; Wrap to top
        lda #MIN_GRID_Y
        sta grid_y
        jsr wait_for_release
        rts

try_move_left:
        lda grid_x
        cmp #MIN_GRID_X        ; At left edge?
        beq check_wrap_left    ; Check wrap mode
        
        ; Can move left
        dec grid_x
        jsr wait_for_release
        rts
        
check_wrap_left:
        lda #WRAP_MODE
        beq hit_boundary       ; No wrap, hit boundary
        
        ; Wrap to right
        lda #MAX_GRID_X
        sta grid_x
        jsr wait_for_release
        rts

try_move_right:
        lda grid_x
        cmp #MAX_GRID_X        ; At right edge?
        beq check_wrap_right   ; Check wrap mode
        
        ; Can move right
        inc grid_x
        jsr wait_for_release
        rts
        
check_wrap_right:
        lda #WRAP_MODE
        beq hit_boundary       ; No wrap, hit boundary
        
        ; Wrap to left
        lda #MIN_GRID_X
        sta grid_x
        jsr wait_for_release
        rts

hit_boundary:
        ; Visual feedback for hitting boundary
        lda #$02               ; Red
        sta boundary_hit
        jsr wait_for_release
        rts

wait_for_release:
        ; Clear boundary hit indicator
        lda #$00
        sta boundary_hit
        
        ; Wait for joystick to return to center
wait_loop:
        jsr read_joystick_only
        lda joystick_state
        and #$0f               ; Check all directions
        cmp #$0f               ; All bits high = centered
        bne wait_loop
        rts

;===============================================================================
; VISUAL FEEDBACK
;===============================================================================

update_border_color:
        ; Flash border red when hitting boundary
        lda boundary_hit
        beq normal_border
        
        ; Red border for boundary hit
        lda #$02
        sta $d020
        
        ; Decrement flash timer
        dec boundary_hit
        rts
        
normal_border:
        ; Normal white border
        lda #$01
        sta $d020
        rts

;===============================================================================
; GRID TO SPRITE CONVERSION (Same as lesson 6)
;===============================================================================

grid_to_sprite_position:
        ; Convert grid X to sprite X
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
; DISPLAY ROUTINES
;===============================================================================

display_constraint_info:
        ; Display "BOUNDS: 0-7, 0-5"
        ldx #0
display_bounds_text:
        lda bounds_text,x
        beq bounds_done
        sta $0400 + 40*3 + 2,x
        inx
        jmp display_bounds_text
bounds_done:
        
        ; Display wrap mode status
        ldx #0
display_mode_text:
        lda mode_text,x
        beq mode_done
        sta $0400 + 40*4 + 2,x
        inx
        jmp display_mode_text
mode_done:
        
        lda #WRAP_MODE
        beq show_constrain
        
        ; Show "WRAP"
        ldx #0
show_wrap:
        lda wrap_text,x
        beq wrap_done
        sta $0400 + 40*4 + 8,x
        inx
        jmp show_wrap
wrap_done:
        rts
        
show_constrain:
        ; Show "CONSTRAIN"
        ldx #0
show_const:
        lda constrain_text,x
        beq const_done
        sta $0400 + 40*4 + 8,x
        inx
        jmp show_const
const_done:
        rts

display_current_position:
        ; Display "POS: X,Y"
        ldx #0
display_pos_label:
        lda pos_label,x
        beq pos_label_done
        sta $0400 + 40*6 + 2,x
        inx
        jmp display_pos_label
pos_label_done:

        ; Display grid X
        lda grid_x
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*6 + 7
        
        ; Display comma
        lda #44                ; Comma character
        sta $0400 + 40*6 + 8
        
        ; Display grid Y
        lda grid_y
        clc
        adc #48                ; Convert to ASCII
        sta $0400 + 40*6 + 9
        
        rts

;===============================================================================
; INPUT HANDLING (Same as lesson 6)
;===============================================================================

read_joystick:
        jsr read_joystick_only
        rts

read_joystick_only:
        lda $dc00
        sta joystick_state
        rts

;===============================================================================
; SPRITE HANDLING (Same as lesson 6)
;===============================================================================

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

wait_frame:
wait_raster:
        lda $d012
        cmp #250
        bne wait_raster
        rts

;===============================================================================
; DATA
;===============================================================================

title_text:
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,55
        !byte 0

bounds_text:
        !byte 2,15,21,14,4,19,58,32,48,45,55,44,32,48,45,53
        !byte 0

mode_text:
        !byte 13,15,4,5,58,32
        !byte 0

constrain_text:
        !byte 3,15,14,19,20,18,1,9,14
        !byte 0

wrap_text:
        !byte 23,18,1,16
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

old_grid_x:
        !byte 0
        
old_grid_y:
        !byte 0

boundary_hit:
        !byte 0

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates movement constraints:
;
; 1. BOUNDARY CHECKING: Validate moves before executing
;    - Check against MIN/MAX constants
;    - Prevent invalid positions
;    - Visual feedback on collision
;    
; 2. WRAP-AROUND OPTION: Alternative to constraints
;    - Move off one edge, appear on opposite
;    - Configurable with WRAP_MODE constant
;    - Common in classic games
;    
; 3. VISUAL FEEDBACK: Border flash on boundary hit
;    - Red border indicates collision
;    - Helps player understand constraints
;    - Professional polish
;
; LEARNING OBJECTIVES ACHIEVED:
; - Implement movement validation
; - Create boundary constraints
; - Add visual feedback systems
; - Design configurable behaviors