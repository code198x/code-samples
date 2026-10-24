.segment "CODE"
reset:
    sei
    cld
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
    stx $4015
    lda #$40
    sta $4017
    lda #0
clear_ram:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clear_ram
    jsr wait_vblank
    jsr wait_vblank
    jsr exercise_rng
; Normal library use: initialize once, then draw only when the game needs it.
    lda #SEED
.if BROKEN
    sta RNG_STATE
.else
    jsr rng_seed
.endif
    ldx #0
preview_next:
    jsr rng_next
    sta preview,x
    inx
    cpx #8
    bne preview_next
    jsr wait_vblank
    bit $2002
    lda #$20
    sta $2006
    lda #0
    sta $2006
    lda #0
    ldy #4
    ldx #0
clear_names:
    sta $2007
    inx
    bne clear_names
    dey
    bne clear_names
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    lda #$0f
    sta $2007
    lda #$30
    sta $2007
    lda #$20
    sta $2006
    lda #$22
    sta $2006
    ldx #0
show_byte:
    lda preview,x
    lsr
    lsr
    lsr
    lsr
    tay
    iny
    tya
    sta $2007
    lda preview,x
    and #15
    tay
    iny
    tya
    sta $2007
    lda #0
    sta $2007
    inx
    cpx #8
    bne show_byte
    lda #0
    sta $2005
    sta $2005
    lda #$0a
    sta $2001
    lda #165
    sta ready
hold:
    jmp hold
wait_vblank:
    bit $2002
    bpl wait_vblank
    rts
nmi:
irq:
    rti
