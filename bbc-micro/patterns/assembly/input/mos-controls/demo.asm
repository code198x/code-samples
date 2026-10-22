; BBC Model B MOS 1.20/BASIC II. Typed loader, then CALL &3000.
; Q/A/O/P move, Space restarts. MOS owns IRQ and SOUND queue; reset to leave.
*=$3000
OSWRCH=$ffee
OSWORD=$fff1
start:
    cli
    jsr reset_game
main_loop:
    jsr wait_frame
    jsr read_controls
    jsr detect_edges
    jsr update_player
    jsr draw_screen
    inc updates
frame_done:
    jmp main_loop
updates: !byte 0
!source "state.inc"
!source "rules.inc"
!source "input.inc"
!source "draw.inc"
!source "sound.inc"
!source "../../framework/game-loop/frame.inc"

!source "collision.inc"
