; Each voice uses 7 consecutive registers
; Voice 1 starts at $D400 (offset +0)
; Voice 2 starts at $D407 (offset +7)
; Voice 3 starts at $D40E (offset +14)

SID_BASE        = $d400

; Voice 1 (offset +0)
SID_V1_FREQ_LO  = SID_BASE + 0
SID_V1_CTRL     = SID_BASE + 4

; Voice 2 (offset +7)
SID_V2_FREQ_LO  = SID_BASE + 7
SID_V2_CTRL     = SID_BASE + 11

; Voice 3 (offset +14)
SID_V3_FREQ_LO  = SID_BASE + 14
SID_V3_CTRL     = SID_BASE + 18
