; Hold a tone on pulse 1: 50% duty, constant volume 15, no sweep.
; A = timer low byte, X = timer high bits (0-7). The 11-bit timer must be
; 8-$7FF; below 8 the channel is muted. NTSC pitch is 1789773/(16*(timer+1)) Hz.
; The caller owns $4015 and must already have set its bit 0: the $4003 write
; loads the length counter only while the channel is enabled.
; Clobbers A. Preserves X and Y.
PULSE1_CTRL  = $4000    ; DDLC VVVV: duty, length halt, constant volume, volume
PULSE1_SWEEP = $4001    ; EPPP NSSS: enable, period, negate, shift
PULSE1_LO    = $4002    ; timer bits 0-7
PULSE1_HI    = $4003    ; LLLL LHHH: length index, timer bits 8-10

pulse1_tone:
    pha
    lda #%10111111      ; duty 2 (50%), halt the length counter, constant volume 15
    sta PULSE1_CTRL
    lda #%00001000      ; sweep disabled, negate set: the sweep cannot mute it
    sta PULSE1_SWEEP
    pla
    sta PULSE1_LO
    stx PULSE1_HI       ; length index 0, timer high bits; restarts the duty step
    rts
