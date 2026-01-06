TIMER_START     equ     1500        ; 30 seconds at 50fps
TIMER_WARNING   equ     500         ; Flash when below 10 seconds

; Timer state
timer_value:    ds.w    1           ; Current countdown value
