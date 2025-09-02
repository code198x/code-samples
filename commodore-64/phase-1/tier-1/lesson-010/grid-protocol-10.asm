; GRID PROTOCOL: Sprite Animation Frames
; Lesson 10 - Animated sprite with multiple frames
; Year: 2085 - Post-Collapse Era
;
; Objective: Entity animates while moving through the grid
; Output: Smooth movement with cycling animation frames

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-10.prg", cbm

;===============================================================================
; CONSTANTS
;===============================================================================
GRID_WIDTH = 12                ; 12 columns
GRID_HEIGHT = 8                ; 8 rows

; Interpolation settings
INTERP_SPEED = 2               ; Pixels per frame

; Movement states
STATE_IDLE = 0
STATE_MOVING = 1

; Animation settings
ANIM_SPEED = 4                 ; Frames between animation changes
ANIM_FRAMES = 4                ; Number of animation frames per direction
TOTAL_FRAMES = 8               ; 4 right-facing + 4 left-facing

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
        jsr update_animation
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
        
        ; Initialize animation
        lda #0
        sta anim_frame
        sta anim_timer
        sta facing_direction   ; 0=right, 1=left
        
        rts

;===============================================================================
; SPRITE FRAMES IN MEMORY
;===============================================================================
; Sprite frames are positioned directly at their final memory locations
; using the *=address directives. No copying needed!

;===============================================================================
; ENTITY DEPLOYMENT
;===============================================================================
deploy_entity:
        ; Set initial sprite pointer to frame 0
        lda #$0d               ; $0340 / 64 = $0D
        sta $07f8
        
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
        
        ; Store previous grid position to detect movement
        lda grid_x
        sta old_grid_x
        
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
        lda #1                 ; Face left
        sta facing_direction
        jmp start_interpolation
        
check_right:
        lda joystick_state
        and #$08
        bne movement_done
        lda grid_x
        cmp #GRID_WIDTH-1
        beq movement_done      ; Already at right
        inc target_grid_x
        lda #0                 ; Face right
        sta facing_direction
        
start_interpolation:
        ; Start movement
        lda #STATE_MOVING
        sta movement_state
        
        ; Reset animation for walking
        lda #1                 ; Start with walk frame 1
        sta anim_frame
        lda #0
        sta anim_timer
        
        ; Update grid position
        lda target_grid_x
        sta grid_x
        lda target_grid_y
        sta grid_y
        
        ; Calculate pixel target
        jsr grid_to_pixels
        
movement_done:
        rts

;===============================================================================
; INTERPOLATION SYSTEM (from lesson 9)
;===============================================================================
interpolate_position:
        ; Only interpolate if moving
        lda movement_state
        cmp #STATE_MOVING
        beq do_interpolate
        jmp interp_done
        
do_interpolate:
        ; Interpolate X position with MSB awareness
        lda current_x_msb
        cmp pixel_x_msb
        beq same_msb_x
        
        ; Different MSB - handle boundary
        bcc move_right_with_msb
        
        ; Move left across boundary
        lda current_x
        sec
        sbc #INTERP_SPEED
        sta current_x
        bcs check_y_interp
        lda #0
        sta current_x_msb
        jmp check_y_interp
        
move_right_with_msb:
        ; Move right across boundary
        lda current_x
        clc
        adc #INTERP_SPEED
        sta current_x
        bcc check_y_interp
        lda #1
        sta current_x_msb
        jmp check_y_interp
        
same_msb_x:
        ; Same MSB page
        lda current_x
        cmp pixel_x
        beq check_y_interp
        bcc move_right_normal
        
        ; Move left
        lda current_x
        sec
        sbc #INTERP_SPEED
        sta current_x
        jmp check_y_interp
        
move_right_normal:
        ; Move right
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
        bne interp_done
        lda current_x
        cmp pixel_x
        bne interp_done
        lda current_y
        cmp pixel_y
        bne interp_done
        
        ; Movement complete
        lda #STATE_IDLE
        sta movement_state
        
        ; Return to idle animation
        lda #0
        sta anim_frame
        
interp_done:
        rts

;===============================================================================
; ANIMATION SYSTEM
;===============================================================================
update_animation:
        ; Only animate when moving
        lda movement_state
        cmp #STATE_MOVING
        bne no_animation
        
        ; Increment animation timer
        inc anim_timer
        lda anim_timer
        cmp #ANIM_SPEED
        bcc no_animation
        
        ; Reset timer and advance frame
        lda #0
        sta anim_timer
        
        ; Cycle through walking frames (1-3)
        inc anim_frame
        lda anim_frame
        cmp #ANIM_FRAMES
        bcc frame_ok
        
        ; Wrap to frame 1 (skip idle frame 0)
        lda #1
        sta anim_frame
        
frame_ok:
        ; Update sprite pointer based on frame AND direction
        ; Right-facing frames (0-3): $0340-$0400 (blocks $0D-$10)
        ; Left-facing frames (4-7): $0440-$0500 (blocks $11-$14)
        lda facing_direction
        beq use_right_frames
        
        ; Use left-facing frames (add 4 to frame number)
        lda anim_frame
        clc
        adc #$11               ; Base for left frames
        sta $07f8
        jmp animation_done
        
