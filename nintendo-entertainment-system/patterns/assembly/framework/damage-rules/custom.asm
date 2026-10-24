.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
HEALTH=$80
REMAINING=$81
AMOUNT=$82
APPLIED=$83
KILLED=$84
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
trace_index=$77
accepted=$78
first_death=$79
deaths=$7a
blocked=$7b
snapshot=$7c
OUTPUT=$0200
preview=OUTPUT+1480
ready=OUTPUT+1488
PERIOD=5
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
