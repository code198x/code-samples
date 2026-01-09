; ============================================================================
; SID Symphony - Unit 4: Playing a Scale
; ============================================================================
; From individual notes to melody. This program plays a C major scale
; ascending and descending - the foundation for all musical playback.
;
; Introduces:
; - Frequency lookup tables
; - Indexed addressing
; - Frame-based timing for note duration
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
SID_VOLUME      = SID_BASE + 24

; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------
GATE_ON         = %00000001
WAVE_PULSE      = %01000000

BORDER_COLOUR   = $d020
BACKGROUND      = $d021
RASTER          = $d012

SCALE_LENGTH    = 8                 ; 8 notes in the scale (C to C)
NOTE_DURATION   = 25                ; Frames per note (~0.5 sec at 50fps)

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

                ; Configure voice 1
                lda #$00
                sta SID_V1_PW_LO
                lda #$08
                sta SID_V1_PW_HI
                lda #$00            ; Instant attack, no decay
                sta SID_V1_AD
                lda #$f6            ; Full sustain, medium release
                sta SID_V1_SR

; ============================================================================
; Main loop - play scale up and down
; ============================================================================
main_loop:
                ; --- Ascending scale ---
                ldx #0
.ascending:
                jsr play_note       ; Play note at index X
                inx
                cpx #SCALE_LENGTH
                bne .ascending

                ; --- Descending scale (skip the top C, start from B) ---
                ldx #SCALE_LENGTH - 2
.descending:
                jsr play_note       ; Play note at index X
                dex
                bpl .descending     ; Continue while X >= 0

                ; Loop forever
                jmp main_loop

; ----------------------------------------------------------------------------
; Play note at index X from the frequency table
; Preserves X for the caller
; ----------------------------------------------------------------------------
play_note:
                stx temp_x          ; Save X

                ; Load frequency from table
                lda freq_lo,x
                sta SID_V1_FREQ_LO
                lda freq_hi,x
                sta SID_V1_FREQ_HI

                ; Gate on - start the note
                lda #WAVE_PULSE | GATE_ON
                sta SID_V1_CTRL

                ; Hold for NOTE_DURATION frames
                ldy #NOTE_DURATION
.hold:          jsr wait_frame
                dey
                bne .hold

                ; Gate off - release the note
                lda #WAVE_PULSE
                sta SID_V1_CTRL

                ; Brief gap between notes (5 frames)
                ldy #5
.gap:           jsr wait_frame
                dey
                bne .gap

                ldx temp_x          ; Restore X
                rts

; Temporary storage
temp_x:         !byte 0

; ----------------------------------------------------------------------------
; Wait for one frame
; ----------------------------------------------------------------------------
wait_frame:
                pha
.wait1:         lda RASTER
                cmp #255
                bne .wait1
.wait2:         lda RASTER
                cmp #255
                beq .wait2
                pla
                rts

; ============================================================================
; Frequency table - C major scale (C4 to C5)
; ============================================================================
; Each note has a 16-bit frequency value, split into low and high bytes.
; These values are for PAL C64 (clock = 985248 Hz).
;
; Formula: freq_value = (note_hz * 16777216) / 985248

freq_lo:
                !byte $16           ; C4  - 261.63 Hz
                !byte $27           ; D4  - 293.66 Hz
                !byte $5b           ; E4  - 329.63 Hz
                !byte $8f           ; F4  - 349.23 Hz
                !byte $e1           ; G4  - 392.00 Hz
                !byte $57           ; A4  - 440.00 Hz
                !byte $f4           ; B4  - 493.88 Hz
                !byte $2c           ; C5  - 523.25 Hz

freq_hi:
                !byte $11           ; C4
                !byte $13           ; D4
                !byte $15           ; E4
                !byte $16           ; F4
                !byte $18           ; G4
                !byte $1b           ; A4
                !byte $1d           ; B4
                !byte $22           ; C5
