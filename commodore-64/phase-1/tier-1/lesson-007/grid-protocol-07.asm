; GRID PROTOCOL: Movement State Tracking
; Lesson 7 - Advanced movement with state management
; Year: 2085 - Post-Collapse Era
;
; Objective: Track movement state and provide feedback
; Output: Movement state visualization and constraints

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-07.prg", cbm

;===============================================================================
; CONSTANTS
;===============================================================================
GRID_WIDTH = 12               ; 12 columns (reaches screen edge with MSB)
GRID_HEIGHT = 8               ; 8 rows (maximum screen coverage)

; Movement states
STATE_IDLE = 0
STATE_MOVING = 1
STATE_BLOCKED = 2

;===============================================================================
; GATEWAY PROTOCOL
;===============================================================================
*=$0801
        !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

;===============================================================================
; GRID INITIALIZATION
;===============================================================================
*=$080d
grid_init:
        ; Terminal activation
        lda #$00
        sta $d021
        lda #$03
        sta $d020
        
        ; Clear screen
        jsr clear_screen
        
        ; Display status
        ldx #0
show_status:
        lda status_msg,x
        beq init_system
        sta $0400+1*40+10,x    ; Centered (20 chars)
        inx
        jmp show_status

init_system:
        ; Initialize position (center of 12x8 grid)
        lda #6
        sta grid_x
        lda #4
        sta grid_y
        
        ; Initialize state
        lda #STATE_IDLE
        sta movement_state
        lda #0
        sta boundary_hit
        sta moved_flag
        
        ; Deploy entity
        jsr deploy_entity
        jsr update_position
        
        ; Enable entity
        lda #$01
        sta $d015
        lda #$03
        sta $d027

;===============================================================================
; MAIN LOOP
;===============================================================================
control_loop:
        jsr read_interface
        jsr process_movement
        jsr update_position
        jsr update_visual_feedback
        jsr wait_frame
        jmp control_loop

;===============================================================================
; MOVEMENT PROCESSING
;===============================================================================

process_movement:
        ; Reset flags
        lda #0
        sta boundary_hit
        sta moved_flag
        
        ; Set state to idle initially
        lda #STATE_IDLE
        sta movement_state
        
        ; Check for input
        lda control_state
        and #$0f
        cmp #$0f               ; All bits high = no input
        beq movement_done
        
        ; We have input, set moving state
        lda #STATE_MOVING
        sta movement_state
        
        ; Process each direction
        lda control_state
        and #$01
        bne check_proc_down
        jsr try_move_up
        
check_proc_down:
        lda control_state
        and #$02
        bne check_proc_left
        jsr try_move_down
        
check_proc_left:
        lda control_state
        and #$04
        bne check_proc_right
        jsr try_move_left
        
check_proc_right:
        lda control_state
        and #$08
        bne movement_done
        jsr try_move_right
        
movement_done:
        ; If we tried to move but hit boundary
        lda boundary_hit
        beq check_if_moved
        lda #STATE_BLOCKED
        sta movement_state
        rts
        
check_if_moved:
        ; If we moved successfully
        lda moved_flag
        beq no_movement
        lda #STATE_MOVING
        sta movement_state
        rts
        
no_movement:
        rts

; Movement attempts
try_move_up:
        lda grid_y
        beq hit_boundary
        dec grid_y
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

try_move_down:
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq hit_boundary
        inc grid_y
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

try_move_left:
        lda grid_x
        beq hit_boundary
        dec grid_x
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

try_move_right:
        lda grid_x
        cmp #GRID_WIDTH-1
        beq hit_boundary
        inc grid_x
        lda #1
        sta moved_flag
        jsr wait_for_release
        rts

hit_boundary:
        lda #1
        sta boundary_hit
        rts

; Update visual feedback based on state
update_visual_feedback:
        lda movement_state
        
        cmp #STATE_IDLE
        bne check_moving
        lda #$03               ; Cyan for idle
        sta $d020
        sta $d027
        rts
        
check_moving:
        cmp #STATE_MOVING
        bne check_blocked
        lda #$05               ; Green for moving
        sta $d020
        sta $d027
        rts
        
check_blocked:
        lda #$02               ; Red for blocked
        sta $d020
        sta $d027
        rts

; Update entity position using lookup tables
update_position:
        ; Use lookup table for X positions with MSB handling
        ldx grid_x
        lda x_positions,x
        sta $d000
        lda x_msb_flags,x
        sta $d010
        
        ; Use lookup table for Y positions
        ldx grid_y
        lda y_positions,x
        sta $d001
        rts

;===============================================================================
; SUBROUTINES
;===============================================================================

wait_for_release:
        lda $dc00
        and #$0f
        cmp #$0f
        bne wait_for_release
        rts

read_interface:
        lda $dc00
        sta control_state
        rts

deploy_entity:
        lda #$0d
        sta $07f8
        ldx #0
load_pattern:
        lda entity_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne load_pattern
        rts

clear_screen:
        ldx #0
clear_loop:
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$03
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_loop
        rts

wait_frame:
        lda #251
wait_raster:
        cmp $d012
        bne wait_raster
        rts

;===============================================================================
; DATA
;===============================================================================

; Grid position
grid_x:         !byte 6        ; Center of 12 columns
grid_y:         !byte 4        ; Center of 8 rows

; Control
control_state:  !byte 0
movement_state: !byte 0
boundary_hit:   !byte 0
moved_flag:     !byte 0

; X position lookup table - perfect margins (28 to 316)
x_positions:
        !byte 28, 54, 80, 106, 132, 158, 184, 210, 236, 6, 32, 58

; MSB flags (0 for positions < 256, 1 for positions >= 256)  
x_msb_flags:
        !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1

; Y positions - 8 rows with proper spacing (55, 77, 99, 121, 143, 165, 187, 209)
y_positions:
        !byte 55, 77, 99, 121, 143, 165, 187, 209

; Messages
status_msg:
        !byte 19,20,1,20,5,32                  ; "STATE "
        !byte 20,18,1,3,11,9,14,7,32           ; "TRACKING "
        !byte 1,3,20,9,22,5                    ; "ACTIVE"
        !byte 0

; Entity pattern
entity_pattern:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000111,%11111111,%11100000
        !byte %00001111,%11111111,%11110000
        !byte %00011111,%11111111,%11111000
        !byte %00111111,%11111111,%11111100
        !byte %01111111,%11111111,%11111110
        !byte %11111111,%11111111,%11111111
        !byte %01111111,%11111111,%11111110
        !byte %00111111,%11111111,%11111100
        !byte %00011111,%11111111,%11111000
        !byte %00001111,%11111111,%11110000
        !byte %00000111,%11111111,%11100000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000

;===============================================================================
; TECHNICAL NOTES
;===============================================================================
; State System:
; - 12 columns × 8 rows = 96 total positions
; - X range: 28 to 316 pixels (perfect screen coverage with MSB)
; - Y range: 55 to 209 pixels (leaves space for UI elements)
; - Visual feedback: Cyan=idle, Green=moving, Red=blocked
; - MSB automatically handled for rightmost positions