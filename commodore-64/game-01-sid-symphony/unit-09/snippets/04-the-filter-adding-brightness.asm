; SID filter registers
SID_FC_LO       = SID + $15     ; Filter cutoff low
SID_FC_HI       = SID + $16     ; Filter cutoff high
SID_RES_FILT    = SID + $17     ; Resonance + routing
SID_MODE_VOL    = SID + $18     ; Filter mode + volume

; Set up filter in init_sid
lda #$00
sta SID_FC_LO
lda #$40            ; Cutoff ~512 (medium)
sta SID_FC_HI
lda #$87            ; Resonance $8, route all voices
sta SID_RES_FILT
lda #$1f            ; Low-pass filter + volume 15
sta SID_MODE_VOL
