    section code,code_c
DURATION equ 50
    include "caller.inc"
    include "clock.inc"
    include "policy.inc"
policy_code_end:
    include "../../../../../cross-platform/patterns/framework/elapsed-deadline/m68000.inc"
deadline_code_end:
POLL_ROUTINE:
    bra deadline_poll
    include "../input-to-sound/input.inc"
    include "../../input/joystick-edge-detection/edges.inc"
    include "display.inc"
    include "font.inc"
program_end:
