; SPDX-License-Identifier: MIT
; Dragon PMODE 4 at $0600. BP reserves 48 bytes RAM, native big-endian words:
; +0 x0,+2 y0,+4 x1,+6 y1 (exclusive ends); +8 op 0=set/1=clear/2=XOR.
; +9 accepted,+10 read,+40 word write count. +12..47 scratch, inputs survive.
; D/X/Y/CC destroyed; stack <=6 bytes incl caller. Not re-entrant; no IRQ mask changes.
bp_fill
    clra
    bra bp_enter
bp_box
    lda #1
    bra bp_enter
bp_pixel
    lda #2
    bra bp_enter
bp_read
    lda #3
    bra bp_enter
bp_hspan
    lda #4
    bra bp_enter
bp_vspan
    lda #5
bp_enter
    sta BP+12
    clr BP+9
    clr BP+10
    clr BP+40
    clr BP+41
    ldx #BP
    ldy #BP+16
    ldb #8
bp_copy
    lda ,x+
    sta ,y+
    decb
    bne bp_copy
    lda BP+12
    cmpa #2
    blo bp_validate
    cmpa #5
    beq bp_unit_x
    ldd BP+18
    addd #1
    std BP+22
    lda BP+12
    cmpa #4
    beq bp_validate
bp_unit_x
    ldd BP+16
    addd #1
    std BP+20
bp_validate
    lda BP+8
    cmpa #3
    bhs bp_invalid
    ldd BP+20
    cmpd #256
    bhi bp_invalid
    ldd BP+16
    cmpd BP+20
    bhs bp_invalid
    ldd BP+22
    cmpd #192
    bhi bp_invalid
    ldd BP+18
    cmpd BP+22
    bhs bp_invalid
    bra bp_valid
bp_invalid
    rts
bp_valid
    lda #1
    sta BP+9
    ldb BP+17
    andb #7
    ldx #bp_right_masks
    lda b,x
    sta BP+24
    ldx #bp_bit_masks
    lda b,x
    sta BP+26
    ldb BP+21
    andb #7
    ldx #bp_left_masks
    lda b,x
    sta BP+25
    decb
    andb #7
    ldx #bp_bit_masks
    lda b,x
    sta BP+27
    ldb BP+17
    lsrb
    lsrb
    lsrb
    stb BP+28
    ldd BP+20
    subd #1
    lsrb
    lsrb
    lsrb
    stb BP+29
    ldb BP+19
    stb BP+32
    ldb BP+23
    decb
    stb BP+42
bp_row
    clr BP+39
    ; A 32-byte scanline: y*32 + x/8 + $0600. No row table.
    clra
    ldb BP+32
    lslb
    rola
    lslb
    rola
    lslb
    rola
    lslb
    rola
    lslb
    rola
    addd #$0600
    addb BP+28
    adca #0
    std BP+34
    lda BP+28
    sta BP+30
    lda BP+24
    sta BP+36
    lda BP+25
    sta BP+37
    lda BP+12
    cmpa #1
    bne bp_bytes
    lda BP+32
    cmpa BP+19
    beq bp_bytes
    cmpa BP+42
    beq bp_bytes
    lda #1
    sta BP+39
    lda BP+26
    sta BP+36
    lda BP+27
    sta BP+37
bp_bytes
    ldb #255
    lda BP+30
    cmpa BP+28
    bne bp_not_first
    ldb BP+36
bp_not_first
    lda BP+30
    cmpa BP+29
    bne bp_not_last
    andb BP+37
    tst BP+39
    beq bp_not_last
    cmpa BP+28
    bne bp_not_last
    ldb BP+36
    orb BP+37
bp_not_last
    tst BP+39
    beq bp_apply
    lda BP+30
    cmpa BP+28
    beq bp_apply
    cmpa BP+29
    bne bp_advance
bp_apply
    ldx BP+34
    lda BP+12
    cmpa #3
    bne bp_write
    andb ,x
    beq bp_return
    lda #1
    sta BP+10
bp_return
    rts
bp_write
    lda BP+8
    beq bp_set
    cmpa #1
    beq bp_clear
    eorb ,x
    bra bp_store
bp_clear
    comb
    andb ,x
    bra bp_store
bp_set
    orb ,x
bp_store
    stb ,x
    ldd BP+40
    addd #1
    std BP+40
bp_advance
    lda BP+30
    cmpa BP+29
    beq bp_next_row
    inc BP+30
    ldx BP+34
    leax 1,x
    stx BP+34
    jmp bp_bytes
bp_next_row
    inc BP+32
    lda BP+32
    cmpa BP+23
    beq bp_return
    jmp bp_row
bp_right_masks
    fcb 255,127,63,31,15,7,3,1
bp_left_masks
    fcb 255,128,192,224,240,248,252,254
bp_bit_masks
    fcb 128,64,32,16,8,4,2,1
