; Load and RUN. Reset to leave. Owns display and interrupt configuration.
; KERNAL remains mapped: its IRQ prologue saves A/X/Y for our handler.
* = $0801
    !byte $0b, $08, $0a, $00, $9e
    !text "2064"
    !byte 0, 0, 0
* = $0810
start:
    sei
    lda #$37
    sta $01
    lda #$7f
    sta $dd0d
    lda $dd0d
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00                 ; VIC bank 0
    lda #$14
    sta $d018                 ; screen $0400, character ROM $1000
    lda #$1b
    sta $d011                 ; 25 rows, Y scroll 3
    lda #$08
    sta $d016                 ; 40 columns, single-colour text
    lda #0
    sta $d015
    sta $d020
    sta $d021
    sta $d01a
    lda #$0f
    sta $d019
    ldx #0
    lda #32
clear_screen:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $06e8, x
    inx
    bne clear_screen
    jsr split_init
    lda #$5a
    ldx #$a5
    ldy #$3c
    cli
wait_top:
    cmp #$5a                 ; IRQ must preserve the foreground registers
    bne failed
    cpx #$a5
    bne failed
    cpy #$3c
    bne failed
    bit $d011
    bmi wait_top
wait_bottom:
    bit $d011
    bpl wait_bottom
    inc frames
picture_ready:
    jmp wait_top
failed:
    inc errors
halt:
    jmp halt
frames: !byte 0
errors: !byte 0

!source "split.inc"
