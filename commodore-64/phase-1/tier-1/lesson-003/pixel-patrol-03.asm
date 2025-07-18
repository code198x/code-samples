; Pixel Patrol - Lesson 3: Joystick Control
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-003

; Target: Commodore 64
; Assembler: ACME
; Outcome: Blue screen with white border and player-controlled sprite

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
        ldx #0                 ; Start at position 0
clear_screen:
        lda #$20               ; Space character
        sta $0400,x            ; Store in screen memory
        sta $0500,x            ; Store in screen memory page 2
        sta $0600,x            ; Store in screen memory page 3
        sta $0700,x            ; Store in screen memory page 4
        
        ; Set character colors to white
        lda #$01               ; White color
        sta $d800,x            ; Store in color memory
        sta $d900,x            ; Store in color memory page 2
        sta $da00,x            ; Store in color memory page 3
        sta $db00,x            ; Store in color memory page 4
        
        inx                    ; Next position
        bne clear_screen       ; Continue until X wraps to 0
        
        ; Clear the remaining 24 bytes
        ldx #$e8               ; Start at position 232
clear_remaining:
        lda #$20               ; Space character
        sta $0700,x            ; Store in screen memory
        lda #$01               ; White color
        sta $db00,x            ; Store in color memory
        inx                    ; Next position
        cpx #$00               ; Check if we've cleared all
        bne clear_remaining    ; Continue until done
        
        ; Display title text
        ldx #0                 ; Start at position 0
display_title:
        lda title_text,x       ; Load character from title
        beq title_done         ; If zero, we're done
        sta $0400 + 40*5 + 8,x ; Store at row 5, column 8
        inx                    ; Next character
        jmp display_title      ; Continue
title_done:

        ; Display instructions
        ldx #0                 ; Start at position 0
display_instructions:
        lda instruction_text,x ; Load character from instructions
        beq instructions_done  ; If zero, we're done
        sta $0400 + 40*7 + 6,x ; Store at row 7, column 6
        inx                    ; Next character
        jmp display_instructions ; Continue
instructions_done:

        ; Set up our sprite data
        jsr setup_sprite

        ; Enable sprite 0
        lda #$01               ; Enable sprite 0
        sta $d015              ; VIC-II sprite enable register
        
        ; Set sprite 0 color to yellow
        lda #$07               ; Yellow color
        sta $d027              ; VIC-II sprite 0 color register
        
        ; Set initial sprite position (center screen)
        lda #160               ; X position (center)
        sta $d000              ; VIC-II sprite 0 X position
        lda #0                 ; X position (high bit)
        sta $d010              ; VIC-II sprite X MSB register
        
        lda #120               ; Y position (center)
        sta $d001              ; VIC-II sprite 0 Y position

        ; Main game loop
game_loop:
        jsr read_joystick      ; Read joystick input
        jsr move_sprite        ; Move sprite based on input
        jsr wait_frame         ; Wait for next frame
        jmp game_loop          ; Continue forever

;===============================================================================
; SUBROUTINES
;===============================================================================

setup_sprite:
        ; Set sprite 0 data pointer
        lda #$0d               ; Sprite data at $0340 (13 * 64)
        sta $07f8              ; Sprite 0 data pointer
        
        ; Copy sprite data to sprite memory
        ldx #0
copy_sprite:
        lda sprite_data,x      ; Load sprite data
        sta $0340,x            ; Store in sprite memory
        inx                    ; Next byte
        cpx #63                ; 63 bytes per sprite
        bne copy_sprite        ; Continue until done
        
        rts

read_joystick:
        ; Read joystick port 2 (CIA1 Port A)
        lda $dc00              ; Read CIA1 Port A
        sta joystick_state     ; Store current state
        
        ; Also check keyboard for QAOP controls
        ; Q = Up, A = Down, O = Left, P = Right
        
        ; Check Q key (Up) - Row 7, Bit 6
        lda #%01111111         ; Select row 7
        sta $dc00              ; Set CIA1 Port A
        lda $dc01              ; Read CIA1 Port B
        and #%01000000         ; Check bit 6 (Q)
        bne not_q              ; If bit set, key not pressed
        lda joystick_state     ; Get current state
        and #%11111110         ; Clear bit 0 (Up)
        sta joystick_state     ; Store updated state
