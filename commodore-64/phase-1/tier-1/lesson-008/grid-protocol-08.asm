; GRID PROTOCOL: Complete Patrol System
; Lesson 8 - Full game loop with timing and state management
; Year: 2085 - Post-Collapse Era
;
; Objective: Complete patrol system with timing and state management
; Output: Fully functional Grid patrol with time tracking

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-08.prg", cbm

;===============================================================================
; CONSTANTS
;===============================================================================
GRID_WIDTH = 12               ; 12 columns (reaches screen edge with MSB)
GRID_HEIGHT = 8               ; 8 rows (maximum screen coverage)

; System states
STATE_INIT = 0
STATE_PATROL = 1
STATE_ALERT = 2

; Timing
FRAMES_PER_SECOND = 50
FRAME_COUNTER_RESET = 50

;===============================================================================
; GATEWAY PROTOCOL
;===============================================================================
*=$0801
        !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

;===============================================================================
; MAIN ENTRY
;===============================================================================
*=$080d
main:
        jsr initialize_grid
        
        ; Set initial state
        lda #STATE_PATROL
        sta system_state
        
        ; Main Grid loop
main_loop:
        jsr update_timing
        jsr update_game
        jsr update_display
        jsr wait_frame
        jmp main_loop

;===============================================================================
; INITIALIZATION
;===============================================================================
initialize_grid:
        ; Terminal activation
        lda #$00
        sta $d021
        lda #$03
        sta $d020
        
        ; Clear screen
        jsr clear_screen
        
        ; Display Grid status
        ldx #0
show_header:
        lda header_msg,x
        beq show_timer
        sta $0400+0*40+8,x     ; Top line
        inx
        jmp show_header
        
show_timer:
        ldx #0
show_time_label:
        lda time_label,x
        beq init_vars
        sta $0400+23*40+0,x    ; Bottom left
        inx
        jmp show_time_label
        
init_vars:
        ; Initialize grid position (center of 12x8 grid)
        lda #6                 ; Center X
        sta grid_x
        lda #4                 ; Center Y
        sta grid_y
        
        ; Initialize timing
        lda #0
        sta frame_counter
        sta seconds_counter
        
        ; Initialize state
        lda #0
        sta boundary_hit
        
        ; Deploy entity
        jsr deploy_entity
        jsr update_position
        
        ; Enable entity
        lda #$01
        sta $d015
        lda #$03
        sta $d027
        
        rts

;===============================================================================
; GAME UPDATE
;===============================================================================
update_game:
        ; Update based on state
        lda system_state
        cmp #STATE_PATROL
        bne skip_patrol
        
        ; Normal patrol operations
        jsr read_interface
        jsr move_grid_constrained
        jsr update_position
        jsr update_border_color
        
skip_patrol:
        rts

;===============================================================================
; TIMING SYSTEM
;===============================================================================
update_timing:
        ; Increment frame counter
        inc frame_counter
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
; DISPLAY UPDATE
;===============================================================================
update_display:
        ; Update time display
        lda seconds_counter
        
        ; Convert to BCD for display
        ldx #0
        sec
div10:
        sbc #10
        bcc done_div
        inx
        jmp div10
done_div:
        adc #10                ; A now contains ones digit
        
        ; Save ones digit
        pha
        
        ; Display tens digit
        txa
        clc
        adc #48                ; Convert to screen code
        sta $0400+23*40+14
        
        ; Display ones digit
        pla                    ; Restore ones digit
        clc
        adc #48
        sta $0400+23*40+15
        
        rts

;===============================================================================
; MOVEMENT SYSTEM
;===============================================================================
move_grid_constrained:
        lda #0
        sta boundary_hit
        
        lda control_state
        
        ; Check up
        and #$01
        bne check_grid_down
        jsr try_move_up
        
check_grid_down:
        lda control_state
        and #$02
        bne check_grid_left
        jsr try_move_down
        
check_grid_left:
        lda control_state
        and #$04
        bne check_grid_right
        jsr try_move_left
        
check_grid_right:
        lda control_state
        and #$08
        bne move_done
        jsr try_move_right
        
move_done:
        rts

try_move_up:
        lda grid_y
        beq hit_boundary
        dec grid_y
        jsr wait_for_release
        rts

try_move_down:
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq hit_boundary
        inc grid_y
        jsr wait_for_release
        rts

try_move_left:
        lda grid_x
        beq hit_boundary
        dec grid_x
        jsr wait_for_release
        rts

try_move_right:
        lda grid_x
        cmp #GRID_WIDTH-1
        beq hit_boundary
        inc grid_x
        jsr wait_for_release
        rts

hit_boundary:
        lda #1
        sta boundary_hit
        rts

update_border_color:
        lda boundary_hit
        beq normal_border
        lda #$02               ; Red alert
        sta $d020
        rts
normal_border:
        lda #$03               ; Cyan normal
        sta $d020
        rts

;===============================================================================
; UTILITY SUBROUTINES
;===============================================================================

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

read_interface:
        lda $dc00
        sta control_state
        rts

wait_for_release:
        lda $dc00
        and #$0f
        cmp #$0f
        bne wait_for_release
        rts

deploy_entity:
        lda #$0d
        sta $07f8
        ldx #0
copy_sprite:
        lda entity_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne copy_sprite
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
; DATA SECTION
;===============================================================================

; System state
system_state:   !byte STATE_INIT

; Grid position
grid_x:         !byte 6        ; Center of 12 columns
grid_y:         !byte 4        ; Center of 8 rows

; Control
control_state:  !byte 0
boundary_hit:   !byte 0

; Timing
frame_counter:  !byte 0
seconds_counter: !byte 0

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
header_msg:
        !byte 7,18,9,4,32                      ; "GRID "
        !byte 16,1,20,18,15,12,32              ; "PATROL "
        !byte 19,25,19,20,5,13,32              ; "SYSTEM "
        !byte 1,3,20,9,22,5                    ; "ACTIVE"
        !byte 0

time_label:
        !byte 20,9,13,5,32,5,12,1,16,19,5,4,58,32  ; "TIME ELAPSED: "
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
; Complete Patrol System:
; - 12 columns × 8 rows = 96 total positions
; - X range: 28 to 316 pixels (perfect screen coverage with MSB)
; - Y range: 55 to 209 pixels (leaves space for UI elements)
; - Real-time timer display showing patrol duration
; - State management system for future expansion
; - MSB automatically handled for rightmost positions