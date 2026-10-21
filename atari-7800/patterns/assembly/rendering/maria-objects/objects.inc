!if ML_CAPACITY < 1 { !error "ML_CAPACITY must be 1..31" }
!if ML_CAPACITY > 31 { !error "ML_CAPACITY must be 1..31" }
; ML+0/1 -> caller-owned page-aligned list, 4*ML_CAPACITY+2 bytes.
; ML+2/3 -> graphic, +4 width bytes (1..31), +5 palette (0..7),
; +6 x (160A pixels); +7 count, +8 accepted, +9 scratch.
; Require ML_CAPACITY in 1..31; no clipping/wrapping, IRQ/DMA remain caller-owned.
maria_begin:
    lda #0
    sta ML+7
    ldy #0
    sta (ML),y
    iny
    sta (ML),y
    lda #1
    sta ML+8
    rts
maria_append:
    lda #0
    sta ML+8
    lda ML+7
    cmp #ML_CAPACITY
    bcs maria_return
    lda ML+4
    beq maria_return
    cmp #32
    bcs maria_return
    lda ML+5
    cmp #8
    bcs maria_return
    lda ML+6
    cmp #160
    bcs maria_return
    lda ML+4
    asl
    asl
    clc
    adc ML+6
    bcs maria_return
    cmp #161
    bcs maria_return
    lda ML+2
    clc
    adc ML+4
    bcc maria_page_ok
    beq maria_page_ok          ; ending exactly at page boundary is valid
    bcs maria_return
maria_page_ok:
    lda ML+7
    asl
    asl
    tay
    lda ML+2
    sta (ML),y
    iny
    lda ML+5
    asl
    asl
    asl
    asl
    asl
    sta ML+9
    lda #32
    sec
    sbc ML+4
    ora ML+9
    sta (ML),y
    iny
    lda ML+3
    sta (ML),y
    iny
    lda ML+6
    sta (ML),y
    iny
    lda #0
    sta (ML),y
    iny
    sta (ML),y
    inc ML+7
    inc ML+8
maria_return:
    rts
maria_code_end:
