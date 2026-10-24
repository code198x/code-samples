.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
REMAINING=$80
REQUEST=$81
AVAILABLE=$82
GRANTED=$83
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
trace_index=$77
accepted=$78
blocked=$79
at_three=$7a
at_six=$7b
availability_guard=$7c
case_kind=$7d
OUTPUT=$0200
preview=OUTPUT+1480
ready=OUTPUT+1488
PERIOD=3
BROKEN=0
.include "caller.inc"
.include "exercise.inc"
component_start:
.include "component.inc"
.include "cases.inc"
code_end:
.segment "VECTORS"
.word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
.res 8192-272,0
