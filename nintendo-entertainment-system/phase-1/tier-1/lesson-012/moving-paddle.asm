;===============================================================================
; Lesson 012: Moving Paddle
; Automatic sprite animation with velocity and boundary detection
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready: .res 1
paddle_y:  .res 1
paddle_vy: .res 1   ; Velocity (signed)

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

    ; Load palettes
    JSR LoadPalettes

    ; Initialize paddle position and velocity
    LDA #100
    STA paddle_y
    LDA #2           ; Move down at 2 pixels/frame
    STA paddle_vy

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
    LDA #%10100000      ; NMI, 8×16, pattern table 1
    STA $2000
    LDA #%00011110      ; Show BG + sprites
    STA $2001

MainLoop:
    ; Wait for NMI
:   LDA nmi_ready
    BEQ :-
    LDA #$00
    STA nmi_ready

    ; Update paddle position with velocity
    LDA paddle_y
    CLC
    ADC paddle_vy    ; Add velocity (signed addition)
    STA paddle_y

    ; Check top boundary (Y < 8)
    CMP #8
    BCS :+           ; Branch if Y >= 8
    LDA #8
    STA paddle_y
    ; Negate velocity (bounce)
    LDA paddle_vy
    EOR #$FF         ; Flip all bits
    CLC
    ADC #$01         ; Add 1 (two's complement negation)
    STA paddle_vy

    ; Check bottom boundary (Y > 200)
:   LDA paddle_y
    CMP #200
    BCC :+           ; Branch if Y < 200
    LDA #200
    STA paddle_y
    ; Negate velocity (bounce)
    LDA paddle_vy
    EOR #$FF
    CLC
    ADC #$01
    STA paddle_vy

    ; Update OAM buffer
:   JSR UpdateOAM

    JMP MainLoop

;===============================================================================
; NMI - VBlank handler with OAM DMA
;===============================================================================
NMI:
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Trigger OAM DMA
    LDA #$02            ; High byte of $0200
    STA $4014           ; Start DMA transfer (513 cycles)

    ; Set ready flag
    LDA #$01
    STA nmi_ready

    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

;===============================================================================
; UpdateOAM - Write sprite data to OAM buffer
;===============================================================================
UpdateOAM:
    LDA paddle_y
    STA $0200           ; Y position
    LDA #$00
    STA $0201           ; Tile index
    LDA #%00000000
    STA $0202           ; Attributes
    LDA #16
    STA $0203           ; X position
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
    ; Sprite tiles
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .res 254*16, $00
