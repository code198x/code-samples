; SPDX-License-Identifier: MIT
DEF INITIAL EQU 0
DEF STEP EQU 1
DEF RESET_EACH EQU 0
DEF NO_EDGE EQU 0
DEF NO_WAIT EQU 0
DEF CTX EQU $C000
SECTION "Entry", ROM0[$100]
    nop
    jp start
    ds $134-@,0
    db "TURNS"
    ds $150-@,0
SECTION "Code", ROM0[$150]
    INCLUDE "caller.inc"
    INCLUDE "routines.inc"
    INCLUDE "presentation.inc"
    ds $8000-@,0
