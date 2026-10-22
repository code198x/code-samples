; atari-5200: rule state and display servicing have separate counters.
T = $1000
!source "settings.inc"
* = $4000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta $d40e                 ; disable ANTIC NMI ownership from BIOS
    sta $d400                 ; display-list DMA off: background-only output
    lda #INITIAL_TURN
    jsr init_turn
    lda #$a5
    sta T-1
    sta T+7
    lda #STEP_SIZE
    sta T+5
main:
    jsr wait_frame
    jsr service_tick
    lda $c010
    and #1
    eor #1
    jsr sample_turn
    lda T
    and #FEEDBACK_BIT
    beq even_turn
    lda #$44
    bne show
even_turn:
    lda #$84
show:
    sta $c01a
    jmp main
!source "frame.inc"
!source "../../../../../cross-platform/patterns/framework/atari-turn-loops/turn.inc"
    !fill $bffe-*, $ff
    !word start
