.segment "VECTORS"
    .word nmi               ; $FFFA-$FFFB: NMI vector
    .word reset             ; $FFFC-$FFFD: Reset vector
    .word irq               ; $FFFE-$FFFF: IRQ vector
