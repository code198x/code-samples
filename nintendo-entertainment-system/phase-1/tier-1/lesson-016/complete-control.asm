;===============================================================================
; Lesson 016: Boundaries
; Complete paddle control with robust boundary handling
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

PADDLE_TOP = 8
PADDLE_BOTTOM = 216
PADDLE_SPEED = 3

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

    ; Center paddle
    LDA #120
    STA paddle_y
    JSR UpdateOAM

    LDX #$04
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
    ; Save original position for conflict handling
    LDA paddle_y
    PHA

    ; Handle Up button
    LDA buttons
    AND #%00001000
    BEQ :+
    LDA paddle_y
    SEC
    SBC #PADDLE_SPEED
    STA paddle_y

    ; Handle Down button
:   LDA buttons
    AND #%00000100
    BEQ :+
    LDA paddle_y
    CLC
    ADC #PADDLE_SPEED
    STA paddle_y

    ; Check for Up+Down conflict
:   LDA buttons
    AND #%00001100   ; Both Up and Down
    CMP #%00001100
    BNE :+
    ; Both pressed - restore original position (no movement)
    PLA
    STA paddle_y
    JMP :++

    ; Apply boundaries
:   PLA              ; Discard saved position

    ; Top boundary
    LDA paddle_y
    CMP #PADDLE_TOP
    BCS :+
    LDA #PADDLE_TOP
    STA paddle_y

    ; Bottom boundary
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

UpdateOAM:
    LDA paddle_y
    STA $0200        ; Y position
    LDA #$00
    STA $0201        ; Tile index
    LDA #%00000001   ; Palette 1
    STA $0202        ; Attributes
    LDA #16
    STA $0203        ; X position
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
    ; Paddle tiles
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .res 254*16, $00
