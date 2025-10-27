;===============================================================================
; Lesson 013: Controller Basics
; Reading NES controller button states
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready: .res 1
buttons:   .res 1   ; Current button states
paddle_y:  .res 1

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

    ; Initialize paddle position
    LDA #100
    STA paddle_y
    JSR UpdateOAM

    ; Hide unused sprites
    LDX #$04
    LDA #$FF
:   STA $0200,X
    INX
    INX
    INX
    INX
    BNE :-

    ; Enable NMI and rendering
    LDA #%10100000
    STA $2000
    LDA #%00011110
    STA $2001

MainLoop:
    ; Wait for NMI
:   LDA nmi_ready
    BEQ :-
    LDA #$00
    STA nmi_ready

    ; Read controller
    JSR ReadController

    ; Test if A button pressed
    LDA buttons
    AND #%10000000   ; Bit 7 = A button
    BEQ :+           ; Branch if not pressed

    ; A button pressed - move paddle down
    LDA paddle_y
    CLC
    ADC #2
    STA paddle_y

:   JSR UpdateOAM
    JMP MainLoop

;===============================================================================
; ReadController - Read controller 1 button states
;===============================================================================
ReadController:
    ; Strobe controller
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016

    ; Read 8 buttons into buttons variable
    ; Result: bit 7=A, 6=B, 5=Select, 4=Start, 3=Up, 2=Down, 1=Left, 0=Right
    LDX #$08         ; 8 buttons to read
:   LDA $4016        ; Read one button
    LSR              ; Shift bit 0 into carry
    ROL buttons      ; Rotate carry into buttons
    DEX
    BNE :-
    RTS

;===============================================================================
; NMI - VBlank handler
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
    STA $0200
    LDA #$00
    STA $0201
    LDA #%00000000
    STA $0202
    LDA #16
    STA $0203
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
    .byte $0F, $00, $30, $10, $0F, $00, $30, $10
    .byte $0F, $00, $30, $10, $0F, $00, $30, $10

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
    .res 254*16, $00
