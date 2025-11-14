; Lesson 002, Example 1: Frequency Table (C-E-G major chord)
; Demonstrates frequency lookup table and sequential playback

        * = $0801

        ; BASIC stub: 10 SYS 2064
!byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810

; Frequency table for C, E, G (major chord) - A440 PAL tuning
freq_lo: !byte $67, $ed, $13  ; Low bytes
freq_hi: !byte $11, $15, $1a  ; High bytes
; C4 = $1167, E4 = $15ED, G4 = $1A13

init:   jsr clear_sid
        ldx #$00        ; Start at note index 0

play_note:
        ; Load frequency from table
        lda freq_lo,x
        sta $d400       ; Voice 1 frequency low
        lda freq_hi,x
        sta $d401       ; Voice 1 frequency high

        ; Note on (triangle + gate)
        lda #$11
        sta $d404

        ; Play duration
        jsr delay

        ; Note off (triangle, no gate)
        lda #$10
        sta $d404

        ; Brief silence between notes
        jsr short_delay

        ; Next note
        inx
        cpx #$03        ; 3 notes in table
        bne play_note

        ; Loop back to start
        jmp init

clear_sid:
        lda #$00
        ldx #$00
cls_loop:
        sta $d400,x
        inx
        cpx #$1d        ; 29 SID registers
        bne cls_loop

        ; Set ADSR envelope
        lda #$08        ; Attack=0, Decay=8
        sta $d405
        lda #$f0        ; Sustain=15, Release=0
        sta $d406

        ; Set volume
        lda #$0f        ; Maximum volume
        sta $d418
        rts

; Note duration (~500ms)
delay:  ldy #$20        ; Outer loop (32 iterations)
dly1:   ldx #$ff        ; Inner loop (255 iterations)
dly2:   dex
        bne dly2
        dey
        bne dly1
        rts

; Short pause (~100ms)
short_delay:
        ldy #$08        ; Shorter outer loop
sdly1:  ldx #$ff
sdly2:  dex
        bne sdly2
        dey
        bne sdly1
        rts
