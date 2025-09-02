; GRID PROTOCOL: Sector Boundary Alerts
; Lesson 6 - Boundary detection and visual feedback
; Year: 2085 - Post-Collapse Era
;
; Objective: Detect and alert when entities reach sector boundaries
; Output: Visual feedback when hitting Grid limits

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-06.prg", cbm

;===============================================================================
; CONSTANTS
;===============================================================================
GRID_WIDTH = 12               ; 12 columns (reaches screen edge with MSB)
GRID_HEIGHT = 8               ; 8 rows (maximum screen coverage)

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
        sta $0400+1*40+8,x     ; Centered (24 chars)
        inx
        jmp show_status

init_system:
        ; Initialize grid position (center of 12x8 grid)
        lda #6
        sta grid_x
        lda #4
        sta grid_y
        
        ; Initialize boundary flag
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

;===============================================================================
; MAIN LOOP
;===============================================================================
control_loop:
        jsr read_interface
        jsr move_with_boundary_check
        jsr update_position
        jsr update_border_alert
        jsr wait_frame
        jmp control_loop

;===============================================================================
; BOUNDARY SYSTEM
;===============================================================================

move_with_boundary_check:
        lda #0
        sta boundary_hit       ; Clear boundary flag
        
        lda control_state
        
        ; Check up
        and #$01
        bne check_move_down
        lda grid_y
        beq hit_up_boundary
        dec grid_y
        jsr wait_for_release
        jmp check_move_down
hit_up_boundary:
        jsr hit_boundary
        
check_move_down:
        lda control_state
        and #$02
        bne check_move_left
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq hit_down_boundary
        inc grid_y
        jsr wait_for_release
        jmp check_move_left
hit_down_boundary:
        jsr hit_boundary
        
check_move_left:
        lda control_state
        and #$04
        bne check_move_right
        lda grid_x
        beq hit_left_boundary
        dec grid_x
        jsr wait_for_release
        jmp check_move_right
hit_left_boundary:
        jsr hit_boundary
        
check_move_right:
        lda control_state
        and #$08
        bne boundary_check_done
        lda grid_x
        cmp #GRID_WIDTH-1
        beq hit_right_boundary
        inc grid_x
        jsr wait_for_release
        jmp boundary_check_done
hit_right_boundary:
        jsr hit_boundary
        
boundary_check_done:
        rts

; Handle boundary hit
hit_boundary:
        lda #1
        sta boundary_hit
        rts

; Update border color based on boundary
update_border_alert:
        lda boundary_hit
        beq normal_border
        
        ; Flash red for boundary hit
        lda #$02               ; Red
        sta $d020
        rts
        
normal_border:
        lda #$03               ; Cyan
        sta $d020
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
boundary_hit:   !byte 0

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
        !byte 2,15,21,14,4,1,18,25,32          ; "BOUNDARY "
        !byte 4,5,20,5,3,20,9,15,14,32         ; "DETECTION "
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
; Boundary System:
; - 12 columns × 8 rows = 96 total positions
; - X range: 28 to 316 pixels (perfect screen coverage with MSB)
; - Y range: 55 to 209 pixels (leaves space for UI elements)
; - Border flashes red when hitting any boundary
; - MSB automatically handled for rightmost positions