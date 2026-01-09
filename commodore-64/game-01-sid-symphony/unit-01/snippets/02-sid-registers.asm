; SID chip lives at $D400-$D41C
SID_BASE        = $d400

; Voice 1 registers (each voice uses 7 bytes)
SID_V1_FREQ_LO  = SID_BASE + 0      ; Frequency low byte
SID_V1_FREQ_HI  = SID_BASE + 1      ; Frequency high byte
SID_V1_PW_LO    = SID_BASE + 2      ; Pulse width low byte
SID_V1_PW_HI    = SID_BASE + 3      ; Pulse width high byte
SID_V1_CTRL     = SID_BASE + 4      ; Control register
SID_V1_AD       = SID_BASE + 5      ; Attack/Decay
SID_V1_SR       = SID_BASE + 6      ; Sustain/Release

; Global register (shared by all voices)
SID_VOLUME      = SID_BASE + 24     ; Master volume (bits 0-3)
