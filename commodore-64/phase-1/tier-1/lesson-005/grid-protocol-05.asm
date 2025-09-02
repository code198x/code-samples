; GRID PROTOCOL: Sector Grid Navigation
; Lesson 5 - Grid-based positioning system
; Year: 2085 - Post-Collapse Era
;
; Objective: Navigate entities using Grid sector coordinates
; Output: Entity moves in grid steps, not pixels

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-05.prg", cbm

;===============================================================================
; CONSTANTS
;===============================================================================
GRID_WIDTH = 12                ; 12 columns (reaches screen edge with MSB)
GRID_HEIGHT = 8                ; 8 rows (maximum screen coverage)

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
        
        ; Display grid status
        ldx #0
show_status:
        lda status_msg,x
        beq init_grid
        sta $0400+1*40+9,x     ; Centered (22 chars)
        inx
        jmp show_status

init_grid:
        ; Initialize grid position (center of 12x8 grid)
        lda #6
        sta grid_x
        lda #4
        sta grid_y
        
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
        jsr move_grid_constrained
        jsr update_position
        jsr wait_frame
        jmp control_loop

;===============================================================================
; GRID NAVIGATION
;===============================================================================

; Move within grid constraints
move_grid_constrained:
        lda control_state
        
        ; Check up
        and #$01
        bne check_grid_down
        lda grid_y
        beq check_grid_down    ; Already at top
        dec grid_y
        jsr wait_for_release
        
check_grid_down:
        lda control_state
        and #$02
        bne check_grid_left
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq check_grid_left    ; Already at bottom
        inc grid_y
        jsr wait_for_release
        
check_grid_left:
        lda control_state
        and #$04
        bne check_grid_right
        lda grid_x
        beq check_grid_right   ; Already at left
        dec grid_x
        jsr wait_for_release
        
check_grid_right:
        lda control_state
        and #$08
        bne grid_move_done
        lda grid_x
        cmp #GRID_WIDTH-1
        beq grid_move_done     ; Already at right
        inc grid_x
        jsr wait_for_release
        
grid_move_done:
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

; Wait for control release
wait_for_release:
        lda $dc00
        and #$0f
        cmp #$0f
        bne wait_for_release
        rts

;===============================================================================
; SUBROUTINES
;===============================================================================

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
        !byte 7,18,9,4,32                      ; "GRID "
        !byte 14,1,22,9,7,1,20,9,15,14,32      ; "NAVIGATION "
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
; Grid System:
; - 12 columns × 8 rows = 96 total positions
; - X range: 28 to 316 pixels (perfect screen coverage with MSB)
; - Y range: 55 to 209 pixels (leaves space for UI elements)
; - Uses lookup tables for authentic 1980s performance
; - MSB automatically handled for rightmost positions