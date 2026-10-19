; atari-7800: untimed turns from a new fire press, with independent field work.
; Owns display/input and $1900-$1904; stack is page 1. IRQ disabled.
turns = $1900
previous = $1901
clock_ticks = $1902
current = $1904
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
    lda #0
    sta turns
    sta previous
    sta clock_ticks
    sta clock_ticks+1
main:
    jsr wait_frame
    inc clock_ticks
    bne sample
    inc clock_ticks+1
sample:
    lda $000c
    and #$80
    eor #$80
    sta current
    lda previous
    eor #$ff
    and current
    beq no_action
    inc turns
no_action:
    lda current
    sta previous
    lda turns
    and #1
    beq even_turn
    lda #$44
    bne show
even_turn:
    lda #$84
show:
    sta $0020
    jmp main

wait_frame:
    bit $28                   ; MSTAT bit 7: leave any current VBlank
    bmi wait_frame
wait_new:
    bit $28
    bpl wait_new
    rts
irq:
    rti
    !align 255,0
dll:
    !for i,1,16 { !byte $0f,>empty_list,<empty_list }
empty_list:
    !byte 0,0                 ; no objects; MARIA still renders the background
    !fill $fffa-*, $ff
    !word irq,start,irq
