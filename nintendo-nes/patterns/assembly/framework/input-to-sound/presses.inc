; Call once after read_controls. Changes A/flags; preserves X/Y.
; Clear previous_controls on startup; RAM is not initialised by .res.
.segment "BSS"
previous_controls: .res 1
new_presses: .res 1
.segment "CODE"
detect_presses:
    lda previous_controls
    eor #$ff
    and controls
    sta new_presses
    lda controls
    sta previous_controls
    rts
