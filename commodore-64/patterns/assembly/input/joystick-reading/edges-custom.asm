; PAL C64; joystick port 2; keyboard released. Reset to leave.
* = $0801
    !byte $0b,$08,$0a,$00,$9e
    !text "2064"
    !byte 0,0,0
* = $0810
ACTION_MASK = $04
!source "edges-caller.inc"
!source "joystick.inc"
!source "edges.inc"
POLL_ROUTINE:
    jmp joy_poll_edges
