; Diagnostic only. Each wait arranges a real VBlank NMI between stores.
; The generator inserts EARLY or LATE publication at the marked boundaries.
handoff_experiment:
    lda #$1C
    sta request_lo
    lda #1
    sta request_hi
    sta handoff_stage
    jsr wait_handoff_nmi    ; stage 1: empty

    lda #2
    sta handoff_stage
; EARLY_PUBLICATION
    lda #$D5
    sta request_lo
    jsr wait_handoff_nmi    ; stage 2: consumer meets a half-written pair

    lda #3
    sta handoff_stage
    lda #0
    sta request_hi
; LATE_PUBLICATION
    jsr wait_handoff_nmi    ; stage 3: only safe version now has a ready request

    lda #4
    sta handoff_stage
    ldx #$52
    ldy #1
    jsr publish_period     ; A: empty -> accepted
    ldx #$7C
    ldy #1
    jsr publish_period     ; B: full -> refuse without overwriting A
    lda #0
    rol a
    sta handoff_deferred   ; record carry, not an unreported dropped cue
    lda request_lo
    sta full_lo
    lda request_hi
    sta full_hi
    jsr wait_handoff_nmi

    lda #5
    sta handoff_stage
    ldx #$7C
    ldy #1
    jsr publish_period     ; caller explicitly retries retained B
    jsr wait_handoff_nmi

    lda #6
    sta handoff_stage
    jsr wait_handoff_nmi    ; empty: no replay of B
    lda #$30
    sta SQ1_VOL
    lda #1
    sta handoff_done
handoff_idle:
    jmp handoff_idle

wait_handoff_nmi:
    lda handoff_clock
@wait:
    cmp handoff_clock
    beq @wait
    rts

; Log what NMI actually sees before consuming; not learner mailbox machinery.
handoff_observe:
    lda handoff_stage
    beq @skip
    lda handoff_count
    cmp #6
    bcs @skip
    asl a
    asl a
    tax
    lda handoff_stage
    sta $0300,x
    lda request_ready
    sta $0301,x
    lda request_lo
    sta $0302,x
    lda request_hi
    sta $0303,x
    inc handoff_count
@skip:
    jsr consume_period
    inc handoff_clock
    rts
