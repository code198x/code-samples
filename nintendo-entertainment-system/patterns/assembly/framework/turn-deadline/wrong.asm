.segment "HEADER"
    .byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
DURATION = 180
.include "caller.inc"
.include "../game-loop/frame.inc"
.include "clock.inc"
.include "../input-to-sound/input.inc"
.include "../input-to-sound/presses.inc"
.include "../../../../../bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc"
dispatch_code_end:
.include "../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc"
deadline_code_end:
POLL_ROUTINE:
    sta DEADLINE+8
    stx DEADLINE+9
    jmp deadline_poll
code_end:
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
    .res 8192-272,0
