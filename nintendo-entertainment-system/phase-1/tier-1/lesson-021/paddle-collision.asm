;===============================================================================
; Lesson 021: Paddle-Ball Collision
; Implement AABB collision detection between paddle and ball
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready: .res 1
buttons:   .res 1
paddle_y:  .res 1
ball_x:    .res 1
ball_y:    .res 1
ball_dx:   .res 1
ball_dy:   .res 1

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
    LDA #BALL_START_X
    STA ball_x
    LDA #BALL_START_Y
    STA ball_y
    LDA #$FE            ; -2 (moving left toward paddle)
    STA ball_dx
    LDA #2
    STA ball_dy

    JSR UpdateOAM

    LDX #$08
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
    JSR CheckPaddleCollision    ; NEW
    JSR UpdateOAM
    JMP MainLoop

;===============================================================================
; CheckPaddleCollision - AABB collision detection
;===============================================================================
CheckPaddleCollision:
    ; Check if ball is near paddle X position
    LDA ball_x
    CMP #(PADDLE_X + PADDLE_WIDTH)
    BCS @no_collision       ; Ball too far right
    CMP #PADDLE_X
    BCC @no_collision       ; Ball too far left

    ; Check Y overlap
    ; Ball top = ball_y, Ball bottom = ball_y + BALL_SIZE
    ; Paddle top = paddle_y, Paddle bottom = paddle_y + PADDLE_HEIGHT

    ; Check if ball bottom < paddle top
    LDA ball_y
    CLC
    ADC #BALL_SIZE
    CMP paddle_y
    BCC @no_collision

    ; Check if ball top > paddle bottom
    LDA paddle_y
    CLC
    ADC #PADDLE_HEIGHT
    CMP ball_y
    BCC @no_collision

    ; Collision detected! Reverse ball X velocity
    LDA ball_dx
    EOR #$FF
    CLC
    ADC #1
    STA ball_dx

    ; Move ball away from paddle to prevent stuck
    LDA #(PADDLE_X + PADDLE_WIDTH + 1)
    STA ball_x

@no_collision:
    RTS

;===============================================================================
; UpdateBall
;===============================================================================
UpdateBall:
    LDA ball_x
    CLC
    ADC ball_dx
    STA ball_x

    LDA ball_y
    CLC
    ADC ball_dy
    STA ball_y

    ; Top boundary
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

    ; Bottom boundary
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

;===============================================================================
; UpdatePaddle
;===============================================================================
UpdatePaddle:
    LDA paddle_y
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

;===============================================================================
; UpdateOAM - Paddle uses 4 sprites vertically
;===============================================================================
UpdateOAM:
    ; Paddle sprites (4x 8x8 tiles)
    LDX #$00
    LDY #$00
@paddle_loop:
    LDA paddle_y
    CLC
    ADC table_offset,Y
    STA $0200,X         ; Y position
    LDA #$00
    STA $0201,X         ; Tile
    LDA #%00000001
    STA $0202,X         ; Attributes
    LDA #PADDLE_X
    STA $0203,X         ; X position
    INX
    INX
    INX
    INX
    INY
    CPY #$04
    BNE @paddle_loop

    ; Ball sprite
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
    .res 256*16, $00
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 252*16, $00
