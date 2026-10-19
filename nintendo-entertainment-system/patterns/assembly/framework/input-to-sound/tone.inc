; Pulse 1, constant volume; owns $4000-$4003 and the $4015 enable shadow.
; Set apu_enable to the current shared enable mask; do not reset other channels.
; These routines change A/flags, preserve X/Y. No DMC is used here.
.segment "BSS"
apu_enable: .res 1
.segment "CODE"
tone_on:
    lda apu_enable
    ora #1
    sta apu_enable
    sta $4015
    lda #$bf                ; 50% duty, halted length, constant volume 15
    sta $4000
    lda #$08                ; sweep disabled, no one's-complement negation
    sta $4001
    lda #$fd                ; timer $0fd: about 440 Hz on NTSC
    sta $4002
    lda #0
    sta $4003
    rts
tone_off:
    lda apu_enable
    and #$fe
    sta apu_enable
    sta $4015
    rts
