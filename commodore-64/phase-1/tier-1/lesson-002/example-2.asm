; Lesson 002, Example 2: Extended Frequency Table (C major scale)
; Demonstrates full octave scale playback

        * = $0801

!byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810

        jmp init        ; Skip over data tables

; Frequency table for C major scale (C4-C5) - A440 PAL tuning
freq_lo: !byte $67, $89, $ed, $3b, $13, $45, $da, $ce
freq_hi: !byte $11, $13, $15, $17, $1a, $1d, $20, $22
; C4=$1167, D4=$1389, E4=$15ED, F4=$173B, G4=$1A13
; A4=$1D45, B4=$20DA, C5=$22CE

note_count = 8

init:   jsr clear_sid
        ldx #$00

play_scale:
        ; Load frequency
        lda freq_lo,x
        sta $d400
        lda freq_hi,x
        sta $d401

        ; Note on with sawtooth (brighter sound for scale)
        lda #$21        ; Sawtooth + gate
        sta $d404

        ; Play duration (faster than example 1)
        jsr delay

        ; Note off
        lda #$20        ; Sawtooth, no gate
        sta $d404

        ; Brief pause
        jsr short_delay

        ; Next note
        inx
        cpx #note_count
        bne play_scale

        ; Pause at end of scale
        jsr long_delay

        ; Loop back
        jmp init

clear_sid:
        lda #$00
        ldx #$00
cls:    sta $d400,x
        inx
        cpx #$1d
        bne cls

        ; Faster attack/decay for scale
        lda #$44        ; Attack=4, Decay=4
        sta $d405
        lda #$f0        ; Sustain=15, Release=0
        sta $d406

        lda #$0f        ; Volume max
        sta $d418
        rts

; Note duration (~300ms)
delay:  ldy #$18
dly1:   ldx #$ff
dly2:   dex
        bne dly2
        dey
        bne dly1
        rts

; Short pause (~50ms)
short_delay:
        ldy #$04
sdly1:  ldx #$ff
sdly2:  dex
        bne sdly2
        dey
        bne sdly1
        rts

; Long pause at end (~1 second)
long_delay:
        ldy #$40
ldly1:  ldx #$ff
ldly2:  dex
        bne ldly2
        dey
        bne ldly1
        rts
