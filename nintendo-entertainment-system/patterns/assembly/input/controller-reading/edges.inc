; Include the maintained reader and presses.inc once before this wrapper.
; A/X/flags change; Y survives. Keep DMC DMA off for the simple reader.
.segment "BSS"
released_controls: .res 1
edge_scratch: .res 1
.segment "CODE"
detect_control_edges:
    lda previous_controls
    sta released_controls
    jsr detect_presses
    lda released_controls
    ldx controls
    jsr release_bits
    sta released_controls
    rts
; Pure entry: A=previous, X=current byte; A=released, X/Y survive.
release_bits:
    sta edge_scratch
    txa
    eor #$ff
    and edge_scratch
    rts
edges_code_end:
