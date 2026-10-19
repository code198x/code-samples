; Half-open unsigned byte edges [left,top,right,bottom].
; Reject empty/reversed boxes and edge-only contact. C=1 means overlap.
; Changes AF/B; preserves C/DE/HL/IX/IY. Caller forms edges without wrapping.
boxes_overlap:
    ld a,(rect_a+2)
    ld b,a
    ld a,(rect_a)
    cp b
    jr nc,boxes_apart
    ld a,(rect_a+3)
    ld b,a
    ld a,(rect_a+1)
    cp b
    jr nc,boxes_apart
    ld a,(rect_b+2)
    ld b,a
    ld a,(rect_b)
    cp b
    jr nc,boxes_apart
    ld a,(rect_b+3)
    ld b,a
    ld a,(rect_b+1)
    cp b
    jr nc,boxes_apart
    ld a,(rect_b+2)
    ld b,a
    ld a,(rect_a)
    cp b
    jr nc,boxes_apart
    ld a,(rect_a+2)
    ld b,a
    ld a,(rect_b)
    cp b
    jr nc,boxes_apart
    ld a,(rect_b+3)
    ld b,a
    ld a,(rect_a+1)
    cp b
    jr nc,boxes_apart
    ld a,(rect_a+3)
    ld b,a
    ld a,(rect_b+1)
    cp b
    jr nc,boxes_apart
    scf
    ret
boxes_apart:
    or a
    ret
rect_a: defb 0,0,0,0
rect_b: defb 10,5,11,6
