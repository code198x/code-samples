; GRID PROTOCOL: Smooth Linear Interpolation
; Lesson 9 - Smooth movement between grid positions
; Year: 2085 - Post-Collapse Era
;
; Objective: Entity glides smoothly between grid sectors
; Output: Interpolated movement with visual smoothness

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-09.prg", cbm

;===============================================================================
; CONSTANTS
;===============================================================================
GRID_WIDTH = 12                ; 12 columns
GRID_HEIGHT = 8                ; 8 rows

; Interpolation settings
INTERP_STEPS = 8               ; Steps between grid positions
INTERP_SPEED = 2               ; Pixels per frame

; Movement states
STATE_IDLE = 0
STATE_MOVING = 1

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
        jsr initialize_system
        jsr display_status
        jsr deploy_entity
        
        ; Main control loop
control_loop:
        jsr wait_frame
        jsr read_input
        jsr process_movement
        jsr interpolate_position
        jsr update_sprite
        jsr display_info
        jmp control_loop

;===============================================================================
; INITIALIZATION
;===============================================================================
initialize_system:
        ; Terminal activation
        lda #$00               ; Black void
        sta $d021
        lda #$03               ; Cyan signature
        sta $d020
        
        ; Clear screen
        jsr clear_screen
        
        ; Initialize positions
        lda #6                 ; Center X
        sta grid_x
        sta target_grid_x
        lda #4                 ; Center Y
        sta grid_y
        sta target_grid_y
        
        ; Calculate initial pixel positions
        jsr grid_to_pixels
        
        ; Set initial interpolation
        lda pixel_x
        sta current_x
        lda pixel_x_msb
        sta current_x_msb
        lda pixel_y
        sta current_y
        
        ; Initialize state
        lda #STATE_IDLE
        sta movement_state
        lda #0
        sta interp_step
        
        rts

;===============================================================================
; ENTITY DEPLOYMENT
;===============================================================================
deploy_entity:
        ; Set entity data pointer
        lda #$0d
        sta $07f8
        
        ; Load pattern
        ldx #0
load_pattern:
        lda entity_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne load_pattern
        
        ; Enable entity
        lda #$01
        sta $d015
        
        ; Set signature color
        lda #$03               ; Cyan
        sta $d027
        
        rts

;===============================================================================
; INPUT HANDLING
;===============================================================================
read_input:
        lda $dc00              ; Read joystick port 2
        sta joystick_state
        rts

process_movement:
        ; Only process if idle
        lda movement_state
        cmp #STATE_IDLE
        bne movement_done
        
        ; Check up
        lda joystick_state
        and #$01
        bne check_down
        lda grid_y
        beq check_down         ; Already at top
        dec target_grid_y
        jmp start_interpolation
        
check_down:
        lda joystick_state
        and #$02
        bne check_left
        lda grid_y
        cmp #GRID_HEIGHT-1
        beq check_left         ; Already at bottom
        inc target_grid_y
        jmp start_interpolation
        
check_left:
        lda joystick_state
        and #$04
        bne check_right
        lda grid_x
        beq check_right        ; Already at left
        dec target_grid_x
        jmp start_interpolation
        
check_right:
        lda joystick_state
        and #$08
        bne movement_done
        lda grid_x
        cmp #GRID_WIDTH-1
        beq movement_done      ; Already at right
        inc target_grid_x
        
start_interpolation:
        ; Start movement
        lda #STATE_MOVING
        sta movement_state
        lda #0
        sta interp_step
        
        ; Calculate target pixel position
        lda target_grid_x
        sta grid_x
        lda target_grid_y
        sta grid_y
        jsr grid_to_pixels
        
movement_done:
        rts

;===============================================================================
; INTERPOLATION SYSTEM
;===============================================================================
interpolate_position:
        ; Only interpolate if moving
        lda movement_state
        cmp #STATE_MOVING
        beq do_interpolate
        jmp interp_done
        
do_interpolate:
        
        ; Interpolate X position with MSB awareness
        ; First check if MSBs are different
        lda current_x_msb
        cmp pixel_x_msb
        beq same_msb_x
        
        ; Different MSB - handle 256 boundary crossing
        bcc move_right_with_msb  ; Current MSB=0, target MSB=1
        
        ; Move left across boundary (MSB 1->0)
        lda current_x
        sec
        sbc #INTERP_SPEED
        sta current_x
        bcs check_y_interp
        ; Crossed boundary
        lda #0
        sta current_x_msb
        jmp check_y_interp
        
move_right_with_msb:
        ; Move right across boundary (MSB 0->1)
        lda current_x
        clc
        adc #INTERP_SPEED
        sta current_x
        bcc check_y_interp
        ; Crossed boundary
        lda #1
        sta current_x_msb
        jmp check_y_interp
        
