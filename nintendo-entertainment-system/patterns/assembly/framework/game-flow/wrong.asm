.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
FLOW_STATE=$80
FLOW_EVENTS=$81
FLOW_CHANGED=$82
FLOW_FRESH=$83
FLOW_ERROR=$84
case_state=$70
case_events=$71
ptr=$74
saved_y=$76
trace_index=$77
score=$78
health=$79
resets=$7a
resumed=$7b
finished=$7c
invalid_seen=$7d
previous=$7e
held=$7f
OUTPUT=$0200
preview=OUTPUT+1480
ready=OUTPUT+1488
RESET_HEALTH=3
BROKEN=1
.include "caller.inc"
.include "exercise.inc"
component_start:
.include "../../../../../cross-platform/patterns/framework/game-flow/6502.inc"
code_end:
.segment "VECTORS"
.word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
.res 8192-272,0
