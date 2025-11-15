;===============================================================================
; Lesson 026: Number to Tiles
; Convert decimal numbers (0-99) to tile indices for display
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready:        .res 1
buttons:          .res 1
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
digit_tens:       .res 1  ; NEW - Tens digit (0-9)
digit_ones:       .res 1  ; NEW - Ones digit (0-9)

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
    LDA #5
    STA score_p1        ; Test with score 5
    LDA #7
    STA score_p2        ; Test with score 7

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
    JSR UpdatePaddle
    JSR UpdateBall
    JSR CheckScoring
    JSR UpdateCollisionTimer
    JSR CheckPaddleCollision
    JSR UpdateOAM
    JMP MainLoop

;===============================================================================
; DecimalToTiles - Convert number (0-99) to two digit tiles
; Input: A = number (0-99)
; Output: digit_tens, digit_ones = tile indices
;===============================================================================
DecimalToTiles:
    ; Clear tens counter
    LDX #0
@count_tens:
    CMP #10
    BCC @done_tens      ; Less than 10, done
    SBC #10             ; Subtract 10 (carry already set from CMP)
    INX                 ; Increment tens
    JMP @count_tens

@done_tens:
    ; A now contains ones digit (0-9)
    STA digit_ones
    ; X contains tens digit (0-9)
    STX digit_tens

    ; Convert to tile indices (tiles $30-$39 = ASCII '0'-'9')
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
    LDA score_p2
    CMP #10
    BCC @reset_ball
    LDA #0
    STA score_p1
    STA score_p2
    JMP @reset_ball

@check_right:
    LDA ball_x
    CMP #SCREEN_RIGHT
    BCC @done

    INC score_p1
    LDA score_p1
    CMP #10
    BCC @reset_ball
    LDA #0
    STA score_p1
    STA score_p2

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

    LDA ball_y
    STA $0210
    LDA #$01
    STA $0211
    LDA #%00000001
    STA $0212
    LDA ball_x
    STA $0213
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
    ; Blank tiles (0-$2F)
    .res 48*16, $00
    ; Digit tiles ($30-$39 = '0'-'9')
    ; Tile $30 = '0'
    .byte $3C,$66,$6E,$76,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $31 = '1'
    .byte $18,$38,$18,$18,$18,$18,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $32 = '2'
    .byte $3C,$66,$06,$0C,$18,$30,$7E,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $33 = '3'
    .byte $3C,$66,$06,$1C,$06,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $34 = '4'
    .byte $0C,$1C,$3C,$6C,$7E,$0C,$0C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $35 = '5'
    .byte $7E,$60,$7C,$06,$06,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $36 = '6'
    .byte $3C,$60,$60,$7C,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $37 = '7'
    .byte $7E,$06,$0C,$18,$30,$30,$30,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $38 = '8'
    .byte $3C,$66,$66,$3C,$66,$66,$3C,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile $39 = '9'
    .byte $3C,$66,$66,$3E,$06,$0C,$38,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 206*16, $00
