; Acorn Electron OS/BASIC. Typed loader, then CALL &3000.
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
!source "../../../../../bbc-micro/patterns/assembly/framework/collect-and-respond/state.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/collect-and-respond/rules.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/collect-and-respond/collision.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/collect-and-respond/input.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/collect-and-respond/draw.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/collect-and-respond/sound.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/game-loop/frame.inc"
