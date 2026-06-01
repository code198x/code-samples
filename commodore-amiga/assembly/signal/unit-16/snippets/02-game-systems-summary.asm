; Phase 1 Game Systems Summary
; ============================

; Movement System
; ---------------
; Grid-based: frog moves in discrete 16x16 pixel cells
; Animation: 8 frames @ 2 pixels/frame = smooth hop
frog_grid_x:    dc.w    9           ; Grid position
frog_pixel_x:   dc.w    0           ; Pixel position (for animation)
HOP_FRAMES      equ 8
PIXELS_PER_FRAME equ 2

; State Machine
; -------------
; Frog states control animation behaviour
STATE_IDLE      equ 0               ; Waiting for input
STATE_HOPPING   equ 1               ; Mid-hop animation
STATE_DYING     equ 2               ; Death flash
STATE_GAMEOVER  equ 3               ; No lives left

; Game states control screen flow
GSTATE_TITLE    equ 0               ; Title screen
GSTATE_PLAYING  equ 1               ; Active gameplay
GSTATE_OVER     equ 2               ; Game over screen

; Collision System
; ----------------
; Bounding box overlap check
; frog_x < car_x+width AND frog_x+width > car_x
; Only checked on road rows (7-11)

; Scoring System
; --------------
; 50 points per home reached
; Time bonus: remaining_seconds * 2
; Level bonus: 100 points per level

; Timer System
; ------------
; 3000 frames = 60 seconds at 50Hz PAL
; Counts down each frame, triggers death at 0
TIMER_START     equ 3000
