; ============================================================================
; CUSTOMISATION SECTION - Change these values and reassemble!
; ============================================================================

; --- SID Voice Settings ---
; Waveforms: $11=triangle, $21=sawtooth, $41=pulse, $81=noise
VOICE1_WAVE = $21               ; Sawtooth - bright, buzzy
VOICE2_WAVE = $41               ; Pulse - hollow, reedy
VOICE3_WAVE = $11               ; Triangle - soft, mellow

; Frequencies (higher = higher pitch)
; Common notes: $07=C3, $0E=C4, $1C=C5, $38=C6
VOICE1_FREQ = $1C               ; High pitch (C5)
VOICE2_FREQ = $0E               ; Mid pitch (C4)
VOICE3_FREQ = $07               ; Low pitch (C3)

; ADSR - Attack/Decay/Sustain/Release
; Attack: 0-15 (0=2ms, 15=8s)   Decay: 0-15 (0=6ms, 15=24s)
; Sustain: 0-15 (volume level)  Release: 0-15 (0=6ms, 15=24s)
VOICE_AD    = $09               ; Attack=0 (instant), Decay=9 (medium)
VOICE_SR    = $00               ; Sustain=0 (none), Release=0 (instant)

; Pulse width (only affects pulse wave, $41)
PULSE_WIDTH = $08               ; $08 = 50% duty cycle (square wave)

; --- Visual Settings ---
; Colours: 0=black, 1=white, 2=red, 3=cyan, 4=purple, 5=green
;          6=blue, 7=yellow, 8=orange, 9=brown, 10=light red
;          11=dark grey, 12=grey, 13=light green, 14=light blue, 15=light grey

BORDER_COL  = 6                 ; Blue border
BG_COL      = 0                 ; Black background

TRACK1_NOTE_COL = 10            ; Light red notes on track 1
TRACK2_NOTE_COL = 13            ; Light green notes on track 2
TRACK3_NOTE_COL = 14            ; Light blue notes on track 3

TRACK_LINE_COL = 11             ; Dark grey track lines
HIT_ZONE_COL = 7                ; Yellow hit zone

; ============================================================================
; END OF CUSTOMISATION - Code below uses the settings above
; ============================================================================
