    section code,code_c
    include "cases.inc"
    include "caller.inc"
helper_start:
    include "../../framework/collect-and-respond/collision.inc"
helper_end:
example: dc.w 2,2,8,6,8,2,13,6
    include "case-table.inc"
program_end:
