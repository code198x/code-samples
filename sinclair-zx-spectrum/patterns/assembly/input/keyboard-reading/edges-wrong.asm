    org $8000
ACTION_MASK equ $10
    include "edges-caller.inc"
    include "../../framework/input-to-sound/input.inc"
    include "../../framework/input-to-sound/presses.inc"
    include "edges.inc"
    include "edges-display.inc"
POLL_ROUTINE:
    xor a
    ld (previous_controls),a
    jp detect_control_edges
    end start
