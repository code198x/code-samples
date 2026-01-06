; Base speeds (level 1)
BASE_CAR_SPEED      equ     2
BASE_LOG_SPEED      equ     1

; Speed increase per level (fixed point: 16 = 1.0)
SPEED_INCREASE      equ     2       ; +12.5% per level

; Maximum speed multiplier (16 = 1.0, 32 = 2.0)
MAX_SPEED_MULT      equ     32      ; Cap at 2x speed
