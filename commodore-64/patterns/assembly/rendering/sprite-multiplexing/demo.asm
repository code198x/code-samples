; RUN after loading: sixteen sprites in two bands on a PAL or NTSC C64.
* = $0801
    !byte $0b, $08, $0a, $00, $9e
    !text "2064"
    !byte 0, 0, 0
* = $0810
start:
    sei
    lda #$7f
    sta $dc0d            ; no CIA timer IRQ or NMI during the raster chain
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$35             ; RAM at BASIC/KERNAL, I/O visible
    sta $01
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00            ; VIC-II bank 0 ($0000-$3fff)
    lda #$14
    sta $d018            ; screen $0400, character ROM $1000
    lda #$08
    sta $d016            ; 40 columns, no multicolour text
    lda #0
    sta $d020
    sta $d021
    ldx #0
    lda #32
clear_screen:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $06e8, x
    inx
    bne clear_screen
    jsr mux_init
    cli
idle:
    jmp idle
nmi_return:
    rti

!source "multiplexer.inc"

* = $2000                ; sprite pointers $80 and $81, 64-byte alignment
solid:
    !fill 63, $ff
    !byte 0
outline:
    !byte $ff, $ff, $ff
    !for row, 1, 19 {
        !byte $80, 0, 1
    }
    !byte $ff, $ff, $ff, 0
