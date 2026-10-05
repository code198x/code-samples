; Start and stop a note on one SID voice.
;
; Before including this file, set SID_VOICE to the voice's first register:
; $D400 for voice 1, $D407 for voice 2, $D40E for voice 3.
; Include it once; it defines one set of routines for that voice.
;
; The routines write only SID_VOICE+0 to SID_VOICE+6 and never read a SID
; register ($D400-$D418 are write-only). Master volume, filter routing and
; the other voices ($D415-$D418 and the remaining voice registers) belong
; to the caller. If an interrupt handler also writes this voice, the caller
; must stop the two from interleaving; these routines do not arbitrate.
;
; Each routine changes A and the flags and preserves X and Y.

SID_WAVE_PULSE  = $40
SID_GATE        = $01

; A = attack/decay ($D405 layout), X = sustain/release ($D406 layout).
; Selects the pulse waveform at 50% width with the gate clear. If the voice
; was gated, clearing the gate starts its release.
sid_voice_setup:
    sta SID_VOICE+5
    stx SID_VOICE+6
    lda #$00
    sta SID_VOICE+2
    lda #$08
    sta SID_VOICE+3
    lda #SID_WAVE_PULSE
    sta SID_VOICE+4
    rts

; A = frequency high byte, X = frequency low byte.
; Clears the gate, then sets it, so a new attack begins even if the voice
; was still gated. The attack rises from the envelope's current level,
; not from zero.
sid_note_on:
    stx SID_VOICE+0
    sta SID_VOICE+1
    lda #SID_WAVE_PULSE
    sta SID_VOICE+4
    lda #SID_WAVE_PULSE | SID_GATE
    sta SID_VOICE+4
    rts

; Clears the gate. Release falls from the current level at the release
; rate. The waveform stays selected; the envelope silences the voice.
sid_note_off:
    lda #SID_WAVE_PULSE
    sta SID_VOICE+4
    rts
