; Pixel Patrol - Lesson 2: First Hardware Sprite
; Learn 6502 assembly programming through game development
; https://code198x.com/lessons/commodore-64/phase-1/tier-1/lesson-002

; Target: Commodore 64
; Assembler: ACME
; Outcome: Blue screen with white border and a moving sprite

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
        
        ; Clear the remaining 24 bytes (1000 - 256*3 = 232, but we only need 24 more)
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

        ; Set up our sprite data
        jsr setup_sprite

        ; Enable sprite 0
        lda #$01               ; Enable sprite 0
        sta $d015              ; VIC-II sprite enable register
        
        ; Set sprite 0 color to yellow
        lda #$07               ; Yellow color
        sta $d027              ; VIC-II sprite 0 color register
        
        ; Set initial sprite position
        lda #100               ; X position (low byte)
        sta $d000              ; VIC-II sprite 0 X position
        lda #0                 ; X position (high bit)
        sta $d010              ; VIC-II sprite X MSB register
        
        lda #100               ; Y position
        sta $d001              ; VIC-II sprite 0 Y position

        ; Main game loop
game_loop:
        jsr animate_sprite     ; Move the sprite
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

animate_sprite:
        ; Read current X position
        lda $d000              ; Get current X position
        clc                    ; Clear carry
        adc #1                 ; Add 1 to X position
        sta $d000              ; Store new X position
        
        ; Check if we need to handle X MSB
        cmp #$00               ; Did we wrap around?
        bne no_wrap            ; No, continue
        
        ; We wrapped, toggle X MSB
        lda $d010              ; Get X MSB register
        eor #$01               ; Toggle bit 0 (sprite 0 X MSB)
        sta $d010              ; Store back
        
no_wrap:
        ; Simple boundary check - reset if off screen
        lda $d000              ; Get X position
        cmp #$40               ; Compare with right edge
        bcc no_reset           ; If less, don't reset
        
        ; Check MSB too
        lda $d010              ; Get X MSB
        and #$01               ; Check sprite 0 MSB
        beq no_reset           ; If MSB=0, don't reset
        
        ; Reset sprite to left side
        lda #50                ; Start X position
        sta $d000              ; Store X position
        lda $d010              ; Get X MSB register
        and #$fe               ; Clear sprite 0 MSB
        sta $d010              ; Store back
        
no_reset:
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
        ; Screen codes for "PIXEL PATROL - LESSON 2"
        !byte 16,9,24,5,12,32,16,1,20,18,15,12,32,45,32,12,5,19,19,15,14,32,50
        !byte 0                ; Null terminator

sprite_data:
        ; A simple 24x21 sprite - a smiley face
        !byte %00000000, %11111111, %00000000  ; Row 1
        !byte %00000011, %11111111, %11000000  ; Row 2
        !byte %00001111, %11111111, %11110000  ; Row 3
        !byte %00011111, %11111111, %11111000  ; Row 4
        !byte %00111111, %11111111, %11111100  ; Row 5
        !byte %01111111, %11111111, %11111110  ; Row 6
        !byte %01111111, %11111111, %11111110  ; Row 7
        !byte %11111100, %11111111, %00111111  ; Row 8
        !byte %11111100, %11111111, %00111111  ; Row 9
        !byte %11111111, %11111111, %11111111  ; Row 10
        !byte %11111111, %11111111, %11111111  ; Row 11
        !byte %11111111, %11111111, %11111111  ; Row 12
        !byte %11111111, %11111111, %11111111  ; Row 13
        !byte %11111100, %00000000, %00111111  ; Row 14
        !byte %11111100, %00000000, %00111111  ; Row 15
        !byte %01111111, %00000000, %11111110  ; Row 16
        !byte %01111111, %11111111, %11111110  ; Row 17
        !byte %00111111, %11111111, %11111100  ; Row 18
        !byte %00011111, %11111111, %11111000  ; Row 19
        !byte %00001111, %11111111, %11110000  ; Row 20
        !byte %00000011, %11111111, %11000000  ; Row 21
        !byte %00000000, %00000000, %00000000  ; Row 22 (padding)

;===============================================================================
; EXPLANATION COMMENTS
;===============================================================================

; This program demonstrates C64 hardware sprites:
;
; 1. SPRITE SYSTEM: The C64 has 8 hardware sprites (0-7)
;    Each sprite is 24x21 pixels and can be positioned anywhere on screen
;    
; 2. SPRITE MEMORY: Sprites are stored in 64-byte blocks
;    Each sprite uses 63 bytes of data + 1 byte padding
;    Sprite data pointers at $07F8-$07FF tell VIC-II where to find sprite data
;    
; 3. SPRITE REGISTERS:
;    - $D015: Sprite enable register (bit 0 = sprite 0, bit 1 = sprite 1, etc.)
;    - $D000-$D001: Sprite 0 X/Y position
;    - $D010: Sprite X MSB register (for X positions > 255)
;    - $D027: Sprite 0 color
;    
; 4. SPRITE COORDINATES:
;    - X: 0-511 (needs MSB register for values > 255)
;    - Y: 0-255
;    - Sprites can move off-screen and wrap around
;    
; 5. SPRITE ANIMATION:
;    - Move sprite by changing X/Y position registers
;    - Synchronize with raster beam for smooth animation
;    - Use VBlank or specific raster line timing
;
; LEARNING OBJECTIVES ACHIEVED:
; - Understand C64 sprite system architecture
; - Learn sprite data format (24x21 pixels)
; - Control sprite position and color
; - Create smooth sprite animation
; - Handle sprite coordinate wraparound
; - Use raster synchronization for smooth movement