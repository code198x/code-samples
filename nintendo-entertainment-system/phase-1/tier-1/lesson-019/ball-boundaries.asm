;===============================================================================
; Lesson 019: Screen Boundaries
; Ball bounces off top/bottom walls, wraps at left/right edges
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
BALL_START_X = 128
BALL_START_Y = 120

; Screen boundaries
SCREEN_TOP = 8
SCREEN_BOTTOM = 232
SCREEN_LEFT = 0
SCREEN_RIGHT = 255

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
    LDA #2
    STA ball_dx
    LDA #1
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
    JSR UpdateOAM
    JMP MainLoop

;===============================================================================
; UpdateBall - Apply velocity and handle screen boundaries
;===============================================================================
UpdateBall:
    ; Update X position
    LDA ball_x
    CLC
    ADC ball_dx
    STA ball_x
    ; Note: X wraps naturally (0-255), no boundary check needed

    ; Update Y position
    LDA ball_y
    CLC
    ADC ball_dy
    STA ball_y

    ; Check top boundary
    LDA ball_y
    CMP #SCREEN_TOP
    BCS :+                  ; Branch if >= SCREEN_TOP
    ; Hit top wall - reverse Y velocity
    LDA #SCREEN_TOP
    STA ball_y
    LDA ball_dy
    EOR #$FF                ; Two's complement negation:
    CLC                     ; Invert bits, then add 1
    ADC #1
    STA ball_dy

    ; Check bottom boundary
:   LDA ball_y
    CMP #SCREEN_BOTTOM
    BCC :+                  ; Branch if < SCREEN_BOTTOM
    ; Hit bottom wall - reverse Y velocity
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

;===============================================================================
; ReadController
;===============================================================================
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

;===============================================================================
; NMI
;===============================================================================
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
; UpdateOAM
;===============================================================================
UpdateOAM:
    LDA paddle_y
    STA $0200
    LDA #$00
    STA $0201
    LDA #%00000001
    STA $0202
    LDA #16
    STA $0203

    LDA ball_y
    STA $0204
    LDA #$01
    STA $0205
    LDA #%00000001
    STA $0206
    LDA ball_x
    STA $0207
    RTS

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
