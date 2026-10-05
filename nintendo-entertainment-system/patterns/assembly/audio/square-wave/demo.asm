; =============================================================================
; A SQUARE WAVE - NES (NROM)
; Hold A-4 on pulse 1 with no further CPU work. Rendering stays off.
; =============================================================================

APU_STATUS = $4015      ; write: channel enables; read: length counters > 0
APU_FRAME  = $4017      ; frame counter mode and IRQ inhibit
PPUCTRL    = $2000
PPUMASK    = $2001

.segment "HEADER"
    .byte "NES", $1A
    .byte 2             ; 2 x 16 KB PRG
    .byte 1             ; 1 x 8 KB CHR
    .byte $00, $00      ; mapper 0, horizontal mirroring
    .byte 0,0,0,0,0,0,0,0

.segment "ZEROPAGE"
status: .res 1          ; last $4015 read; bit 0 = pulse 1 length counter > 0

.segment "CODE"
reset:
    sei
    cld
    ldx #$40
    stx APU_FRAME       ; 4-step sequence, frame IRQ inhibited
    ldx #$FF
    txs
    inx
    stx PPUCTRL         ; no NMI
    stx PPUMASK         ; rendering off
    stx $4010           ; no DMC IRQ

    lda #%00000001      ; enable pulse 1 only, before the length load
    sta APU_STATUS
    lda #$FD            ; timer 253 = $0FD
    ldx #$00
    jsr pulse1_tone     ; NTSC: 1789773/(16*254) = 440.4 Hz

hold:
    lda APU_STATUS      ; the tone needs no CPU; this only records state
    sta status
    jmp hold

nmi:
irq:
    rti

    .include "square-wave.inc"

.segment "VECTORS"
    .word nmi, reset, irq

.segment "CHARS"
    .res 8192, $00
