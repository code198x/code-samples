;===============================================================================
; Lesson 003: CPU and Memory Map
; Example: Zero Page Variables
;
; Demonstrates:
; - Defining variables in zero page
; - Loading and storing values
; - Using variables to control PPU
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
counter: .res 1             ; 1 byte at $00
colour:  .res 1             ; 1 byte at $01

.segment "CODE"
Reset:
    SEI
    CLD

    ; PPU warmup
    BIT $2002
:   BIT $2002
    BPL :-
:   BIT $2002
    BPL :-

    ; Initialize variables
    LDA #$00
    STA counter
    LDA #$12                ; Blue
    STA colour

    ; Use variable to set background
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA colour              ; Load from variable
    STA $2007

    ; Enable rendering
    LDA #%00001000
    STA $2001

Forever:
    INC counter             ; Increment counter each loop
    JMP Forever

NMI:
    RTI

IRQ:
    RTI

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    .res 8192, $00