not_q:
        
        ; Check A key (Down) - Row 1, Bit 2
        lda #%11111101         ; Select row 1
        sta $dc00              ; Set CIA1 Port A
        lda $dc01              ; Read CIA1 Port B
        and #%00000100         ; Check bit 2 (A)
        bne not_a              ; If bit set, key not pressed
        lda joystick_state     ; Get current state
        and #%11111101         ; Clear bit 1 (Down)
        sta joystick_state     ; Store updated state
not_a:
        
        ; Check O key (Left) - Row 3, Bit 6
        lda #%11110111         ; Select row 3
        sta $dc00              ; Set CIA1 Port A
        lda $dc01              ; Read CIA1 Port B
        and #%01000000         ; Check bit 6 (O)
        bne not_o              ; If bit set, key not pressed
        lda joystick_state     ; Get current state
        and #%11111011         ; Clear bit 2 (Left)
        sta joystick_state     ; Store updated state
not_o:
        
        ; Check P key (Right) - Row 1, Bit 5
        lda #%11111101         ; Select row 1
        sta $dc00              ; Set CIA1 Port A
        lda $dc01              ; Read CIA1 Port B
        and #%00100000         ; Check bit 5 (P)
        bne not_p              ; If bit set, key not pressed
        lda joystick_state     ; Get current state
        and #%11110111         ; Clear bit 3 (Right)
        sta joystick_state     ; Store updated state
not_p:
        
        ; Restore CIA1 Port A
        lda #$ff               ; All bits high
        sta $dc00              ; Restore CIA1 Port A
        
        rts

