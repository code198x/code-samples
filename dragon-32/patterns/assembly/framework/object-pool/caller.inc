    org $6000
mask_index equ $6600
mask_shift equ $6601
selected equ $6602
status_bits equ $6603
saved_y equ $6604
saved_x equ $6605
occupancy_bits equ $6606
init_sig equ $6607
preview equ $6608
check_a equ $6612
check_b equ $6613
ready equ $6614
end_ptr equ $6616
case_i equ $6618
saved_dp equ $661a
POOL_FLAGS equ $6800
POOL_LIFE equ $6a00
OUTPUT equ $6c00
start:
    pshs cc,dp,d,x,y,u
    tfr dp,a
    sta saved_dp
    lda #BOUNDARY
    beq main_normal
    jsr boundary_pool
    lda #1
    sta check_a
    sta check_b
    bra main_finish
main_normal:
    jsr exercise_pool
    jsr preview_pool
    clr check_a
    clr check_b
    lda preview+4
    cmpa #1
    bne main_a_done
    inc check_a
main_a_done:
    tst preview+8
    bne main_b_done
    inc check_b
main_b_done:
    ldx #preview
    ldb #9
main_preview:
    lda ,x+
    jsr emit
    decb
    bne main_preview
main_finish:
    tfr dp,a
    cmpa saved_dp
    beq main_dp_ok
    clr check_b
main_dp_ok:
    lda check_a
    jsr emit
    lda check_b
    jsr emit
    lda #239
    jsr emit
    sty end_ptr
    lda #239
    sta ready
    puls cc,dp,d,x,y,u,pc
exercise_pool:
    lda #90
    sta POOL_FLAGS-1
    lda #167
    sta POOL_FLAGS+POOL_CAPACITY
    ldx #POOL_LIFE
    ldb #POOL_CAPACITY
    lda #60
exercise_dirty:
    sta ,x+
    decb
    bne exercise_dirty
    ldu #$9352
    jsr pool_init
    cmpu #$9352
    lbne exercise_failed
    lda #147
    sta init_sig
    ldy #OUTPUT+3
    clr mask_index
exercise_case:
    lda mask_index
    sta mask_shift
    ldx #POOL_FLAGS
    ldb #POOL_CAPACITY
exercise_flags:
    lsr mask_shift
    lda #0
    rola
    sta ,x+
    decb
    bne exercise_flags
    ldu #$9352
    jsr pool_acquire
    stb selected
    tfr cc,a
    anda #1
    sta status_bits
    tfr b,a
    jsr emit
    jsr occupancy
    jsr emit
    ldb #255
    jsr pool_release
    lbcc exercise_failed
    lda status_bits
    ora #2
    sta status_bits
    ldb selected
    cmpb #POOL_CAPACITY
    beq exercise_full
    jsr pool_release
    lbcs exercise_failed
    ldb selected
    jsr pool_release
    lbcc exercise_failed
    lda status_bits
    ora #8
    sta status_bits
exercise_full:
    jsr occupancy
    jsr emit
    lda status_bits
    jsr emit
    cmpu #$9352
    lbne exercise_failed
    lda #147
    jsr emit
    inc mask_index
    lbne exercise_case
    lda #165
    sta OUTPUT
    lda #POOL_CAPACITY
    sta OUTPUT+1
    lda init_sig
    sta OUTPUT+2
    jsr pool_init
    jsr occupancy
    jsr emit
    lda POOL_FLAGS-1
    jsr emit
    lda POOL_FLAGS+POOL_CAPACITY
    jsr emit
    ldx #POOL_LIFE
    ldb #POOL_CAPACITY
exercise_payload:
    lda ,x+
    jsr emit
    decb
    bne exercise_payload
    lda #239
    jsr emit
    rts
exercise_failed:
    bra exercise_failed
emit:
    pshs cc
    sta ,y+
    puls cc,pc
occupancy:
    ldx #POOL_FLAGS+POOL_CAPACITY-1
    ldb #POOL_CAPACITY
    clr occupancy_bits
