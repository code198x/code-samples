;===============================================================================
; Lesson 017: The Ball Entity
; Add ball entity with position and velocity in RAM, display as sprite
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

; Ball entity variables
ball_x:    .res 1       ; Ball X position (0-255)
ball_y:    .res 1       ; Ball Y position (0-239)
ball_dx:   .res 1       ; Ball X velocity (signed)
ball_dy:   .res 1       ; Ball Y velocity (signed)

PADDLE_TOP = 8
PADDLE_BOTTOM = 216
PADDLE_SPEED = 3

; Ball constants
BALL_START_X = 128
BALL_START_Y = 120

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

    ; Initialize paddle
    LDA #120
    STA paddle_y

    ; Initialize ball entity
    LDA #BALL_START_X
    STA ball_x
    LDA #BALL_START_Y
    STA ball_y
    LDA #2              ; X velocity = 2 pixels/frame
    STA ball_dx
    LDA #1              ; Y velocity = 1 pixel/frame
    STA ball_dy

    JSR UpdateOAM

    ; Clear unused sprite slots
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
    JSR UpdateOAM
    JMP MainLoop

;===============================================================================
; UpdatePaddle - Handle input and boundaries
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
; UpdateOAM - Write paddle and ball sprites to OAM
;===============================================================================
UpdateOAM:
    ; Paddle sprite (slot 0)
    LDA paddle_y
    STA $0200        ; Y position
    LDA #$00
    STA $0201        ; Tile index 0 (paddle)
    LDA #%00000001   ; Palette 1
    STA $0202        ; Attributes
    LDA #16
    STA $0203        ; X position

    ; Ball sprite (slot 1)
    LDA ball_y
    STA $0204        ; Y position
    LDA #$01
    STA $0205        ; Tile index 1 (ball)
    LDA #%00000001   ; Palette 1
    STA $0206        ; Attributes
    LDA ball_x
    STA $0207        ; X position
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
    ; Tile 0: Paddle (8x8 vertical bar)
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    ; Tile 1: Ball (8x8 square)
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 252*16, $00
