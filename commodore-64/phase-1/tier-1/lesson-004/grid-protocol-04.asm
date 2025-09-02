; GRID PROTOCOL: Basic Sprite Movement
; Lesson 4 - Smooth, responsive sprite movement with variables
; Year: 2085 - Post-Collapse Era
;
; Objective: Enhanced entity control with position tracking
; Output: Smooth sprite movement with position variables

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-04.prg", cbm

;===============================================================================
; GATEWAY PROTOCOL (BASIC STUB)
;===============================================================================
*=$0801
        !byte $0b,$08          ; Next line pointer
        !byte $0a,$00          ; Line number: 10
        !byte $9e              ; SYS token
        !byte $32,$30,$36,$31  ; "2061" as PETSCII
        !byte $00              ; End of line
        !byte $00,$00          ; End of program

;===============================================================================
; GRID INITIALIZATION
;===============================================================================
*=$080d
grid_init:
        ; Activate terminal visuals
        lda #$00               ; Black void
        sta $d021
        lda #$03               ; Cyan signature
        sta $d020
        
        ; Purge data matrix
        jsr clear_screen
        
        ; Display status
        ldx #0
show_status:
        lda status_msg,x
        beq show_position_label
        sta $0400+22*40+11,x   ; Row 22, centered (17 chars)
        inx
        jmp show_status
        
show_position_label:
        ; Display position label
        ldx #0
pos_label_loop:
        lda position_label,x
        beq deploy_start
        sta $0400+24*40+12,x   ; Row 24, bottom
        inx
        jmp pos_label_loop

;===============================================================================
; ENTITY DEPLOYMENT
;===============================================================================
deploy_start:
        ; Initialize sprite position variables
        lda #160
        sta sprite_x
        lda #0
        sta sprite_x_msb
        lda #150
        sta sprite_y
        
        jsr deploy_entity
        jsr update_sprite_position
        
        ; Main control loop
control_loop:
        jsr wait_frame
        jsr read_joystick      ; Read operator input
        jsr move_sprite        ; Apply movement with variables
        jsr update_sprite_position ; Update hardware from variables
        jsr display_position   ; Show current position
        jmp control_loop

;===============================================================================
; SUBROUTINES
;===============================================================================

; Deploy entity
deploy_entity:
        ; Set entity data pointer
        lda #$0d               ; $0340
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

; Read joystick input (port 2)
read_joystick:
        lda $dc00              ; CIA1 Port A (joystick 2)
        sta joystick_state
        rts

; Move sprite based on input
move_sprite:
        ; Check up (bit 0)
        lda joystick_state
        and #$01
        bne check_down
        
        ; Move up
        lda sprite_y
        sec
        sbc #2                 ; Move 2 pixels for smooth movement
        cmp #50                ; Top boundary
        bcc check_down         ; Skip if too high
        sta sprite_y
        
check_down:
        ; Check down (bit 1)
        lda joystick_state
        and #$02
        bne check_left
        
        ; Move down
        lda sprite_y
        clc
        adc #2                 ; Move 2 pixels for smooth movement
        cmp #230               ; Bottom boundary
        bcs check_left         ; Skip if too low
        sta sprite_y
        
check_left:
        ; Check left (bit 2)
        lda joystick_state
        and #$04
        bne check_right
        
        ; Move left with MSB handling
        lda sprite_x
        sec
        sbc #2                 ; Move 2 pixels for smooth movement
        sta sprite_x
        bcs check_right        ; No underflow, continue
        
        ; Handle X underflow - toggle MSB
        lda sprite_x_msb
        eor #$01
        sta sprite_x_msb
        
check_right:
        ; Check right (bit 3)
        lda joystick_state
        and #$08
        bne move_done
        
        ; Move right with MSB handling
        lda sprite_x
        clc
        adc #2                 ; Move 2 pixels for smooth movement
        sta sprite_x
        bcc move_done          ; No overflow, done
        
        ; Handle X overflow - toggle MSB
        lda sprite_x_msb
        eor #$01
        sta sprite_x_msb
        
move_done:
        rts

; Update sprite position from variables
update_sprite_position:
        ; Set X position
        lda sprite_x
        sta $d000              ; Sprite 0 X position
        
        ; Set Y position
        lda sprite_y
        sta $d001              ; Sprite 0 Y position
        
        ; Set X MSB
        lda sprite_x_msb
        sta $d010              ; Sprite X MSB register
        
        rts

; Display current position
display_position:
        ; Convert X to decimal and display
        lda sprite_x
        jsr byte_to_decimal
        
        ; Display X position
        lda decimal_hundreds
        ora #$30               ; Convert to PETSCII
        sta $0400+24*40+22     ; Row 24, after "COORDS: X="
        lda decimal_tens
        ora #$30
        sta $0400+24*40+23
        lda decimal_ones
        ora #$30
        sta $0400+24*40+24
        
        ; Display Y position
        lda sprite_y
        jsr byte_to_decimal
        
        lda decimal_hundreds
        ora #$30
        sta $0400+24*40+29     ; After " Y="
        lda decimal_tens
        ora #$30
        sta $0400+24*40+30
        lda decimal_ones
        ora #$30
        sta $0400+24*40+31
        
        rts

; Convert byte to decimal
byte_to_decimal:
        ldx #0
        stx decimal_hundreds
        stx decimal_tens
        stx decimal_ones
        
        ; Hundreds
hundreds_loop:
        cmp #100
        bcc tens_start
        sec
        sbc #100
        inc decimal_hundreds
        jmp hundreds_loop
        
tens_start:
        ; Tens
tens_loop:
        cmp #10
        bcc ones_start
        sec
        sbc #10
        inc decimal_tens
        jmp tens_loop
        
ones_start:
        ; Ones
        sta decimal_ones
        rts

; Clear screen
clear_screen:
        ldx #0
clear_loop:
        lda #$20               ; Space
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

; Wait for frame
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
sprite_x:
        !byte 0
        
sprite_y:
        !byte 0
        
sprite_x_msb:
        !byte 0

; Control state
joystick_state:
        !byte $ff

; Decimal conversion
decimal_hundreds:
        !byte 0
decimal_tens:
        !byte 0
decimal_ones:
        !byte 0

; Messages (screen codes)
status_msg:
        !byte 5,14,8,1,14,3,5,4,32,20,18,1,3,11,9,14,7  ; "ENHANCED TRACKING"
        !byte 0

position_label:
        !byte 3,15,15,18,4,19,58,32,24,61             ; "COORDS: X="
        !byte 32,32,32,32,25,61,32,32,32              ; "    Y=   "
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
; Lesson 4 improvements over Lesson 3:
; - Position stored in variables (sprite_x, sprite_y, sprite_x_msb)
; - Cleaner code organization with separate move and update routines
; - Real-time position display showing exact coordinates
; - Smooth 2-pixel movement for better responsiveness
; - Better visual feedback with position tracking