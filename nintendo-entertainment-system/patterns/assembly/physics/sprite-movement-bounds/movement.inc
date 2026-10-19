; =============================================================================
; SPRITE MOVEMENT WITH BOUNDS - NES
; Move player sprite with screen boundary clamping
; Taught: Game 1 (Neon Nexus), Unit 2
; =============================================================================

; Controller button masks
BTN_UP     = %00001000
BTN_DOWN   = %00000100
BTN_LEFT   = %00000010
BTN_RIGHT  = %00000001

; Movement speed
PLAYER_SPEED = 2                ; Pixels per frame

; Screen boundaries (accounting for 8x8 sprite)
SCREEN_LEFT   = 0
SCREEN_RIGHT  = 248             ; 256 - 8 (sprite width)
SCREEN_TOP    = 0
SCREEN_BOTTOM = 224             ; chosen lower margin; stored OAM Y is one less than visible Y

.segment "ZEROPAGE"
player_x:    .res 1
player_y:    .res 1
buttons:     .res 1

.segment "CODE"

; player_x=0..248, player_y=0..224 on entry; initialise these and buttons.
; Changes A/flags, preserves X/Y. Bounds are inclusive. Sequential order is
; up, down, left, right; opposing inputs can be asymmetric at an edge.
; This owns the three declared ZP bytes. Call once after sampling input.
move_player:
    lda buttons
    and #BTN_UP
    beq @check_down
    lda player_y
    sec
    sbc #PLAYER_SPEED
    bcc @clamp_up
    cmp #SCREEN_TOP
    bcs @store_up
@clamp_up:
    lda #SCREEN_TOP
@store_up:
    sta player_y
@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_left
    lda player_y
    clc
    adc #PLAYER_SPEED
    bcs @clamp_down
    cmp #SCREEN_BOTTOM
    bcc @store_down
@clamp_down:
    lda #SCREEN_BOTTOM
@store_down:
    sta player_y
@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_right
    lda player_x
    sec
    sbc #PLAYER_SPEED
    bcc @clamp_left
    cmp #SCREEN_LEFT
    bcs @store_left
@clamp_left:
    lda #SCREEN_LEFT
@store_left:
    sta player_x
@check_right:
    lda buttons
    and #BTN_RIGHT
    beq @done
    lda player_x
    clc
    adc #PLAYER_SPEED
    bcs @clamp_right
    cmp #SCREEN_RIGHT
    bcc @store_right
@clamp_right:
    lda #SCREEN_RIGHT
@store_right:
    sta player_x
@done:
    rts
