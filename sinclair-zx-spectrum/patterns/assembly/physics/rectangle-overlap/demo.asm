    org $8000
    include "cases.inc"
    include "caller.inc"
    include "../../framework/collect-and-respond/collision.inc"
    include "display.inc"
example: defb 2,2,8,6,6,4,11,7
    include "case-table.inc"
    end start
