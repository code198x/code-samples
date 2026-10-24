; Deliberate fault: accept boundary equality.
; Half-open unsigned word edges [left,top,right,bottom].
; Reject empty/reversed boxes and touching edges. Returns D0=1/0; CCR changes.
; Other registers survive. Caller forms edges without word overflow.
boxes_overlap:
    move.w rect_a,d0
    cmp.w rect_a+4,d0
    bhs boxes_apart
    move.w rect_a+2,d0
    cmp.w rect_a+6,d0
    bhs boxes_apart
    move.w rect_b,d0
    cmp.w rect_b+4,d0
    bhs boxes_apart
    move.w rect_b+2,d0
    cmp.w rect_b+6,d0
    bhs boxes_apart
    move.w rect_a,d0
    cmp.w rect_b+4,d0
    beq wrong_accept_5
    bhs boxes_apart
wrong_accept_5:
    move.w rect_b,d0
    cmp.w rect_a+4,d0
    beq wrong_accept_6
    bhs boxes_apart
wrong_accept_6:
    move.w rect_a+2,d0
    cmp.w rect_b+6,d0
    beq wrong_accept_7
    bhs boxes_apart
wrong_accept_7:
    move.w rect_b+2,d0
    cmp.w rect_a+6,d0
    beq wrong_accept_8
    bhs boxes_apart
wrong_accept_8:
    moveq #1,d0
    rts
boxes_apart:
    moveq #0,d0
    rts
rect_a: dc.w 0,0,0,0
rect_b: dc.w 10,5,11,6
