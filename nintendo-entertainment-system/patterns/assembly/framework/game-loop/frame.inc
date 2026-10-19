; NMI owns frame_clock; main owns last_frame/frame_delta.
; Call initialise_clock before enabling NMI. NMI handler must preserve registers.
; A/X/flags change. NMI must remain enabled. No other reader consumes this state.
; Work must take fewer than 256 frames between accepted samples.
.segment "CODE"
initialise_clock:
    lda frame_clock
    sta last_frame
    rts
wait_frame:
    lda frame_clock
    cmp last_frame
    beq wait_frame
    tax
    sec
    sbc last_frame
    sta frame_delta
    stx last_frame
    rts
.segment "BSS"
frame_clock: .res 1
last_frame: .res 1
frame_delta: .res 1
