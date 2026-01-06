reset_timer:
            bsr     get_level_timer
            move.w  d0,timer_value
            rts

; Call from start_new_game
start_new_game:
            ; ... existing code ...
            bsr     reset_timer
            ; ...

; Call from reset_frog
reset_frog:
            ; ... existing code ...
            bsr     reset_timer
            ; ...
