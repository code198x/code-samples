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
OUTPUT=$c000
preview=OUTPUT+1480
ready=OUTPUT+1488
RESET_HEALTH=3
BROKEN=0
!source "caller.inc"
!source "exercise.inc"
component_start:
!source "../../../../../cross-platform/patterns/framework/game-flow/6502.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
