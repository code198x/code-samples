; ============================================================================
; SID Symphony - Unit 2: The Three Voices
; ============================================================================
; The SID has three independent voices. This program plays a C major chord
; using all three, each with a different waveform.
;
; Voice 1: Triangle wave  - C4 (middle C)
; Voice 2: Sawtooth wave  - E4 (major third)
; Voice 3: Pulse wave     - G4 (perfect fifth)
; ============================================================================

* = $0801
                !byte $0c, $08, $0a, $00, $9e
                !text "2064"
                !byte $00, $00, $00

* = $0810

; ----------------------------------------------------------------------------
; SID registers
; ----------------------------------------------------------------------------
SID_BASE        = $d400

; Voice 1 (offset +0)
SID_V1_FREQ_LO  = SID_BASE + 0
SID_V1_FREQ_HI  = SID_BASE + 1
SID_V1_PW_LO    = SID_BASE + 2
SID_V1_PW_HI    = SID_BASE + 3
SID_V1_CTRL     = SID_BASE + 4
SID_V1_AD       = SID_BASE + 5
SID_V1_SR       = SID_BASE + 6

; Voice 2 (offset +7)
SID_V2_FREQ_LO  = SID_BASE + 7
SID_V2_FREQ_HI  = SID_BASE + 8
SID_V2_PW_LO    = SID_BASE + 9
SID_V2_PW_HI    = SID_BASE + 10
SID_V2_CTRL     = SID_BASE + 11
SID_V2_AD       = SID_BASE + 12
SID_V2_SR       = SID_BASE + 13

; Voice 3 (offset +14)
SID_V3_FREQ_LO  = SID_BASE + 14
SID_V3_FREQ_HI  = SID_BASE + 15
SID_V3_PW_LO    = SID_BASE + 16
SID_V3_PW_HI    = SID_BASE + 17
SID_V3_CTRL     = SID_BASE + 18
SID_V3_AD       = SID_BASE + 19
SID_V3_SR       = SID_BASE + 20

; Global
SID_VOLUME      = SID_BASE + 24

; ----------------------------------------------------------------------------
; Waveform bits (combine with GATE_ON)
; ----------------------------------------------------------------------------
GATE_ON         = %00000001
WAVE_TRI        = %00010000         ; Triangle - soft, flute-like
WAVE_SAW        = %00100000         ; Sawtooth - bright, brassy
WAVE_PULSE      = %01000000         ; Pulse - hollow, organ-like
WAVE_NOISE      = %10000000         ; Noise - no pitch, percussive

; ----------------------------------------------------------------------------
; Note frequencies (PAL)
; Formula: freq_value = (frequency_hz * 16777216) / 985248
; ----------------------------------------------------------------------------
FREQ_C4_LO      = $67               ; Middle C (261.63 Hz) = $1167
FREQ_C4_HI      = $11
FREQ_E4_LO      = $ed               ; E4 (329.63 Hz) = $15ed
FREQ_E4_HI      = $15
FREQ_G4_LO      = $13               ; G4 (392.00 Hz) = $1a13
FREQ_G4_HI      = $1a

; ----------------------------------------------------------------------------
; Screen registers
; ----------------------------------------------------------------------------
BORDER_COLOUR   = $d020
BACKGROUND      = $d021

; ============================================================================
; Program entry
; ============================================================================
start:
                ; Black screen
                lda #0
                sta BORDER_COLOUR
                sta BACKGROUND
                ldx #0
.clear:         lda #$20
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $06e8,x
                inx
                bne .clear

                ; Set master volume
                lda #15
                sta SID_VOLUME

                ; --------------------------------------------------------
                ; Voice 1: Triangle wave, C4
                ; --------------------------------------------------------
                lda #FREQ_C4_LO
                sta SID_V1_FREQ_LO
                lda #FREQ_C4_HI
                sta SID_V1_FREQ_HI
                lda #$00
                sta SID_V1_AD
                lda #$f0
                sta SID_V1_SR
                lda #WAVE_TRI | GATE_ON
                sta SID_V1_CTRL

                ; --------------------------------------------------------
                ; Voice 2: Sawtooth wave, E4
                ; --------------------------------------------------------
                lda #FREQ_E4_LO
                sta SID_V2_FREQ_LO
                lda #FREQ_E4_HI
                sta SID_V2_FREQ_HI
                lda #$00
                sta SID_V2_AD
                lda #$f0
                sta SID_V2_SR
                lda #WAVE_SAW | GATE_ON
                sta SID_V2_CTRL

                ; --------------------------------------------------------
                ; Voice 3: Pulse wave, G4 (with pulse width)
                ; --------------------------------------------------------
                lda #FREQ_G4_LO
                sta SID_V3_FREQ_LO
                lda #FREQ_G4_HI
                sta SID_V3_FREQ_HI
                ; Pulse width 50%
                lda #$00
                sta SID_V3_PW_LO
                lda #$08
                sta SID_V3_PW_HI
                lda #$00
                sta SID_V3_AD
                lda #$f0
                sta SID_V3_SR
                lda #WAVE_PULSE | GATE_ON
                sta SID_V3_CTRL

                ; Infinite loop
forever:
                jmp forever
