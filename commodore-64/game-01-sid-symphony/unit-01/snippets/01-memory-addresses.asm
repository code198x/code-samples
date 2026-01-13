; ----------------------------------------------------------------------------
; Memory Addresses
; ----------------------------------------------------------------------------

SCREEN      = $0400             ; Screen memory base
COLRAM      = $D800             ; Colour RAM base
BORDER      = $D020             ; Border colour
BGCOL       = $D021             ; Background colour

; SID registers
SID         = $D400             ; SID base address
SID_V1_FREQ_LO = $D400          ; Voice 1 frequency low
SID_V1_FREQ_HI = $D401          ; Voice 1 frequency high
SID_V1_CTRL = $D404             ; Voice 1 control register
SID_V1_AD   = $D405             ; Voice 1 attack/decay
SID_V1_SR   = $D406             ; Voice 1 sustain/release

SID_V2_FREQ_LO = $D407          ; Voice 2 frequency low
SID_V2_FREQ_HI = $D408          ; Voice 2 frequency high
SID_V2_CTRL = $D40B             ; Voice 2 control register
SID_V2_AD   = $D40C             ; Voice 2 attack/decay
SID_V2_SR   = $D40D             ; Voice 2 sustain/release

SID_V3_FREQ_LO = $D40E          ; Voice 3 frequency low
SID_V3_FREQ_HI = $D40F          ; Voice 3 frequency high
SID_V3_CTRL = $D412             ; Voice 3 control register
SID_V3_AD   = $D413             ; Voice 3 attack/decay
SID_V3_SR   = $D414             ; Voice 3 sustain/release

SID_VOLUME  = $D418             ; Volume and filter mode

; CIA keyboard
CIA1_PRA    = $DC00             ; CIA1 Port A (keyboard column)
CIA1_PRB    = $DC01             ; CIA1 Port B (keyboard row)
