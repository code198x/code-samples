; SPDX-License-Identifier: MIT
    org $8000
DURATION equ 200
    include "caller.inc"
    include "mistakes/reset-baseline.inc"
    include "input.inc"
    include "../../../../../cross-platform/patterns/framework/elapsed-deadline/z80.inc"
    include "dispatch.inc"
TURN: db 0
EXPIRIES: db 0
KEY: db 0
HELD: db 0
DEADLINE: defs 10,0
READY: dw 0
code_end:
    end start
