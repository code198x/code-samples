; atari-2600: rule state and display servicing have separate counters.
T = $90
!source "settings.inc"
* = $f000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    ldx #$7f
clear_ram:
    sta $80,x
    dex
    bpl clear_ram
    lda #INITIAL_TURN
    jsr init_turn
    lda #$a5
    sta T-1
    sta T+7
    lda #STEP_SIZE
    sta T+5
    lda #2
    sta $01
frame:
    lda #2
    sta $00
    sta $02
    sta $02
    sta $02
    lda #0
    sta $00
    ldx #37
blank_lines:
    sta $02
    dex
    bne blank_lines
    lda #0
    sta $01
    ldx #192
visible_lines:
    sta $02
    dex
    bne visible_lines
    lda #2
    sta $01
    sta $02                   ; overscan 1; input/update owns next line
    lda $0c
    and #$80
    eor #$80
    jsr sample_turn
    sta $02                   ; overscan 2; service/feedback owns next line
    jsr service_tick
    lda T
    and #FEEDBACK_BIT
    beq even_turn
    lda #$44
    bne colour
even_turn:
    lda #$84
colour:
    sta $09
    sta $02                   ; overscan 3
!source "overscan-count.inc"
overscan:
    sta $02
    dex
    bne overscan
    jmp frame
!source "../../../../../cross-platform/patterns/framework/atari-turn-loops/turn.inc"
    !fill $fffa-*,0
    !word start,start,start
