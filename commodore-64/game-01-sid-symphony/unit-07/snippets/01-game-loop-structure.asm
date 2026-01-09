; Game loop structure - the foundation of any game
;
; All games follow this pattern:
; 1. Initialise once at startup
; 2. Loop: update state, draw, check input, repeat

start:
                jsr init            ; One-time setup

main_loop:
                jsr wait_raster     ; Sync to frame (50fps on PAL)
                jsr update_counters ; Update timing
                jsr update_display  ; Visual feedback
                jsr check_quit      ; Check for exit
                jmp main_loop       ; Loop forever

; Key insight: the main loop runs once per frame (50 times/second)
; Everything in the loop must complete within one frame (~20ms)
