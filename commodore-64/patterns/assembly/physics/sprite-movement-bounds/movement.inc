; A = pressed directions: bit 0 up, 1 down, 2 left, 3 right.
; Opposites cancel per axis; fire and other bits are ignored.
; State must start within X=24..320, Y=50..229. Two pixels per call.
; Clobbers A and flags; preserves X/Y. Owns sprite 0 position, not its modes.
MIN_X = 24
MAX_X = 320
MIN_Y = 50
MAX_Y = 229
MOVE_SPEED = 2

move_sprite:
    sta joy_state
    and #3
    cmp #1
    beq move_up
    cmp #2
    beq move_down
    jmp move_horizontal
move_up:
    lda sprite_y
    sec
    sbc #MOVE_SPEED
    cmp #MIN_Y
    bcs store_y
    lda #MIN_Y
    jmp store_y
move_down:
    lda sprite_y
    clc
    adc #MOVE_SPEED
    cmp #MAX_Y
    bcc store_y
    lda #MAX_Y
store_y:
    sta sprite_y
move_horizontal:
    lda joy_state
    and #12
    cmp #4
    beq move_left
    cmp #8
    beq move_right
    jmp update_sprite_pos
move_left:
    lda sprite_x_lo
    sec
    sbc #MOVE_SPEED
    sta sprite_x_lo
    lda sprite_x_hi
    sbc #0
    sta sprite_x_hi
    bne update_sprite_pos
    lda sprite_x_lo
    cmp #MIN_X
    bcs update_sprite_pos
    lda #MIN_X
    sta sprite_x_lo
    jmp update_sprite_pos
move_right:
    lda sprite_x_lo
    clc
    adc #MOVE_SPEED
    sta sprite_x_lo
    lda sprite_x_hi
    adc #0
    sta sprite_x_hi
    cmp #>MAX_X
    bcc update_sprite_pos
    bne clamp_right
    lda sprite_x_lo
    cmp #<MAX_X
    bcc update_sprite_pos
clamp_right:
    lda #<MAX_X
    sta sprite_x_lo
    lda #>MAX_X
    sta sprite_x_hi
update_sprite_pos:
    lda sprite_x_lo
    sta $d000
    lda sprite_y
    sta $d001
    lda $d010
    and #$fe
    ora sprite_x_hi
    sta $d010
    rts
movement_end:

sprite_x_lo: !byte 160
sprite_x_hi: !byte 0
sprite_y:    !byte 140
joy_state:   !byte 0
