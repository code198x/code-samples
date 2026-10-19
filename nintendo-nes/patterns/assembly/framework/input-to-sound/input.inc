; Controller 1, ca65 syntax. Allocate state in writable RAM.
; A=$80 B=$40 Select=$20 Start=$10 Up=$08 Down=$04 Left=$02 Right=$01.
; read_controls changes A/X/flags, preserves Y. Call once per update.
; This simple reader assumes no DMC sample DMA; it is not a DMC-safe reader.
.segment "BSS"
controls: .res 1
.segment "CODE"
read_controls:
    lda #1
    sta $4016
    lda #0
    sta $4016
    ldx #8
input_shift:
    lda $4016
    lsr
    rol controls
    dex
    bne input_shift
    rts
