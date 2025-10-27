;===============================================================================
; Lesson 004: VBlank Timing
; Example 1: Basic NMI Handler
;
; Demonstrates:
; - Enabling NMI interrupt
; - NMI handler structure with register preservation
; - 60fps synchronization flag
; - Main game loop waiting for VBlank
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready: .res 1           ; Flag: 1 = NMI occurred, ready for next frame

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

    ; Initialize stack
    LDX #$FF
    TXS

    ; Set background colour
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA #$12                ; Blue
    STA $2007

    ; Enable NMI
    LDA #%10000000          ; Bit 7 = NMI enable
    STA $2000

    ; Enable rendering
    LDA #%00001000
    STA $2001

MainLoop:
    ; Wait for NMI to set flag
:   LDA nmi_ready
    BEQ :-                  ; Loop until flag is 1

    ; NMI occurred - reset flag
    LDA #$00
    STA nmi_ready

    ; Game logic here
    ; (runs once per frame, synchronized to 60fps)

    JMP MainLoop

NMI:
    ; Save registers
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Graphics updates here
    ; (safe to update PPU during VBlank)

    ; Set ready flag
    LDA #$01
    STA nmi_ready

    ; Restore registers
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI                     ; Return from interrupt

IRQ:
    RTI

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    .res 8192, $00
