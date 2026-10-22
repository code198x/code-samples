; Capability caller: original input/frame service, explicit drawing and sound.
; atari-5200: untimed turns from a new fire press, with independent field work.
; Owns display/input and $1000-$1004; stack is page 1. IRQ disabled.
turns = $1000
previous = $1001
clock_ticks = $1002
current = $1004
* = $4000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta $d40e                 ; disable ANTIC NMI ownership from BIOS
    sta $d400                 ; display-list DMA off: background-only output
    lda #0
    sta turns
    sta previous
    sta clock_ticks
    sta clock_ticks+1
    jsr init_picture
main:
    jsr wait_frame
    inc clock_ticks
    bne sample
    inc clock_ticks+1
sample:
    !source "sample.inc"
    lda previous
    eor #$ff
    and current
    beq no_action
    inc turns
    jsr trigger_sound
no_action:
    lda current
    sta previous
    jsr draw_picture
    jsr service_sound
    jmp main

wait_frame:
    lda $d40b                 ; VCOUNT bit 7 covers the tail of the NTSC field
    bmi wait_frame
wait_new:
    lda $d40b
    bpl wait_new
    rts
!source "picture.inc"
!source "sound.inc"
    !fill $bffe-*, $ff
    !word start               ; genuine BIOS cartridge handover address
