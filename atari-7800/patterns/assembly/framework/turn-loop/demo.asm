; atari-7800: rule state and display servicing have separate counters.
T = $1900
!source "settings.inc"
* = $4000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #7
    sta $01                   ; enter/lock 7800 mode; BIOS authentication is external
    lda #0
    sta $3c                   ; MARIA DMA off during pointer setup
    lda #>dll
    sta $2c
    lda #<dll
    sta $30
wait_enable:
    bit $28                   ; enable DMA only during VBlank
    bpl wait_enable
    lda #$40
    sta $3c                   ; 160A, empty display lists, background visible
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
    lda $000c
    and #$80
    eor #$80
    jsr sample_turn
    lda T
    and #FEEDBACK_BIT
    beq even_turn
    lda #$44
    bne show
even_turn:
    lda #$84
show:
    sta $0020
    jmp main
!source "frame.inc"
!source "../../../../../cross-platform/patterns/framework/atari-turn-loops/turn.inc"
irq:
    rti
    !align 255,0
dll:
    !for i,1,16 { !byte $0f,>empty_list,<empty_list }
empty_list:
    !byte 0,0                 ; no objects; MARIA still renders the background
    !fill $fffa-*, $ff
    !word irq,start,irq
