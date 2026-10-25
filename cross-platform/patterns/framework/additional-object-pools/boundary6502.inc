boundary_pool:
    lda #<(OUTPUT+3)
    sta ptr
    lda #>(OUTPUT+3)
    sta ptr+1
    lda #90
    sta POOL_FLAGS-1
    lda #167
    sta POOL_FLAGS+POOL_CAPACITY
    ldy #147
    jsr pool_init
    sty OUTPUT+2
    lda #165
    sta OUTPUT
    lda #POOL_CAPACITY
    sta OUTPUT+1
    ldx #0
boundary_init:
    lda POOL_FLAGS,x
    jsr emit
    inx
    cpx #POOL_CAPACITY
    bne boundary_init
    lda #0
    sta case_i
boundary_case:
    lda #1
    ldx #0
boundary_fill:
    sta POOL_FLAGS,x
    inx
    cpx #POOL_CAPACITY
    bne boundary_fill
    ldx case_i
    lda free_cases,x
    cmp #POOL_CAPACITY
    bcs boundary_acquire
    tax
    lda #0
    sta POOL_FLAGS,x
boundary_acquire:
    ldy #147
    jsr pool_acquire
    stx selected
    lda #0
    rol
    sta status_bits
    txa
    jsr emit
    lda status_bits
    jsr emit
    jsr snapshot_flags
    ldx selected
    jsr pool_release
    lda #0
    rol
    jsr emit
    ldx selected
    jsr pool_release
    lda #0
    rol
    jsr emit
    ldx #POOL_CAPACITY
    jsr pool_release
    lda #0
    rol
    jsr emit
    jsr snapshot_flags
    tya
    jsr emit
    inc case_i
    lda case_i
    cmp #CASE_COUNT
    bne boundary_case
    ldx #0
boundary_long_life:
    lda #1
    sta POOL_FLAGS,x
    lda #255
    sta POOL_LIFE,x
    inx
    cpx #POOL_CAPACITY
    bne boundary_long_life
    jsr pool_age
    jsr snapshot_flags
    jsr snapshot_life
    ldx #0
boundary_short_life:
    lda #1
    sta POOL_LIFE,x
    inx
    cpx #POOL_CAPACITY
    bne boundary_short_life
    jsr pool_age
    jsr snapshot_flags
    jsr snapshot_life
    lda POOL_FLAGS-1
    jsr emit
    lda POOL_FLAGS+POOL_CAPACITY
    jsr emit
    lda #239
    jsr emit
    rts
snapshot_flags:
    ldx #0
snapshot_flags_loop:
    lda POOL_FLAGS,x
    jsr emit
    inx
    cpx #POOL_CAPACITY
    bne snapshot_flags_loop
    rts
snapshot_life:
    ldx #0
snapshot_life_loop:
    lda POOL_LIFE,x
    jsr emit
    inx
    cpx #POOL_CAPACITY
    bne snapshot_life_loop
    rts
