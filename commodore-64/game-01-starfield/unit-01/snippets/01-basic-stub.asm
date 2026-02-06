; BASIC stub: 10 SYS 2061
; These bytes encode a single BASIC line that jumps
; to our machine code at address $080D (decimal 2061)
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00
