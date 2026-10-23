; SPDX-License-Identifier: MIT
    org $C000
DURATION equ 240
    include "caller.inc"
    include "mistakes/reset-baseline.inc"
    include "input.inc"
    include "../../../../../cross-platform/patterns/framework/elapsed-deadline/z80.inc"
    include "dispatch.inc"
TURN: db 0
EXPIRIES: db 0
KEY: db 0
UNUSED: db 0
DEADLINE: defs 10,0
DISPLAY: db "00 00 00"
code_end:
