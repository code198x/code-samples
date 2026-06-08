; ============================================================================
; Meet the Machine (NES) - Unit 1: Assemble and Run
;
; Everything outside the YOUR CODE block is the harness: the ceremony the NES
; needs before it will show a single pixel. You type it once and treat it as a
; black box. Later units open it up - the part that puts your colour on screen
; is Unit 5. For now, leave the colour you want in A, and the harness shows it.
; ============================================================================

; --- iNES header: tells the emulator what kind of cartridge this is ----------
.segment "HEADER"
    .byte "NES", $1a        ; magic number
    .byte 2                 ; 2 x 16 KB PRG ROM (the program)
    .byte 1                 ; 1 x 8 KB CHR ROM (the shapes)
    .byte $00, $00          ; mapper 0 (NROM), horizontal mirroring

; --- The program -------------------------------------------------------------
.segment "CODE"

reset:
    sei                     ; ignore interrupts for now
    cld                     ; the NES 6502 has no decimal mode
    ldx #$40
    stx $4017               ; quieten the APU's frame interrupt
    ldx #$ff
    txs                     ; set the stack pointer
    inx                     ; x is now 0
    stx $2000               ; PPUCTRL = 0  -> NMI off
    stx $2001               ; PPUMASK = 0  -> rendering off
    stx $4010               ; DMC interrupt off

    ; The PPU is not ready for about two frames after power-on. Wait for two
    ; VBlanks before we touch it. (We meet VBlank properly later in the Primer.)
warm1:
    bit $2002
    bpl warm1
warm2:
    bit $2002
    bpl warm2

    ; ----------------------------------------------------------- YOUR CODE START
    lda #$16                ; $16 = red. Leave the colour you want in A.
    ; ------------------------------------------------------------- YOUR CODE END

    ; --- harness: show the colour now in A as the screen's backdrop ----------
    sta $00                 ; stash the colour in a scratch box
    bit $2002               ; reset the PPU's address latch
    lda #$3f
    sta $2006               ; aim the PPU at palette address $3F00...
    lda #$00
    sta $2006
    lda $00                 ; fetch the colour back
    sta $2007               ; ...and pour it in - the screen takes the colour

forever:
    jmp forever             ; hold the picture (the 6502 never stops on its own)

nmi:
    rti
irq:
    rti

; --- Interrupt vectors: where the CPU looks on reset and interrupt ------------
.segment "VECTORS"
    .word nmi               ; $FFFA
    .word reset             ; $FFFC
    .word irq               ; $FFFE

; --- CHR ROM: the shapes the PPU can draw (we meet this later) ----------------
.segment "CHARS"
    ; Tile 0: blank
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile 1: a solid block
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 8192 - 32, $00     ; fill the rest of CHR ROM with blank tiles