same_msb_x:
        ; Same MSB page - normal comparison
        lda current_x
        cmp pixel_x
        beq check_y_interp
        bcc move_right_normal
        
        ; Move left (same page)
        lda current_x
        sec
        sbc #INTERP_SPEED
        sta current_x
        jmp check_y_interp
        
move_right_normal:
        ; Move right (same page)
        lda current_x
        clc
        adc #INTERP_SPEED
        sta current_x
        
check_y_interp:
        ; Interpolate Y position
        lda current_y
        cmp pixel_y
        beq check_complete
        bcc move_down_interp
        
        ; Move up
        lda current_y
        sec
        sbc #INTERP_SPEED
        sta current_y
        jmp check_complete
        
move_down_interp:
        ; Move down
        lda current_y
        clc
        adc #INTERP_SPEED
        sta current_y
        
check_complete:
        ; Check if interpolation complete
        lda current_x_msb
        cmp pixel_x_msb
        bne interp_done        ; MSBs don't match yet
        lda current_x
        cmp pixel_x
        bne interp_done
        lda current_y
        cmp pixel_y
        bne interp_done
        
        ; Movement complete
        lda #STATE_IDLE
        sta movement_state
        
interp_done:
        rts

;===============================================================================
; POSITION CONVERSION
;===============================================================================
grid_to_pixels:
        ; Convert grid X to pixels using lookup table
        ldx grid_x
        lda x_positions,x
        sta pixel_x
        lda x_msb_flags,x
        sta pixel_x_msb
        
        ; Convert grid Y to pixels using lookup table
        ldx grid_y
        lda y_positions,x
        sta pixel_y
        
        rts

;===============================================================================
; SPRITE UPDATE
;===============================================================================
update_sprite:
        ; Set X position
        lda current_x
        sta $d000
        
        ; Set Y position
        lda current_y
        sta $d001
        
        ; Set X MSB
        lda current_x_msb
        sta $d010
        
        rts

;===============================================================================
; DISPLAY ROUTINES
;===============================================================================
display_status:
        ldx #0
status_loop:
        lda status_msg,x
        beq status_done
        sta $0400+22*40+9,x    ; Row 22
        inx
        jmp status_loop
status_done:
        rts

display_info:
        ; Display grid X position (0-11, needs two digits)
        lda grid_x
        cmp #10
        bcc single_digit_x
        
        ; Two digit X (10 or 11)
        lda #$31               ; '1'
        sta $0400+24*40+15     ; Row 24
        lda grid_x
        sec
        sbc #10                ; Get ones digit (0 or 1)
        ora #$30
        sta $0400+24*40+16
        jmp display_y
        
single_digit_x:
        ; Single digit X (0-9)
        lda #$20               ; Space
        sta $0400+24*40+15     
        lda grid_x
        ora #$30
        sta $0400+24*40+16
        
display_y:
        ; Display grid Y position (0-7, single digit)
        lda grid_y
        ora #$30
        sta $0400+24*40+18
        
        ; Display movement state
        lda movement_state
        cmp #STATE_MOVING
        bne show_idle
        
        ; Show moving indicator
        lda #42                ; Asterisk
        sta $0400+24*40+20     ; Adjusted position for 2-digit display
        rts
        
show_idle:
        lda #32                ; Space
        sta $0400+24*40+20
        rts

clear_screen:
        ldx #0
clear_loop:
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$03               ; Cyan
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

; Position variables
grid_x:         !byte 0
grid_y:         !byte 0
target_grid_x:  !byte 0
target_grid_y:  !byte 0

; Pixel positions
pixel_x:        !byte 0
pixel_x_msb:    !byte 0
pixel_y:        !byte 0

; Current interpolated positions
current_x:      !byte 0
current_x_msb:  !byte 0
current_y:      !byte 0

; State variables
movement_state: !byte 0
interp_step:    !byte 0
joystick_state: !byte $ff

; Position lookup tables
x_positions:
        !byte 28, 54, 80, 106, 132, 158, 184, 210, 236, 6, 32, 58

x_msb_flags:
        !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1

y_positions:
        !byte 55, 77, 99, 121, 143, 165, 187, 209

; Messages
status_msg:
        !byte 19,13,15,15,20,8,32,9,14,20,5,18,16,15,12,1,20,9,15,14  ; "SMOOTH INTERPOLATION"
        !byte 0

; Entity pattern (diamond)
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
; Lesson 9 improvements:
; - Smooth linear interpolation between grid positions
; - Movement state machine (IDLE/MOVING)
; - Separate current position from target position
; - Visual smoothness at 2 pixels per frame
; - No more instant snapping - professional movement feel