occupancy_loop:
    lda ,x
    leax -1,x
    lsra
    rol occupancy_bits
    decb
    bne occupancy_loop
    lda occupancy_bits
    rts
preview_pool:
    jsr pool_init
    jsr pool_acquire
    stb preview
    jsr pool_acquire
    stb preview+1
    jsr pool_acquire
    stb preview+2
preview_fill:
    jsr pool_acquire
    bcc preview_fill
    lda #255
    sta preview+3
    lda #BROKEN
    bne preview_no_release
    ldb #1
    jsr pool_release
preview_no_release:
    jsr pool_acquire
    bcc preview_reused
    ldb #255
preview_reused:
    stb preview+4
    tfr cc,a
    anda #1
    sta preview+8
    ldb #255
    jsr pool_release
    tfr cc,a
    anda #1
    sta preview+5
    ldx #POOL_LIFE
    clrb
preview_life:
    tfr b,a
    anda #1
    inca
    sta ,x+
    incb
    cmpb #POOL_CAPACITY
    bne preview_life
    jsr pool_age
    jsr occupancy
    sta preview+6
    jsr pool_age
    jsr occupancy
    sta preview+7
    rts
boundary_pool:
    ldy #OUTPUT+3
    lda #90
    sta POOL_FLAGS-1
    lda #167
    sta POOL_FLAGS+POOL_CAPACITY
    ldu #$9352
    jsr pool_init
    cmpu #$9352
    lbne exercise_failed
    lda #147
    sta OUTPUT+2
    lda #165
    sta OUTPUT
    lda #POOL_CAPACITY
    sta OUTPUT+1
    jsr snapshot_flags
    clr case_i
boundary_case:
    ldx #POOL_FLAGS
    ldb #POOL_CAPACITY
    lda #1
boundary_fill:
    sta ,x+
    decb
    bne boundary_fill
    ldx #free_cases
    ldb case_i
    abx
    ldb ,x
    cmpb #POOL_CAPACITY
    bhs boundary_acquire
    ldx #POOL_FLAGS
    abx
    clr ,x
boundary_acquire:
    ldu #$9352
    jsr pool_acquire
    stb selected
    tfr cc,a
    anda #1
    sta status_bits
    tfr b,a
    jsr emit
    lda status_bits
    jsr emit
    jsr snapshot_flags
    ldb selected
    jsr pool_release
    tfr cc,a
    anda #1
    jsr emit
    ldb selected
    jsr pool_release
    tfr cc,a
    anda #1
    jsr emit
    ldb #POOL_CAPACITY
    jsr pool_release
    tfr cc,a
    anda #1
    jsr emit
    jsr snapshot_flags
    cmpu #$9352
    lbne exercise_failed
    lda #147
    jsr emit
    inc case_i
    lda case_i
    cmpa #CASE_COUNT
    lbne boundary_case
    ldx #POOL_FLAGS
    ldb #POOL_CAPACITY
    lda #1
boundary_long_flags:
    sta ,x+
    decb
    bne boundary_long_flags
    ldx #POOL_LIFE
    ldb #POOL_CAPACITY
    lda #255
boundary_long_life:
    sta ,x+
    decb
    bne boundary_long_life
    jsr pool_age
    jsr snapshot_flags
    jsr snapshot_life
    ldx #POOL_LIFE
    ldb #POOL_CAPACITY
    lda #1
boundary_short_life:
    sta ,x+
    decb
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
    ldx #POOL_FLAGS
    ldb #POOL_CAPACITY
snapshot_flags_loop:
    lda ,x+
    jsr emit
    decb
    bne snapshot_flags_loop
    rts
snapshot_life:
    ldx #POOL_LIFE
    ldb #POOL_CAPACITY
snapshot_life_loop:
    lda ,x+
    jsr emit
    decb
    bne snapshot_life_loop
    rts
    include "pool.inc"
    include "age.inc"
free_cases:
    fcb 0,SECOND_FREE,128,254,255
code_end:
