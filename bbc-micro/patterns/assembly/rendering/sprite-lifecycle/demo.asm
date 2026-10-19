*=$3000
OSBYTE=$fff4
start:
    cld
    cli
    lda #$6c
    sta screen_ptr+1
    lda #0
    sta screen_ptr
    ldy #0
paint:
    tya
    and #7
    bne paint_ready
    lda #$55
paint_ready:
    sta (screen_ptr),y
    iny
    bne paint
    jsr draw_objects
main:
    lda #19
    jsr OSBYTE
    inc tick
    lda tick
    and #7
    bne main
    ; Reverse draw order; restore at OLD addresses before moving either object.
    lda #$80
    sta screen_ptr
    lda #$6c
    sta screen_ptr+1
    lda #<under_b
    sta back_ptr
    lda #>under_b
    sta back_ptr+1
    jsr restore_cell_from_buffer
    lda old_a
    sta screen_ptr
    lda #<under_a
    sta back_ptr
    lda #>under_a
    sta back_ptr+1
    jsr restore_cell_from_buffer
    lda column
    clc
    adc #8
    cmp #$c0
    bcc next_column
    lda #$40
next_column:
    sta column
    jsr draw_objects
    inc updates
    jmp main
draw_objects:
    lda column
    sta old_a
    sta screen_ptr
    lda #$6c
    sta screen_ptr+1
    lda #<under_a
    sta back_ptr
    lda #>under_a
    sta back_ptr+1
    jsr save_cell_to_buffer
    lda #<shape_a
    sta pairs_ptr
    lda #>shape_a
    sta pairs_ptr+1
    jsr draw_masked_cell
    lda #$80
    sta screen_ptr
    lda #<under_b
    sta back_ptr
    lda #>under_b
    sta back_ptr+1
    jsr save_cell_to_buffer
    lda #<shape_b
    sta pairs_ptr
    lda #>shape_b
    sta pairs_ptr+1
    jsr draw_masked_cell
    rts
column: !byte $40
old_a: !byte 0
tick: !byte 0
updates: !byte 0
under_a: !fill 8,0
under_b: !fill 8,0
shape_a: !byte $e7,$18,$c3,$3c,$81,$7e,$24,$db,0,$ff,$a5,$5a,$db,$24,$ff,0
shape_b: !byte $81,$7e,$bd,$42,$bd,$42,$81,$7e,$e7,$18,$e7,$18,$e7,$18,$c3,$3c
!source "../masked-sprites/masked.inc"
!source "background.inc"
