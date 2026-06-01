; ADSR Envelope - Shapes how the sound evolves over time
;
; Attack:  How quickly the sound reaches full volume (0=instant, 15=slow)
; Decay:   How quickly it drops to sustain level (0=instant, 15=slow)
; Sustain: Volume level while key is held (0=silent, 15=full)
; Release: How quickly it fades when released (0=instant, 15=slow)
;
; Packed into two bytes:
;   AD register: upper nibble = Attack, lower nibble = Decay
;   SR register: upper nibble = Sustain, lower nibble = Release
;
; Examples:
;
; $09, $00 = Instant attack, medium decay, no sustain, instant release
;            Good for: Plucked strings, percussion hits
;
; $00, $F0 = Instant everything, but sustain at max while gate is on
;            Good for: Organ, held notes
;
; $50, $90 = Slow attack, instant decay, high sustain, medium release
;            Good for: Pads, strings, atmospheric sounds
;
; $0C, $00 = Instant attack, long decay, no sustain
;            Good for: Piano-like decay

VOICE_AD    = $09               ; Attack=0, Decay=9
VOICE_SR    = $00               ; Sustain=0, Release=0