move_sprite:
        ; Check Up (bit 0 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$01               ; Check bit 0 (Up)
        bne check_down         ; If bit set, not pressed
        
        ; Move up
        lda $d001              ; Get current Y position
        sec                    ; Set carry
        sbc #2                 ; Subtract 2 (move up)
        cmp #50                ; Check top boundary
        bcc no_move_up         ; If less than 50, don't move
        sta $d001              ; Store new Y position
no_move_up:

check_down:
        ; Check Down (bit 1 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$02               ; Check bit 1 (Down)
        bne check_left         ; If bit set, not pressed
        
        ; Move down
        lda $d001              ; Get current Y position
        clc                    ; Clear carry
        adc #2                 ; Add 2 (move down)
        cmp #200               ; Check bottom boundary
        bcs no_move_down       ; If >= 200, don't move
        sta $d001              ; Store new Y position
no_move_down:

check_left:
        ; Check Left (bit 2 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$04               ; Check bit 2 (Left)
        bne check_right        ; If bit set, not pressed
        
        ; Move left
        lda $d000              ; Get current X position
        sec                    ; Set carry
        sbc #2                 ; Subtract 2 (move left)
        cmp #24                ; Check left boundary
        bcc no_move_left       ; If less than 24, don't move
        sta $d000              ; Store new X position
no_move_left:

check_right:
        ; Check Right (bit 3 clear means pressed)
        lda joystick_state     ; Get joystick state
        and #$08               ; Check bit 3 (Right)
        bne movement_done      ; If bit set, not pressed
        
        ; Move right
        lda $d000              ; Get current X position
        clc                    ; Clear carry
        adc #2                 ; Add 2 (move right)
        cmp #255               ; Check if we hit right boundary of low byte
        bcc store_new_x        ; If < 255, safe to store
        
        ; Check if we're already at max X position (320)
        lda $d010              ; Get X MSB register
        and #$01               ; Check sprite 0 MSB
        beq store_new_x        ; If MSB=0, we can continue
        
        ; We're at high X values, check exact boundary
        lda $d000              ; Get current X position
        cmp #64                ; Check if >= 320 (64 + 256)
        bcs no_move_right      ; If >= 320, don't move
        
store_new_x:
        lda $d000              ; Get current X position again
        clc                    ; Clear carry
        adc #2                 ; Add 2 (move right)
        sta $d000              ; Store new X position
        
        ; Handle X MSB wraparound
        bcc no_move_right      ; If no carry, no MSB change needed
        lda $d010              ; Get X MSB register
        ora #$01               ; Set bit 0 (sprite 0 X MSB)
        sta $d010              ; Store back
        
no_move_right:
movement_done:
        rts

wait_frame:
        ; Wait for raster line 250 (bottom of screen)
wait_raster:
        lda $d012              ; Read raster line
        cmp #250               ; Compare with line 250
        bne wait_raster        ; If not there, keep waiting
        rts

;===============================================================================
; DATA
;===============================================================================
title_text:
        ; Screen codes for "PIXEL PATROL - LESSON 3"
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,51
        !byte 0                ; Null terminator

instruction_text:
        ; Screen codes for "USE JOYSTICK OR QAOP KEYS"
        !byte 21,19,5,32,10,15,25,19,20,9,3,11,32,15,18,32,17,1,15,16,32,11,5,25,19
        !byte 0                ; Null terminator

sprite_data:
        ; A simple 24x21 sprite - a spaceship
        !byte %00000000, %01111110, %00000000  ; Row 1 - nose
        !byte %00000000, %11111111, %00000000  ; Row 2
        !byte %00000001, %11111111, %10000000  ; Row 3
        !byte %00000011, %11111111, %11000000  ; Row 4
        !byte %00000111, %11111111, %11100000  ; Row 5
        !byte %00001111, %11111111, %11110000  ; Row 6
        !byte %00011111, %11111111, %11111000  ; Row 7
        !byte %00111111, %11111111, %11111100  ; Row 8
        !byte %01111111, %11111111, %11111110  ; Row 9
        !byte %11111111, %11111111, %11111111  ; Row 10 - body
        !byte %11111111, %11111111, %11111111  ; Row 11
        !byte %11111111, %11111111, %11111111  ; Row 12
        !byte %11111111, %11111111, %11111111  ; Row 13
        !byte %11111111, %11111111, %11111111  ; Row 14
        !byte %11111111, %11111111, %11111111  ; Row 15
        !byte %11111111, %11111111, %11111111  ; Row 16
        !byte %01111111, %11111111, %11111110  ; Row 17
        !byte %00111111, %11111111, %11111100  ; Row 18
        !byte %11001111, %11111111, %11110011  ; Row 19 - engines
        !byte %11100111, %11111111, %11100111  ; Row 20
        !byte %11110000, %00000000, %00001111  ; Row 21 - engine flames
        !byte %00000000, %00000000, %00000000  ; Row 22 (padding)

; Variable storage
joystick_state:
        !byte $ff              ; Current joystick state (all bits high = no input)

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates C64 joystick and keyboard input:
;
; 1. JOYSTICK INPUT: The C64 supports 2 joysticks via CIA chip
;    - Joystick 1: CIA1 Port B ($DC01)
;    - Joystick 2: CIA1 Port A ($DC00)
;    - Bits: 0=Up, 1=Down, 2=Left, 3=Right, 4=Fire (0=pressed, 1=not pressed)
;    
; 2. KEYBOARD INPUT: Alternative QAOP controls
;    - Q = Up, A = Down, O = Left, P = Right
;    - Uses keyboard matrix scanning via CIA1
;    - Each key has a specific row/column position
;    
; 3. SPRITE MOVEMENT: Responsive player control
;    - 2-pixel movement per frame for smooth control
;    - Boundary checking prevents sprite from leaving screen
;    - Handles X coordinate MSB for positions > 255
;    
; 4. GAME LOOP STRUCTURE:
;    - Read input from joystick/keyboard
;    - Update sprite position based on input
;    - Wait for next frame (raster synchronization)
;    - Repeat forever
;
; 5. CIA CHIP FUNCTIONS:
;    - CIA1 ($DC00/$DC01): Keyboard matrix and joystick input
;    - CIA2 ($DD00/$DD01): Serial bus and user port
;    - Each CIA has two 8-bit I/O ports (Port A and Port B)
;
; LEARNING OBJECTIVES ACHIEVED:
; - Understand CIA chip input handling
; - Learn joystick input bit patterns
; - Implement keyboard matrix scanning
; - Create responsive sprite movement
; - Handle boundary checking and collision with screen edges
; - Build complete interactive game loop structure