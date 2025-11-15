;===============================================================================
; Lesson 030: Sound Effects
; Add sound effects using APU pulse channels
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready:        .res 1
buttons:          .res 1
buttons_prev:     .res 1
buttons2:         .res 1
buttons2_prev:    .res 1
paddle_y:         .res 1
paddle_y_old:     .res 1
paddle2_y:        .res 1
paddle2_y_old:    .res 1
ball_x:           .res 1
ball_y:           .res 1
ball_dx:          .res 1
ball_dy:          .res 1
collision_timer:  .res 1
temp:             .res 1
score_p1:         .res 1
score_p2:         .res 1
digit_tens:       .res 1
digit_ones:       .res 1
score_changed:    .res 1
game_state:       .res 1

STATE_TITLE = 0
STATE_PLAYING = 1
STATE_GAMEOVER = 2

PADDLE_TOP = 8
PADDLE_BOTTOM = 216
PADDLE_SPEED = 3
PADDLE1_X = 16
PADDLE2_X = 232
PADDLE_WIDTH = 8
PADDLE_HEIGHT = 32
BALL_SIZE = 8
BALL_START_X = 128
BALL_START_Y = 120
SCREEN_TOP = 8
SCREEN_BOTTOM = 232
SCREEN_LEFT = 0
SCREEN_RIGHT = 248
COLLISION_COOLDOWN = 10
WIN_SCORE = 10

.segment "CODE"
Reset:
    SEI
    CLD
    BIT $2002
:   BIT $2002
    BPL :-
:   BIT $2002
    BPL :-
    LDX #$FF
    TXS

    JSR LoadPalettes
    JSR InitAPU          ; NEW - Initialize sound

    LDA #120
    STA paddle_y
    STA paddle_y_old
    STA paddle2_y
    STA paddle2_y_old
    LDA #BALL_START_X
    STA ball_x
    LDA #BALL_START_Y
    STA ball_y
    LDA #$FE
    STA ball_dx
    LDA #2
    STA ball_dy
    LDA #0
    STA collision_timer
    STA score_p1
    STA score_p2
    STA buttons_prev
    STA buttons2_prev
    LDA #STATE_TITLE
    STA game_state
    LDA #1
    STA score_changed

    JSR UpdateOAM

    LDX #$20
    LDA #$FF
:   STA $0200,X
    INX
    INX
    INX
    INX
    BNE :-

    LDA #%10100000
    STA $2000
    LDA #%00011110
    STA $2001

MainLoop:
:   LDA nmi_ready
    BEQ :-
    LDA #$00
    STA nmi_ready

    JSR ReadController
    JSR ReadController2

    LDA game_state
    CMP #STATE_TITLE
    BNE @check_playing
    JSR UpdateTitle
    JMP @done_state
@check_playing:
    CMP #STATE_PLAYING
    BNE @check_gameover
    JSR UpdatePlaying
    JMP @done_state
@check_gameover:
    JSR UpdateGameover

@done_state:
    JSR UpdateOAM
    JMP MainLoop

;===============================================================================
; InitAPU - Initialize Audio Processing Unit
;===============================================================================
InitAPU:
    ; Enable pulse 1 and pulse 2 channels
    LDA #%00000011
    STA $4015

    ; Set pulse 1 duty cycle (50%) and volume
    LDA #%10111111      ; 50% duty, constant volume, vol 15
    STA $4000

    ; Set pulse 2 duty cycle and volume
    LDA #%10111111
    STA $4004

    RTS

;===============================================================================
; PlayPaddleSound - "Pong" sound when ball hits paddle
;===============================================================================
PlayPaddleSound:
    ; Pulse 1: mid frequency, short envelope
    LDA #%10111111      ; 50% duty, constant volume
    STA $4000
    LDA #%00000000      ; No sweep
    STA $4001
    LDA #$A0            ; Low byte frequency (mid tone)
    STA $4002
    LDA #%00001000      ; High byte frequency + length counter
    STA $4003
    RTS

;===============================================================================
; PlayWallSound - "Ping" sound when ball hits wall
;===============================================================================
PlayWallSound:
    ; Pulse 1: high frequency, very short
    LDA #%10111111
    STA $4000
    LDA #%00000000
    STA $4001
    LDA #$50            ; Higher frequency
    STA $4002
    LDA #%00000100      ; Shorter duration
    STA $4003
    RTS

;===============================================================================
; PlayScoreSound - Descending "boop" when someone scores
;===============================================================================
PlayScoreSound:
    ; Pulse 2: descending sweep
    LDA #%10111111
    STA $4004
    LDA #%10011000      ; Enable sweep, descending
    STA $4005
    LDA #$80            ; Start frequency
    STA $4006
    LDA #%00001100      ; Medium duration
    STA $4007
    RTS

