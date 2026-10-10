; =============================================================================
; SPRITE MOVEMENT WITH BOUNDS - COMMODORE 64
; Move sprite with joystick and boundary clamping
; Taught: Game 2 (Parallax), Unit 2
; CPU: ~120 cycles | Memory: ~80 bytes
; =============================================================================

; VIC-II registers
VIC         = $D000
SPR0_X      = $D000             ; Sprite 0 X position (low 8 bits)
SPR0_Y      = $D001             ; Sprite 0 Y position
SPR_MSB     = $D010             ; Sprite X position MSB (bit 0 = sprite 0)

; Joystick port
JOY2        = $DC00             ; Joystick port 2

; Movement settings
MOVE_SPEED  = 2                 ; Pixels per frame

; Boundaries (visible screen area)
MIN_X       = 24                ; Left edge
MAX_X       = 320               ; Right edge (9-bit value)
MIN_Y       = 50                ; Top edge
MAX_Y       = 229               ; Bottom edge

; Move sprite 0 based on joystick input
move_sprite:
            lda JOY2            ; Read joystick (active low)
            eor #$FF            ; Invert so 1=pressed

            ; === Check Up (bit 0) ===
            lsr                 ; Bit 0 -> Carry
            bcc .no_up
            lda sprite_y
            sec
            sbc #MOVE_SPEED
            cmp #MIN_Y
            bcc .no_up          ; Past top
            sta sprite_y
.no_up:
            ; === Check Down (bit 1) ===
            lda JOY2
            eor #$FF
            and #$02
            beq .no_down
            lda sprite_y
            clc
            adc #MOVE_SPEED
            cmp #MAX_Y
            bcs .no_down        ; Past bottom
            sta sprite_y
.no_down:
            ; === Check Left (bit 2) ===
            lda JOY2
            eor #$FF
            and #$04
            beq .no_left
            jsr move_left
.no_left:
            ; === Check Right (bit 3) ===
            lda JOY2
            eor #$FF
            and #$08
            beq .no_right
            jsr move_right
.no_right:
            ; Update VIC-II registers
            jsr update_sprite_pos
            rts

; Move left (handle 9-bit X)
move_left:
            lda sprite_x_lo
            sec
            sbc #MOVE_SPEED
            sta sprite_x_lo
            lda sprite_x_hi
            sbc #0              ; Borrow from high byte
            sta sprite_x_hi

            ; Check minimum (24)
            lda sprite_x_hi
            bne .left_ok        ; High byte set = definitely > 255 > 24
            lda sprite_x_lo
            cmp #MIN_X
            bcs .left_ok

            ; Clamp to minimum
            lda #MIN_X
            sta sprite_x_lo
            lda #0
            sta sprite_x_hi
.left_ok:
            rts

; Move right (handle 9-bit X)
move_right:
            lda sprite_x_lo
            clc
            adc #MOVE_SPEED
            sta sprite_x_lo
            lda sprite_x_hi
            adc #0              ; Carry to high byte
            sta sprite_x_hi

            ; Check maximum (320 = $140)
            lda sprite_x_hi
            cmp #>MAX_X
            bcc .right_ok       ; High byte less = definitely ok
            bne .right_clamp    ; High byte greater = clamp
            lda sprite_x_lo
            cmp #<MAX_X
            bcc .right_ok

.right_clamp:
            lda #<MAX_X
            sta sprite_x_lo
            lda #>MAX_X
            sta sprite_x_hi
.right_ok:
            rts

; Copy position to VIC-II
update_sprite_pos:
            lda sprite_x_lo
            sta SPR0_X
            lda sprite_y
            sta SPR0_Y

            ; Set/clear MSB for sprite 0
            lda SPR_MSB
            and #$FE            ; Clear bit 0
            ora sprite_x_hi     ; Set if high byte is 1
            sta SPR_MSB
            rts

; Variables (16-bit X, 8-bit Y)
sprite_x_lo:    !byte 160       ; X position low byte
sprite_x_hi:    !byte 0         ; X position high byte (0 or 1)
sprite_y:       !byte 140       ; Y position
