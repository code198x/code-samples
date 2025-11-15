;===============================================================================
; Lesson 028: Game States
; Add title, playing, and game over states with state machine
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready:        .res 1
buttons:          .res 1
buttons_prev:     .res 1  ; NEW - Previous frame buttons for edge detection
paddle_y:         .res 1
paddle_y_old:     .res 1
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
game_state:       .res 1  ; NEW - Current game state

; Game state constants
STATE_TITLE = 0
STATE_PLAYING = 1
STATE_GAMEOVER = 2

PADDLE_TOP = 8
PADDLE_BOTTOM = 216
PADDLE_SPEED = 3
PADDLE_X = 16
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

    LDA #120
    STA paddle_y
    STA paddle_y_old
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
    LDA #STATE_TITLE     ; NEW - Start in title state
    STA game_state
    LDA #1
    STA score_changed

    JSR UpdateOAM

    LDX #$10
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

    ; Dispatch based on game state
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
; UpdateTitle - Title screen logic, wait for Start button
;===============================================================================
UpdateTitle:
    ; Check for Start button press (bit 3)
    LDA buttons
    AND #%00010000      ; Start button
    BEQ @no_start
    LDA buttons_prev
    AND #%00010000
    BNE @no_start       ; Was pressed last frame, ignore

    ; Start button pressed, begin game
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

;===============================================================================
; UpdatePlaying - Active gameplay
;===============================================================================
UpdatePlaying:
    JSR UpdatePaddle
    JSR UpdateBall
    JSR CheckScoring
    JSR UpdateCollisionTimer
    JSR CheckPaddleCollision

    ; Check for win condition
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

;===============================================================================
; UpdateGameover - Game over screen, wait for Start to return to title
;===============================================================================
UpdateGameover:
    ; Check for Start button press
    LDA buttons
    AND #%00010000      ; Start button
    BEQ @no_start
    LDA buttons_prev
    AND #%00010000
    BNE @no_start

    ; Return to title
    LDA #STATE_TITLE
    STA game_state
    LDA #0
    STA score_p1
    STA score_p2
    LDA #1
    STA score_changed

@no_start:
    RTS

UpdateScoreDisplay:
    ; Player 1 score at row 2, column 10
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

    ; Player 2 score at row 2, column 20
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

    ; Display state messages
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

;===============================================================================
; DrawTitleMessage - "PRESS START" at center of screen
;===============================================================================
DrawTitleMessage:
    ; Row 14, column 10 (nametable $2000 + 14*32 + 10)
    LDA #$21
    STA $2006
    LDA #$CA            ; 14*32 = $1C0, + 10 = $1CA
    STA $2006

    ; "PRESS START" (11 characters)
    LDX #0
@loop:
    LDA msg_press_start,X
    STA $2007
    INX
    CPX #11
    BNE @loop
    RTS

msg_press_start:
    .byte $50,$52,$45,$53,$53,$20,$53,$54,$41,$52,$54  ; "PRESS START"

;===============================================================================
; DrawGameoverMessage - "GAME OVER" at center of screen
;===============================================================================
DrawGameoverMessage:
    ; Row 14, column 11
    LDA #$21
    STA $2006
    LDA #$CB
    STA $2006

    ; "GAME OVER" (9 characters)
    LDX #0
@loop:
    LDA msg_game_over,X
    STA $2007
    INX
    CPX #9
    BNE @loop
    RTS

msg_game_over:
    .byte $47,$41,$4D,$45,$20,$4F,$56,$45,$52  ; "GAME OVER"

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
    JMP @reset_ball

@check_right:
    LDA ball_x
    CMP #SCREEN_RIGHT
    BCC @done

    INC score_p1
    LDA #1
    STA score_changed

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
    CMP #(PADDLE_X + PADDLE_WIDTH)
    BCS @no_collision
    CMP #PADDLE_X
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
    LDA #(PADDLE_X + PADDLE_WIDTH + 1)
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
    LDA ball_y
    CMP #SCREEN_TOP
    BCS :+
    LDA #SCREEN_TOP
    STA ball_y
    LDA ball_dy
    EOR #$FF
    CLC
    ADC #1
    STA ball_dy
:   LDA ball_y
    CMP #SCREEN_BOTTOM
    BCC :+
    LDA #SCREEN_BOTTOM
    STA ball_y
    LDA ball_dy
    EOR #$FF
    CLC
    ADC #1
    STA ball_dy
:   RTS

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
    STA buttons_prev    ; NEW - Save previous frame state
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
@paddle_loop:
    LDA paddle_y
    CLC
    ADC table_offset,Y
    STA $0200,X
    LDA #$00
    STA $0201,X
    LDA #%00000001
    STA $0202,X
    LDA #PADDLE_X
    STA $0203,X
    INX
    INX
    INX
    INX
    INY
    CPY #$04
    BNE @paddle_loop

    ; Only show ball in PLAYING state
    LDA game_state
    CMP #STATE_PLAYING
    BNE @hide_ball

    LDA ball_y
    STA $0210
    LDA #$01
    STA $0211
    LDA #%00000001
    STA $0212
    LDA ball_x
    STA $0213
    RTS

@hide_ball:
    LDA #$FF
    STA $0210
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
    ; Digit tiles ($30-$39)
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
    ; Letter tiles for messages (A-Z at $41-$5A)
    .res 7*16, $00  ; $3A-$40 unused
    ; A ($41)
    .byte $3C,$66,$66,$7E,$66,$66,$66,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 4*16, $00  ; B-D skip
    ; E ($45)
    .byte $7E,$60,$60,$7C,$60,$60,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 1*16, $00  ; F skip
    ; G ($47)
    .byte $3C,$66,$60,$6E,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 7*16, $00  ; H-N skip
    ; O ($4F)
    .byte $3C,$66,$66,$66,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; P ($50)
    .byte $7C,$66,$66,$7C,$60,$60,$60,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 1*16, $00  ; Q skip
    ; R ($52)
    .byte $7C,$66,$66,$7C,$6C,$66,$66,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; S ($53)
    .byte $3C,$66,$60,$3C,$06,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; T ($54)
    .byte $7E,$18,$18,$18,$18,$18,$18,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 9*16, $00  ; Rest of alphabet
    .res 128*16, $00
