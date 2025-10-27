;===============================================================================
; Lesson 011: Sprite DMA
; Using OAM DMA for efficient sprite updates
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready: .res 1
paddle_y: .res 1

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

    ; Initialize sprite position
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

    ; Update sprite position
    INC paddle_y
    JSR UpdateOAM

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