UpdateTitle:
    LDA buttons
    AND #%00010000
    BEQ @no_start
    LDA buttons_prev
    AND #%00010000
    BNE @no_start

    LDA #STATE_PLAYING
    STA game_state
    LDA #0
    STA score_p1
    STA score_p2
    LDA #1
    STA score_changed
    LDA #BALL_START_X
    STA ball_x
    LDA #BALL_START_Y
    STA ball_y
    LDA #$FE
    STA ball_dx
    LDA #2
    STA ball_dy

@no_start:
    RTS

UpdatePlaying:
    JSR UpdatePaddle
    JSR UpdatePaddle2
    JSR UpdateBall
    JSR CheckScoring
    JSR UpdateCollisionTimer
    JSR CheckPaddleCollision
    JSR CheckPaddle2Collision

    LDA score_p1
    CMP #WIN_SCORE
    BEQ @game_over
    LDA score_p2
    CMP #WIN_SCORE
    BEQ @game_over
    RTS

@game_over:
    LDA #STATE_GAMEOVER
    STA game_state
    RTS

UpdateGameover:
    LDA buttons
    AND #%00010000
    BEQ @no_start
    LDA buttons_prev
    AND #%00010000
    BNE @no_start

    LDA #STATE_TITLE
    STA game_state
    LDA #0
    STA score_p1
    STA score_p2
    LDA #1
    STA score_changed

@no_start:
    RTS

UpdatePaddle2:
    LDA paddle2_y
    STA paddle2_y_old
    PHA
    LDA buttons2
    AND #%00001000
    BEQ :+
    LDA paddle2_y
    SEC
    SBC #PADDLE_SPEED
    STA paddle2_y
:   LDA buttons2
    AND #%00000100
    BEQ :+
    LDA paddle2_y
    CLC
    ADC #PADDLE_SPEED
    STA paddle2_y
:   LDA buttons2
    AND #%00001100
    CMP #%00001100
    BNE :+
    PLA
    STA paddle2_y
    JMP :++
:   PLA
    LDA paddle2_y
    CMP #PADDLE_TOP
    BCS :+
    LDA #PADDLE_TOP
    STA paddle2_y
:   LDA paddle2_y
    CMP #PADDLE_BOTTOM
    BCC :+
    LDA #PADDLE_BOTTOM
    STA paddle2_y
:   RTS

CheckPaddle2Collision:
    LDA collision_timer
    BNE @no_collision

    LDA ball_x
    CLC
    ADC #BALL_SIZE
    CMP #PADDLE2_X
    BCC @no_collision

    LDA ball_x
    CMP #(PADDLE2_X + PADDLE_WIDTH)
    BCS @no_collision

    LDA ball_y
    CLC
    ADC #BALL_SIZE
    CMP paddle2_y
    BCC @no_collision

    LDA paddle2_y
    CLC
    ADC #PADDLE_HEIGHT
    CMP ball_y
    BCC @no_collision

    ; Collision detected - play sound!
    JSR PlayPaddleSound  ; NEW

    LDA #COLLISION_COOLDOWN
    STA collision_timer

    LDA ball_y
    SEC
    SBC paddle2_y
    STA temp

    LDA ball_dx
    EOR #$FF
    CLC
    ADC #1
    STA ball_dx

    LDA temp
    CMP #11
    BCS @check_middle
    LDA #$FE
    STA ball_dy
    JMP @add_momentum
@check_middle:
    CMP #22
    BCS @bottom_third
    LDA #$00
    STA ball_dy
    JMP @add_momentum
@bottom_third:
    LDA #$02
    STA ball_dy

@add_momentum:
    LDA paddle2_y
    SEC
    SBC paddle2_y_old
    CLC
    ADC ball_dy
    STA ball_dy
    LDA ball_dy
    CMP #$FC
    BCS @clamp_max
    LDA #$FC
    STA ball_dy
    JMP @done
@clamp_max:
    LDA ball_dy
    CMP #$05
    BCC @done
    LDA #$04
    STA ball_dy
@done:
    LDA #(PADDLE2_X - BALL_SIZE - 1)
    STA ball_x
@no_collision:
    RTS

UpdateScoreDisplay:
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$4A
    STA $2006

    LDA score_p1
    JSR DecimalToTiles

    LDA digit_tens
    STA $2007
    LDA digit_ones
    STA $2007

    LDA #$20
    STA $2006
    LDA #$54
    STA $2006

    LDA score_p2
    JSR DecimalToTiles

    LDA digit_tens
    STA $2007
    LDA digit_ones
    STA $2007

    LDA game_state
    CMP #STATE_TITLE
    BNE @check_gameover
    JSR DrawTitleMessage
    JMP @done_messages

