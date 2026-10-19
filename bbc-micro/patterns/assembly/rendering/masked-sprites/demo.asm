; MODE4 is selected by the BASIC loader. MOS IRQ remains active.
*=$3000
OSBYTE=$fff4
start:
    cld
    cli
    lda #<shape
    sta pairs_ptr
    lda #>shape
    sta pairs_ptr+1
    lda #$6c
    sta screen_ptr+1
    lda #0
    sta screen_ptr
    ldy #0
paint:
    tya
    and #7
    bne paint_pixel
    lda #$aa
paint_pixel:
    sta (screen_ptr),y
    iny
    bne paint
    lda #$a0
    sta screen_ptr
    jsr save_background
    jsr draw_masked_cell
main:
    lda #19
    jsr OSBYTE
    ; Move one character cell every eight vertical syncs.
    inc tick
    lda tick
    and #7
    bne main
    jsr restore_background
    lda screen_ptr
    clc
    adc #8
    cmp #$f8
    bcc next_cell
    lda #0
next_cell:
    sta screen_ptr
    jsr save_background
    jsr draw_masked_cell
    inc updates
    jmp main
tick: !byte 0
updates: !byte 0
shape: !byte $e7,$18,$c3,$3c,$81,$7e,$24,$db,$00,$ff,$a5,$5a,$db,$24,$ff,0
!source "masked.inc"
