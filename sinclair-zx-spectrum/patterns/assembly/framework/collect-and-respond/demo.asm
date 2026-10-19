; 48K PAL, QAOP/Space. IM1 retained; only short collection beep disables IRQ.
    org $8000
start:
    di
    im 1
    ld sp,$ff00
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),7
    ldir
    xor a
    out ($fe),a
    call reset_game
    call initialise_clock
    ei
main_loop:
    call wait_frame
    call read_controls
    call detect_edges
    call update_player
    call draw_screen
    ld hl,(updates)
    inc hl
    ld (updates),hl
frame_done:
    jr main_loop
updates: defw 0
previous: defb 0
pressed: defb 0
released: defb 0
player_x: defb 2
player_y: defb 5
item_active: defb 1
score: defb 0
move_delay: defb 0
old_x: defb 0
old_y: defb 0
    include "rules.inc"
    include "draw.inc"
    include "sound.inc"
    include "../game-loop/frame.inc"
    include "../input-to-sound/input.inc"
    include "../../audio/sound-beep/sound-beep.inc"
    include "collision.inc"
    end start
