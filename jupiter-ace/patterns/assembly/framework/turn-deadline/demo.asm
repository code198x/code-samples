; SPDX-License-Identifier: MIT
    org $3D00
DURATION equ 200
    include "caller.inc"
    include "clock.inc"
    include "input.inc"
    include "../../../../../cross-platform/patterns/framework/elapsed-deadline/z80.inc"
    include "dispatch.inc"
TURN: db 0
EXPIRIES: db 0
KEY: db 0
HELD: db 0
DEADLINE: defs 10,0
code_end:
