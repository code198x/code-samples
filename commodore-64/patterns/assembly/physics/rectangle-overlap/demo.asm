* = $0801
    !byte $0b,$08,$0a,$00,$9e
    !text "2064"
    !byte 0,0,0
* = $0810
!source "cases.inc"
!source "caller.inc"
helper_start:
!source "../../framework/collect-and-respond/collision.inc"
helper_end:
example: !byte 2,2,8,6,6,4,11,7
!source "case-table.inc"
