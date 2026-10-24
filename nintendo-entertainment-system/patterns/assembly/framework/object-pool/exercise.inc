; Second caller: every occupancy mask, not a preview-generated assertion.
exercise_pool:
    lda #$5a
    sta POOL_FLAGS-1
    lda #$a7
    sta POOL_FLAGS+POOL_CAPACITY
    ldx #0
    lda #$3c
exercise_dirty:
    sta POOL_FLAGS,x
    sta POOL_LIFE,x
    inx
    cpx #POOL_CAPACITY
    bne exercise_dirty
    jsr pool_init
    lda #<(OUTPUT+2)
    sta ptr
    lda #>(OUTPUT+2)
    sta ptr+1
    lda #0
    sta mask_index
exercise_case:
    lda mask_index
    sta mask_shift
    ldx #0
exercise_flags:
    lda #0
    lsr mask_shift
    rol
    sta POOL_FLAGS,x
    inx
    cpx #POOL_CAPACITY
    bne exercise_flags
    ldy #$93
    jsr pool_acquire
    stx selected
    lda #0
    rol
    sta status_bits
    txa
    jsr emit
    jsr occupancy
    jsr emit
    ldx #255
    jsr pool_release
    bcc exercise_failed
    lda status_bits
    ora #2
    sta status_bits
    ldx selected
    cpx #POOL_CAPACITY
    beq exercise_full
    jsr pool_release
    bcs exercise_failed
    jsr pool_release
    bcc exercise_failed
    lda status_bits
    ora #8
    sta status_bits
exercise_full:
    jsr occupancy
    jsr emit
    lda status_bits
    jsr emit
    tya
    jsr emit
    inc mask_index
    bne exercise_case
; Explicit positive completion and guard/payload observations.
    lda #$a5
    sta OUTPUT
    lda #POOL_CAPACITY
    sta OUTPUT+1
    jsr pool_init
    jsr occupancy
    jsr emit
    lda POOL_FLAGS-1
    jsr emit
    lda POOL_FLAGS+POOL_CAPACITY
    jsr emit
    ldx #0
exercise_payload:
    lda POOL_LIFE,x
    jsr emit
    inx
    cpx #POOL_CAPACITY
    bne exercise_payload
    lda #$ef
    jsr emit
    rts
exercise_failed:
    jmp exercise_failed
; Does not modify X/Y. carry/flags clobbered.
emit:
    sty saved_y
    ldy #0
    sta (ptr),y
    inc ptr
    bne emit_done
    inc ptr+1
emit_done:
    ldy saved_y
    rts
; Bit i reports flag i; valid for this fixture's capacity 1..8 only.
occupancy:
    stx saved_x
    ldx #POOL_CAPACITY-1
    lda #0
    sta occupancy_bits
occupancy_loop:
    lda POOL_FLAGS,x
    lsr
    rol occupancy_bits
    dex
    bpl occupancy_loop
    ldx saved_x
    lda occupancy_bits
    rts
; Small useful client: fill, reject overflow, release/reuse, age without compaction.
preview_pool:
    jsr pool_init
    jsr pool_acquire
    stx preview
    jsr pool_acquire
    stx preview+1
    jsr pool_acquire
    stx preview+2
preview_fill:
    jsr pool_acquire
    bcc preview_fill
    lda #$ff
    sta preview+3
    ldx #1
.if !BROKEN
    jsr pool_release
.endif
    jsr pool_acquire
    bcc preview_reused
    ldx #$ff
preview_reused:
    stx preview+4
    ldx #255
    jsr pool_release
    lda #0
    rol
    sta preview+5
; Initialise payload only after claiming slots. All are occupied here.
    ldx #0
preview_life:
    txa
    and #1
    clc
    adc #1
    sta POOL_LIFE,x
    inx
    cpx #POOL_CAPACITY
    bne preview_life
    jsr pool_age
    jsr occupancy
    sta preview+6
    jsr pool_age
    jsr occupancy
    sta preview+7
    rts
; End of standalone pool preview.
