; 48K PAL, entered through BASIC USR32768. ROM IM1 remains visible.
; Space: title->play, play<->pause, game over->title. Q: lose while playing.
; Blue=title, green=playing, yellow=paused, red=game over. Reset to leave.
; This caller owns the stack, border/MIC/beeper port and the declared state.
    org $8000
start:
    di
    ld sp,$ff00
    ld iy,$5c3a
    im 1
    xor a
    ld (game_state),a
    ld hl,0
    ld (game_ticks),hl
    call read_controls
    ld (previous),a             ; held controls at entry are not new presses
    ld hl,$cafe
    ld (ready),hl
    ei
main_loop:
    call wait_frame
    call read_controls
    ld b,a
    ld a,(previous)
    cpl
    and b
    ld (pressed),a
    ld a,b
    ld (previous),a
    call update_state
    call draw_state
    jr main_loop

; One state consumes one sampled update. AF/BC/HL change; DE/IX/IY survive.
; State is0..3. Entry/reset actions happen only on a transition.
update_state:
    ld a,(game_state)
    or a
    jr z,state_title
    cp 1
    jr z,state_playing
    cp 2
    jr z,state_game_over
    cp 3
    jr z,state_paused
invalid_state:
    di                         ; expose corrupted state instead of masking it
    halt
    jr invalid_state
state_title:
    ld a,(pressed)
    and 16
    ret z
    ld hl,0                    ; a fresh session, not a resume
    ld (game_ticks),hl
    ld a,1
    ld (game_state),a
    ret
state_playing:
    ld hl,(game_ticks)
    inc hl
    ld (game_ticks),hl
    ld a,(pressed)
    bit 0,a
    jr nz,state_lose           ; loss takes priority over pause
    and 16
    ret z
    ld a,3
    ld (game_state),a
    ret
state_lose:
    ld a,2
    ld (game_state),a
    ret
state_game_over:
    ld a,(pressed)
    and 16
    ret z
    xor a
    ld (game_state),a
    ret
state_paused:
    ld a,(pressed)
    and 16
    ret z
    ld a,1                     ; retain the current session's counter
    ld (game_state),a
    ret

draw_state:
    ld a,(game_state)
    ld l,a
    ld h,0
    ld de,state_colours
    add hl,de
    ld a,(hl)
    out ($fe),a
    ret
signature: defm "198XSTATES!"
ready: defw 0
game_state: defb 0
previous: defb 0
pressed: defb 0
game_ticks: defw 0
state_colours: defb 1,4,2,6
    include "../game-loop/frame.inc"
    include "../input-to-sound/input.inc"
    end start
