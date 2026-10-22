; Alternate backdrop 2/3 using count parity. AF changed, no rule update.
; Direct control/status port ownership; no CPU-mapped text screen is implied.
show_turn:
    ld a,(CTX)
    and 1
    add a,2
    out ($02),a
    ld a,$87
    out ($02),a
    ret