@check_gameover:
    CMP #STATE_GAMEOVER
    BNE @done_messages
    JSR DrawGameoverMessage

@done_messages:
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    RTS

DrawTitleMessage:
    LDA #$21
    STA $2006
    LDA #$CA
    STA $2006

    LDX #0
@loop:
    LDA msg_press_start,X
    STA $2007
    INX
    CPX #11
    BNE @loop
    RTS

msg_press_start:
    .byte $50,$52,$45,$53,$53,$20,$53,$54,$41,$52,$54

DrawGameoverMessage:
    LDA #$21
    STA $2006
    LDA #$CB
    STA $2006

    LDX #0
@loop:
    LDA msg_game_over,X
    STA $2007
    INX
    CPX #9
    BNE @loop
    RTS

msg_game_over:
    .byte $47,$41,$4D,$45,$20,$4F,$56,$45,$52

DecimalToTiles:
    LDX #0
@count_tens:
    CMP #10
    BCC @done_tens
    SBC #10
    INX
    JMP @count_tens
@done_tens:
    STA digit_ones
    STX digit_tens
    LDA digit_tens
    CLC
    ADC #$30
    STA digit_tens
    LDA digit_ones
    CLC
    ADC #$30
    STA digit_ones
    RTS

CheckScoring:
    LDA ball_x
    CMP #SCREEN_LEFT
    BNE @check_right

    INC score_p2
    LDA #1
    STA score_changed
    JSR PlayScoreSound   ; NEW
    JMP @reset_ball

@check_right:
    LDA ball_x
    CMP #SCREEN_RIGHT
    BCC @done

    INC score_p1
    LDA #1
    STA score_changed
    JSR PlayScoreSound   ; NEW

@reset_ball:
    LDA #BALL_START_X
    STA ball_x
    LDA #BALL_START_Y
    STA ball_y
    LDA #$FE
    STA ball_dx
    LDA #2
    STA ball_dy

@done:
    RTS

UpdateCollisionTimer:
    LDA collision_timer
    BEQ :+
    DEC collision_timer
:   RTS

CheckPaddleCollision:
    LDA collision_timer
    BNE @no_collision
    LDA ball_x
    CMP #(PADDLE1_X + PADDLE_WIDTH)
    BCS @no_collision
    CMP #PADDLE1_X
    BCC @no_collision
    LDA ball_y
    CLC
    ADC #BALL_SIZE
    CMP paddle_y
    BCC @no_collision
    LDA paddle_y
    CLC
    ADC #PADDLE_HEIGHT
    CMP ball_y
    BCC @no_collision

    ; Collision detected - play sound!
    JSR PlayPaddleSound  ; NEW

    LDA #COLLISION_COOLDOWN
    STA collision_timer
    LDA ball_y
    SEC
    SBC paddle_y
    STA temp
    LDA ball_dx
    EOR #$FF
    CLC
    ADC #1
    STA ball_dx

    LDA temp
    CMP #11
    BCS @check_middle
    LDA #$FE
    STA ball_dy
    JMP @add_momentum
@check_middle:
    CMP #22
    BCS @bottom_third
    LDA #$00
    STA ball_dy
    JMP @add_momentum
@bottom_third:
    LDA #$02
    STA ball_dy

@add_momentum:
    LDA paddle_y
    SEC
    SBC paddle_y_old
    CLC
    ADC ball_dy
    STA ball_dy
    LDA ball_dy
    CMP #$FC
    BCS @clamp_max
    LDA #$FC
    STA ball_dy
    JMP @done
@clamp_max:
    LDA ball_dy
    CMP #$05
    BCC @done
    LDA #$04
    STA ball_dy
@done:
    LDA #(PADDLE1_X + PADDLE_WIDTH + 1)
    STA ball_x
@no_collision:
    RTS

UpdateBall:
    LDA ball_x
    CLC
    ADC ball_dx
    STA ball_x
    LDA ball_y
    CLC
    ADC ball_dy
    STA ball_y

    ; Check top wall collision
    LDA ball_y
    CMP #SCREEN_TOP
    BCS @check_bottom
    LDA #SCREEN_TOP
    STA ball_y
    LDA ball_dy
    EOR #$FF
    CLC
    ADC #1
    STA ball_dy
    JSR PlayWallSound    ; NEW