use_right_frames:
        lda anim_frame
        clc
        adc #$0d               ; Base for right frames
        sta $07f8
        
animation_done:
        
no_animation:
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
        
        ; Direction-based sprites are handled in update_animation
        ; We're using pre-stored mirrored frames (solution #1)
        rts

;===============================================================================
; DISPLAY ROUTINES
;===============================================================================
display_status:
        ldx #0
status_loop:
        lda status_msg,x
        beq status_done
        sta $0400+22*40+11,x   ; Row 22
        inx
        jmp status_loop
status_done:
        rts

display_info:
        ; Display grid position (X: 0-11, Y: 0-7)
        lda grid_x
        cmp #10
        bcc single_digit_x
        
        ; Two digit X
        lda #$31               ; '1'
        sta $0400+24*40+15
        lda grid_x
        sec
        sbc #10
        ora #$30
        sta $0400+24*40+16
        jmp display_y
        
single_digit_x:
        lda #$20               ; Space
        sta $0400+24*40+15
        lda grid_x
        ora #$30
        sta $0400+24*40+16
        
display_y:
        lda grid_y
        ora #$30
        sta $0400+24*40+18
        
        ; Display animation frame
        lda anim_frame
        ora #$30
        sta $0400+24*40+27
        
        ; Display movement indicator
        lda movement_state
        cmp #STATE_MOVING
        bne show_idle
        lda #42                ; Asterisk
        sta $0400+24*40+20
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
old_grid_x:     !byte 0

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
joystick_state: !byte $ff

; Animation variables
anim_frame:     !byte 0        ; Current animation frame (0-3)
anim_timer:     !byte 0        ; Timer for animation speed
facing_direction: !byte 0      ; 0=right, 1=left (stored but not used yet)

; Position lookup tables
x_positions:
        !byte 28, 54, 80, 106, 132, 158, 184, 210, 236, 6, 32, 58

x_msb_flags:
        !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1

y_positions:
        !byte 55, 77, 99, 121, 143, 165, 187, 209

; Messages
status_msg:
        !byte 1,14,9,13,1,20,5,4,32,13,15,22,5,13,5,14,20  ; "ANIMATED MOVEMENT"
        !byte 0

; Sprite frames - Simple walking animation
*=$0340
; Frame 0 - Idle (standing)
sprite_frame_0:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%11111111,%00000000

*=$0380
; Frame 1 - Walk cycle 1 (left leg forward)
sprite_frame_1:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%10000011,%00000000
        !byte %00000011,%00000001,%10000000
        !byte %00000110,%00000000,%11000000
        !byte %00001100,%00000000,%01100000

*=$03C0
; Frame 2 - Walk cycle 2 (both legs together)
sprite_frame_2:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000

*=$0400
; Frame 3 - Walk cycle 3 (right leg forward)
sprite_frame_3:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000000,%11000001,%10000000
        !byte %00000001,%10000011,%00000000
        !byte %00000011,%00000000,%11000000
        !byte %00000110,%00000000,%01100000

;===============================================================================
; LEFT-FACING SPRITE FRAMES (Mirrored versions)
;===============================================================================
; These are horizontally flipped versions of the right-facing sprites
; This demonstrates solution #1 to C64's lack of hardware flipping

*=$0440
; Frame 4 - Idle (left-facing)
sprite_frame_4:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000

*=$0480
; Frame 5 - Walk cycle 1 (left-facing, right leg forward)
sprite_frame_5:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%10000011,%00000000
        !byte %00000000,%11000110,%00000000
        !byte %00000000,%01100011,%00000000
        !byte %00000000,%00110001,%10000000

*=$04C0
; Frame 6 - Walk cycle 2 (left-facing)
sprite_frame_6:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000
        !byte %00000000,%01100110,%00000000

*=$0500
; Frame 7 - Walk cycle 3 (left-facing, left leg forward)
sprite_frame_7:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%11111111,%00000000
        !byte %00000001,%10000011,%00000000
        !byte %00000000,%11000001,%10000000
        !byte %00000011,%00000000,%11000000
        !byte %00000110,%00000000,%01100000

;===============================================================================
; TECHNICAL NOTES
;===============================================================================
; Lesson 10 improvements:
; - 8 total animation frames (4 right-facing + 4 left-facing)
; - Animation cycles while moving (3 walk frames per direction)
; - Frame timing control (ANIM_SPEED)
; - Returns to idle frame when stopped
; - Sprite faces correct direction based on movement
;
; IMPORTANT C64 LIMITATION:
; The C64 has NO hardware sprite flipping! Common solutions:
; 1. Store mirrored sprite data (doubles memory usage) - OUR SOLUTION
; 2. Software flip routine (CPU intensive)
; 3. Use same sprite for both directions (simplest but unrealistic)
;
; We're using solution #1 - storing both left and right versions
; This is what most professional C64 games did!
; Memory usage: 64 bytes × 8 frames = 512 bytes total