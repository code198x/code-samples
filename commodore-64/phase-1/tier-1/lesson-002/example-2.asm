; Lesson 002, Example 2: Extended Frequency Table (C major scale)
; Demonstrates full octave scale playback

        * = $0801

!byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810

        jmp init        ; Skip over data tables

; Frequency table for C major scale (C4-C5)
freq_lo: !byte $11, $27, $61, $6f, $f9, $b8, $23, $22, $bc
freq_hi: !byte $11, $13, $15, $16, $18, $1b, $1e, $22, $22
; C4=$1111, D4=$1327, E4=$1561, F4=$166F, G4=$18F9
; A4=$1BB8, B4=$1E23, C5=$2222, C5=$22BC (extended)

note_count = 9

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
