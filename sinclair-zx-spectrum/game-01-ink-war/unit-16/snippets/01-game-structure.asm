; Complete game structure overview
;
; The state machine drives the entire game:
;
;   ┌─────────────────────────────────────────┐
;   │                                         │
;   ▼                                         │
; TITLE ──(any key)──► PLAYING ──(board full)──► RESULTS
;   ▲                                              │
;   │                                              │
;   └──────────────(any key)───────────────────────┘
;
; Each state has:
;   - An enter function (sets up the screen)
;   - A handler (processes one frame)
;   - Exit conditions (transition to next state)

STATE_TITLE   equ 0
STATE_PLAYING equ 1
STATE_RESULTS equ 2

main_loop:
        halt                    ; Sync to 50Hz refresh
        ld a, (game_state)
        cp STATE_TITLE
        jr z, handle_title
        cp STATE_PLAYING
        jr z, handle_playing
        jp handle_results
