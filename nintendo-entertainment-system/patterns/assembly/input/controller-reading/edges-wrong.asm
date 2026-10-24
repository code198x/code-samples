.segment "HEADER"
    .byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
ACTION_MASK = $80
.include "edges-caller.inc"
.include "../../framework/input-to-sound/input.inc"
.include "../../framework/input-to-sound/presses.inc"
.include "edges.inc"
POLL_ROUTINE:
    lda #0
    sta previous_controls
    jmp detect_control_edges
code_end:
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
.include "edges-font.inc"
    .res 8192-272,0
