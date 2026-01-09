; ============================================================================
; SID Symphony - Unit 3: ADSR Envelopes
; ============================================================================
; The same note, three different envelopes, three different characters.
; This program demonstrates how ADSR shapes sound over time.
;
; Voice 1: Organ    - instant attack, full sustain, slow release
; Voice 2: String   - slow attack, medium decay, medium sustain
; Voice 3: Pluck    - instant attack, fast decay, no sustain
;
; The program repeatedly triggers all three voices so you can hear
; the attack and release phases in action.
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

SID_V1_FREQ_LO  = SID_BASE + 0
SID_V1_FREQ_HI  = SID_BASE + 1
SID_V1_PW_LO    = SID_BASE + 2
SID_V1_PW_HI    = SID_BASE + 3
SID_V1_CTRL     = SID_BASE + 4
SID_V1_AD       = SID_BASE + 5
SID_V1_SR       = SID_BASE + 6

SID_V2_FREQ_LO  = SID_BASE + 7
SID_V2_FREQ_HI  = SID_BASE + 8
SID_V2_PW_LO    = SID_BASE + 9
SID_V2_PW_HI    = SID_BASE + 10
SID_V2_CTRL     = SID_BASE + 11
SID_V2_AD       = SID_BASE + 12
SID_V2_SR       = SID_BASE + 13

SID_V3_FREQ_LO  = SID_BASE + 14
SID_V3_FREQ_HI  = SID_BASE + 15
SID_V3_PW_LO    = SID_BASE + 16
SID_V3_PW_HI    = SID_BASE + 17
SID_V3_CTRL     = SID_BASE + 18
SID_V3_AD       = SID_BASE + 19
SID_V3_SR       = SID_BASE + 20

SID_VOLUME      = SID_BASE + 24

; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------
GATE_ON         = %00000001
WAVE_PULSE      = %01000000

; Note frequencies (different pitches so you can hear each voice)
; Formula: freq_value = (frequency_hz * 16777216) / 985248
FREQ_C4_LO      = $67               ; Voice 1: C4 (organ) = $1167
FREQ_C4_HI      = $11
FREQ_E4_LO      = $ed               ; Voice 2: E4 (string) = $15ed
FREQ_E4_HI      = $15
FREQ_G4_LO      = $13               ; Voice 3: G4 (pluck) = $1a13
FREQ_G4_HI      = $1a

; Screen
BORDER_COLOUR   = $d020
BACKGROUND      = $d021

; Raster register for timing
RASTER          = $d012

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

                ; Master volume
                lda #15
                sta SID_VOLUME

                ; --------------------------------------------------------
                ; Configure Voice 1: "Organ" envelope
                ; Attack=0 (instant), Decay=0, Sustain=15, Release=9
                ; --------------------------------------------------------
                lda #FREQ_C4_LO
                sta SID_V1_FREQ_LO
                lda #FREQ_C4_HI
                sta SID_V1_FREQ_HI
                lda #$00
                sta SID_V1_PW_LO
                lda #$08
                sta SID_V1_PW_HI
                lda #$00            ; Attack=0, Decay=0
                sta SID_V1_AD
                lda #$f9            ; Sustain=15, Release=9 (slow fade)
                sta SID_V1_SR

                ; --------------------------------------------------------
                ; Configure Voice 2: "String" envelope
                ; Attack=12 (very slow ~1 sec swell), Decay=8, Sustain=10, Release=8
                ; --------------------------------------------------------
                lda #FREQ_E4_LO
                sta SID_V2_FREQ_LO
                lda #FREQ_E4_HI
                sta SID_V2_FREQ_HI
                lda #$00
                sta SID_V2_PW_LO
                lda #$08
                sta SID_V2_PW_HI
                lda #$c8            ; Attack=12 (~1 sec), Decay=8
                sta SID_V2_AD
                lda #$a8            ; Sustain=10, Release=8
                sta SID_V2_SR

                ; --------------------------------------------------------
                ; Configure Voice 3: "Pluck" envelope
                ; Attack=0 (instant), Decay=3 (very fast), Sustain=0, Release=0
                ; --------------------------------------------------------
                lda #FREQ_G4_LO
                sta SID_V3_FREQ_LO
                lda #FREQ_G4_HI
                sta SID_V3_FREQ_HI
                lda #$00
                sta SID_V3_PW_LO
                lda #$08
                sta SID_V3_PW_HI
                lda #$03            ; Attack=0, Decay=3 (very fast ~24ms)
                sta SID_V3_AD
                lda #$00            ; Sustain=0, Release=0
                sta SID_V3_SR

; ============================================================================
; Main loop - play each voice separately, then all together
; ============================================================================
main_loop:
                ; --- Voice 1: ORGAN (instant attack, sustained) ---
                lda #WAVE_PULSE | GATE_ON
                sta SID_V1_CTRL
                ldx #75                         ; ~1.5 seconds
.wait1on:       jsr wait_frame
                dex
                bne .wait1on
                lda #WAVE_PULSE
                sta SID_V1_CTRL
                ldx #50                         ; ~1 second release
.wait1off:      jsr wait_frame
                dex
                bne .wait1off

                ; --- Voice 2: STRING (slow swell) ---
                lda #WAVE_PULSE | GATE_ON
                sta SID_V2_CTRL
                ldx #100                        ; ~2 seconds (needs time to swell)
.wait2on:       jsr wait_frame
                dex
                bne .wait2on
                lda #WAVE_PULSE
                sta SID_V2_CTRL
                ldx #50
.wait2off:      jsr wait_frame
                dex
                bne .wait2off

                ; --- Voice 3: PLUCK (instant hit, fast decay) ---
                lda #WAVE_PULSE | GATE_ON
                sta SID_V3_CTRL
                ldx #75                         ; Sound fades during this time
.wait3on:       jsr wait_frame
                dex
                bne .wait3on
                lda #WAVE_PULSE
                sta SID_V3_CTRL
                ldx #25
.wait3off:      jsr wait_frame
                dex
                bne .wait3off

                ; --- All three together ---
                lda #WAVE_PULSE | GATE_ON
                sta SID_V1_CTRL
                sta SID_V2_CTRL
                sta SID_V3_CTRL
                ldx #100
.waitAllon:     jsr wait_frame
                dex
                bne .waitAllon
                lda #WAVE_PULSE
                sta SID_V1_CTRL
                sta SID_V2_CTRL
                sta SID_V3_CTRL
                ldx #75
.waitAlloff:    jsr wait_frame
                dex
                bne .waitAlloff

                ; Repeat the cycle
                jmp main_loop

; ----------------------------------------------------------------------------
; Wait for one frame (raster line 255 -> 0 transition)
; ----------------------------------------------------------------------------
wait_frame:
.wait1:         lda RASTER
                cmp #255
                bne .wait1
.wait2:         lda RASTER
                cmp #255
                beq .wait2
                rts
