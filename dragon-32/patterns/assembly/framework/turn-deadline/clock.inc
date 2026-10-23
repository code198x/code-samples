; Dragon 32 ROM IRQ owns TIMER $0112..$0113. Snapshot with IRQ masked.
; No vector, PIA or global clock writes. Preserve caller interrupt mask.
clock_read:
    pshs cc
    orcc #$10
    ldd $0112
    puls cc,pc
