PF_BUFFER = $80
PF = $c8
RESULT = $d8
* = $f000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #2
    sta $01
    lda #0
    sta $00
    sta $09
    sta $0a                   ; repeat right half; use 1 for reflection
    lda #14
    sta $08
    jsr pf_clear
    lda #<glyph
    sta PF
    lda #>glyph
    sta PF+1
    lda #2
    sta PF+2
    lda #4
    sta PF+3
    jsr pf_stamp
    lda PF+5
    sta RESULT
    lda #19
    sta PF+2
    lda #23
    sta PF+3
    lda #1
    sta PF+4
    jsr pf_cell
    lda PF+5
    sta RESULT+1
    inc PF+2                  ; invalid x: must leave buffer alone
    jsr pf_cell
    lda PF+5
    sta RESULT+2
    lda #$a5
    sta $e8
    sta $eb
ready:
frame:
    lda #2
    sta $01
    sta $02
    sta $00
    sta $02
    sta $02
    sta $02
    lda #0
    sta $00
    ldx #36                   ; kernel begins with its own WSYNC
blank:
    sta $02
    dex
    bne blank
    lda #0
    sta $0d
    sta $0e
    sta $0f
    sta $01
    jsr pf_kernel
    sta $02                   ; finish final picture line, then blank
    lda #2
    sta $01
    ldx #29                   ; one extra WSYNC at frame start = 30 overscan
overscan:
    sta $02
    dex
    bne overscan
    jmp frame
!source "playfield.inc"
!source "kernel.inc"
glyph:
    !byte 14,17,17,31,17,17,17
    !fill $fffc-*, $ff
    !word start,start
