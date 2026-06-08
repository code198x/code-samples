; ============================================================================
; Meet the Machine (NES) - Unit 9: The Machine Has a Heartbeat
;
; The PPU pulses once per frame - 60 times a second - and can tell the CPU each
; time, through the NMI. We turn that heartbeat on, and do one small job every
; beat: nudge the backdrop colour. The screen cycles through colours by itself.
; ============================================================================

.segment "HEADER"
    .byte "NES", $1a
    .byte 2
    .byte 1
    .byte $00, $00

COUNTER = $10               ; a box in RAM to count frames

.segment "CODE"

reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
warm1:
    bit $2002
    bpl warm1
warm2:
    bit $2002
    bpl warm2

    lda #$00
    sta COUNTER             ; start the frame count at 0

    ; turn the heartbeat ON: bit 7 of PPUCTRL asks for an NMI every frame
    lda #$80
    sta $2000

forever:
    jmp forever             ; the main loop does nothing - the NMI does the work

; --- the heartbeat handler: runs once per frame, at the top of VBlank ---------
nmi:
    inc COUNTER             ; one more frame has passed
    bit $2002               ; reset the address latch
    lda #$3f
    sta $2006
    lda #$00
    sta $2006               ; aim at the backdrop, $3F00
    lda COUNTER
    sta $2007               ; backdrop = the frame count (palette keeps low 6 bits)
    ; re-aim at $3F00 so the backdrop we display is the one we just set
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    rti

irq:
    rti

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 8192 - 32, $00
