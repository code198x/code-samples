    org $8000
ACTION_MASK equ $04
    include "edges-caller.inc"
    include "../../framework/input-to-sound/input.inc"
    include "../../framework/input-to-sound/presses.inc"
    include "edges.inc"
    include "edges-display.inc"
POLL_ROUTINE:
    jp detect_control_edges
    end start
