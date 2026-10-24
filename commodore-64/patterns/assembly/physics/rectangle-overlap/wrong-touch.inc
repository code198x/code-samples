; Deliberate fault: accept equality at separation boundaries.
; Half-open boxes [left,top,right,bottom]; all edges unsigned bytes.
; Reject empty/reversed boxes and touching edges. Returns C=1 on overlap.
; Changes A/flags; preserves X/Y. No arithmetic inside the test.
boxes_overlap:
    lda rect_a
    cmp rect_a+2
    bcs boxes_apart
    lda rect_a+1
    cmp rect_a+3
    bcs boxes_apart
    lda rect_b
    cmp rect_b+2
    bcs boxes_apart
    lda rect_b+1
    cmp rect_b+3
    bcs boxes_apart
    lda rect_a
    cmp rect_b+2
    beq wrong_accept_5
    bcs boxes_apart
wrong_accept_5:
    lda rect_b
    cmp rect_a+2
    beq wrong_accept_6
    bcs boxes_apart
wrong_accept_6:
    lda rect_a+1
    cmp rect_b+3
    beq wrong_accept_7
    bcs boxes_apart
wrong_accept_7:
    lda rect_b+1
    cmp rect_a+3
    beq wrong_accept_8
    bcs boxes_apart
wrong_accept_8:
    sec
    rts
boxes_apart:
    clc
    rts
rect_a: !byte 0,0,0,0
rect_b: !byte 10,5,11,6