@check_bottom:
    LDA ball_y
    CMP #SCREEN_BOTTOM
    BCC @done
    LDA #SCREEN_BOTTOM
    STA ball_y
    LDA ball_dy
    EOR #$FF
    CLC
    ADC #1
    STA ball_dy
    JSR PlayWallSound    ; NEW

@done:
    RTS

UpdatePaddle:
    LDA paddle_y
    STA paddle_y_old
    PHA
    LDA buttons
    AND #%00001000
    BEQ :+
    LDA paddle_y
    SEC
    SBC #PADDLE_SPEED
    STA paddle_y
:   LDA buttons
    AND #%00000100
    BEQ :+
    LDA paddle_y
    CLC
    ADC #PADDLE_SPEED
    STA paddle_y
:   LDA buttons
    AND #%00001100
    CMP #%00001100
    BNE :+
    PLA
    STA paddle_y
    JMP :++
:   PLA
    LDA paddle_y
    CMP #PADDLE_TOP
    BCS :+
    LDA #PADDLE_TOP
    STA paddle_y
:   LDA paddle_y
    CMP #PADDLE_BOTTOM
    BCC :+
    LDA #PADDLE_BOTTOM
    STA paddle_y
:   RTS

ReadController:
    LDA buttons
    STA buttons_prev
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016
    LDX #$08
:   LDA $4016
    LSR
    ROL buttons
    DEX
    BNE :-
    RTS

ReadController2:
    LDA buttons2
    STA buttons2_prev
    LDX #$08
:   LDA $4017
    LSR
    ROL buttons2
    DEX
    BNE :-
    RTS

NMI:
    PHA
    TXA
    PHA
    TYA
    PHA

    LDA score_changed
    BEQ @skip_score_update
    JSR UpdateScoreDisplay
    LDA #0
    STA score_changed
@skip_score_update:

    LDA #$02
    STA $4014

    LDA #$01
    STA nmi_ready

    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

UpdateOAM:
    LDX #$00
    LDY #$00
@paddle1_loop:
    LDA paddle_y
    CLC
    ADC table_offset,Y
    STA $0200,X
    LDA #$00
    STA $0201,X
    LDA #%00000001
    STA $0202,X
    LDA #PADDLE1_X
    STA $0203,X
    INX
    INX
    INX
    INX
    INY
    CPY #$04
    BNE @paddle1_loop

    LDY #$00
@paddle2_loop:
    LDA paddle2_y
    CLC
    ADC table_offset,Y
    STA $0200,X
    LDA #$00
    STA $0201,X
    LDA #%00000010
    STA $0202,X
    LDA #PADDLE2_X
    STA $0203,X
    INX
    INX
    INX
    INX
    INY
    CPY #$04
    BNE @paddle2_loop

    LDA game_state
    CMP #STATE_PLAYING
    BNE @hide_ball

    LDA ball_y
    STA $0220
    LDA #$01
    STA $0221
    LDA #%00000001
    STA $0222
    LDA ball_x
    STA $0223
    RTS

@hide_ball:
    LDA #$FF
    STA $0220
    RTS

table_offset:
    .byte 0, 8, 16, 24

LoadPalettes:
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
:   LDA Palettes,X
    STA $2007
    INX
    CPX #$20
    BNE :-
    RTS

IRQ:
    RTI

.segment "RODATA"
Palettes:
    .byte $0F, $00, $30, $10, $0F, $00, $30, $10
    .byte $0F, $00, $30, $10, $0F, $00, $30, $10
    .byte $0F, $16, $27, $18, $0F, $1A, $30, $27
    .byte $0F, $16, $30, $27, $0F, $0F, $30, $10

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    .res 48*16, $00
    .byte $3C,$66,$6E,$76,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $18,$38,$18,$18,$18,$18,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$66,$06,$0C,$18,$30,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$66,$06,$1C,$06,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $0C,$1C,$3C,$6C,$7E,$0C,$0C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $7E,$60,$7C,$06,$06,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$60,$60,$7C,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $7E,$06,$0C,$18,$30,$30,$30,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$66,$66,$3C,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$66,$66,$3E,$06,$0C,$38,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 7*16, $00
    .byte $3C,$66,$66,$7E,$66,$66,$66,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 4*16, $00
    .byte $7E,$60,$60,$7C,$60,$60,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 1*16, $00
    .byte $3C,$66,$60,$6E,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 7*16, $00
    .byte $3C,$66,$66,$66,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $7C,$66,$66,$7C,$60,$60,$60,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 1*16, $00
    .byte $7C,$66,$66,$7C,$6C,$66,$66,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3C,$66,$60,$3C,$06,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $7E,$18,$18,$18,$18,$18,$18,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 137*16, $00
