; ============================================================================
; SID Symphony - Unit 1: First Sound
; ============================================================================
; Your first contact with the SID chip. This program does one thing:
; make the C64 produce a continuous tone.
;
; No graphics. No input. Just sound.
; ============================================================================

; BASIC stub - allows the program to run with LOAD"*",8,1 then RUN
* = $0801
                !byte $0c, $08      ; Pointer to next BASIC line
                !byte $0a, $00      ; Line number 10
                !byte $9e           ; SYS token
                !text "2064"        ; Address in decimal
                !byte $00           ; End of line
                !byte $00, $00      ; End of BASIC program

; ============================================================================
; Main program starts at $0810 (2064 decimal)
; ============================================================================
* = $0810

; ----------------------------------------------------------------------------
; SID chip registers (active voice 1 only for now)
; ----------------------------------------------------------------------------
SID_BASE        = $d400

; Voice 1 registers
SID_V1_FREQ_LO  = SID_BASE + 0      ; Frequency low byte
SID_V1_FREQ_HI  = SID_BASE + 1      ; Frequency high byte
SID_V1_PW_LO    = SID_BASE + 2      ; Pulse width low byte
SID_V1_PW_HI    = SID_BASE + 3      ; Pulse width high byte
SID_V1_CTRL     = SID_BASE + 4      ; Control register
SID_V1_AD       = SID_BASE + 5      ; Attack/Decay
SID_V1_SR       = SID_BASE + 6      ; Sustain/Release

; Global SID registers
SID_VOLUME      = SID_BASE + 24     ; Volume and filter mode

; ----------------------------------------------------------------------------
; Control register bits
; ----------------------------------------------------------------------------
GATE_ON         = %00000001         ; Bit 0: Gate (triggers ADSR)
WAVEFORM_TRI    = %00010000         ; Bit 4: Triangle wave
WAVEFORM_SAW    = %00100000         ; Bit 5: Sawtooth wave
WAVEFORM_PULSE  = %01000000         ; Bit 6: Pulse wave
WAVEFORM_NOISE  = %10000000         ; Bit 7: Noise

; ----------------------------------------------------------------------------
; Screen registers (we'll explore these properly in later units)
; ----------------------------------------------------------------------------
BORDER_COLOUR   = $d020
BACKGROUND      = $d021

; ============================================================================
; Program entry point
; ============================================================================
start:
                ; Clear the screen to black (we'll learn how this works later)
                lda #0
                sta BORDER_COLOUR
                sta BACKGROUND

                ; Hide BASIC text by filling screen with spaces
                ldx #0
.clear:         lda #$20            ; Space character
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $06e8,x
                inx
                bne .clear

                ; Set master volume to maximum (15)
                lda #15
                sta SID_VOLUME

                ; Set frequency for middle C (C4)
                ; The SID frequency formula is: freq_value = (frequency_hz * 16777216) / clock
                ; For PAL C64 (clock = 985248 Hz), middle C (261.63 Hz) = $1168
                lda #$68            ; Low byte
                sta SID_V1_FREQ_LO
                lda #$11            ; High byte
                sta SID_V1_FREQ_HI

                ; Set pulse width to 50% (for pulse wave)
                ; Pulse width is 12 bits. $0800 = 2048 = 50%
                lda #$00
                sta SID_V1_PW_LO
                lda #$08
                sta SID_V1_PW_HI

                ; Set ADSR envelope
                ; Attack = 0 (instant), Decay = 0 (none)
                lda #$00
                sta SID_V1_AD
                ; Sustain = 15 (full), Release = 0 (instant)
                lda #$f0
                sta SID_V1_SR

                ; Select pulse waveform and open the gate
                ; Gate ON starts the ADSR cycle
                lda #WAVEFORM_PULSE | GATE_ON
                sta SID_V1_CTRL

                ; Infinite loop - keep the program running
                ; Without this, the program would return to BASIC
                ; and the SID would be silenced
forever:
                jmp forever
