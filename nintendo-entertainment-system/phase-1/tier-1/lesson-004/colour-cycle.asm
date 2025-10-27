;===============================================================================
; Lesson 004: VBlank Timing
; Example 2: Colour Cycling at 60fps
;
; Demonstrates:
; - Graphics updates during NMI
; - Frame counter incrementing
; - Changing background colour each frame
; - True 60fps synchronization
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
nmi_ready: .res 1
frame_count: .res 1         ; Frame counter (0-255)
colour_index: .res 1        ; Current colour (0-7)

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

    ; Initialize variables
    LDA #$00
    STA frame_count
    STA colour_index

    ; Enable NMI
    LDA #%10000000
    STA $2000

    ; Enable rendering
    LDA #%00001000
    STA $2001

MainLoop:
    ; Wait for VBlank
:   LDA nmi_ready
    BEQ :-

    ; Reset flag
    LDA #$00
    STA nmi_ready

    ; Game logic: change colour every 15 frames
    INC frame_count
    LDA frame_count
    CMP #15
    BNE MainLoop            ; Not yet - skip colour change

    ; 15 frames passed - change colour
    LDA #$00
    STA frame_count         ; Reset counter
    INC colour_index
    LDA colour_index
    CMP #$08
    BNE MainLoop            ; Not at end - continue
    LDA #$00
    STA colour_index        ; Wrap to 0

    JMP MainLoop

NMI:
    ; Save registers
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Update background colour
    BIT $2002               ; Reset PPU address latch
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    ; Load colour from table
    LDX colour_index
    LDA ColourTable,X
    STA $2007

    ; Set ready flag
    LDA #$01
    STA nmi_ready

    ; Restore registers
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

IRQ:
    RTI

.segment "RODATA"
ColourTable:
    .byte $0F, $12, $16, $27, $29, $1A, $21, $30

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    .res 8192, $00
