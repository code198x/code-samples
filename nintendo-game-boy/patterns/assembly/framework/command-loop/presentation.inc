; Blank tile zero fills the cleared map. BGP changes colour zero by parity.
; AF changed. Owns background palette; no game-rule changes or VRAM writes.
show_turn:
    ld a,[CTX]
    and 1
    ld a,$E4
    jr z,show_palette
    ld a,$1B
show_palette:
    ld [$FF47],a
    ret
