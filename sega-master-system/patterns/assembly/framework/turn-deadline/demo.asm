; Standalone cartridge; no firmware required. Button 1 commits a turn.
; Button 2 toggles timed turns. Untimed: no frame wait, no ticking deadline.
; Timed: one accepted display announcement per tick, 120 ticks per turn.
; Action wins a same-iteration expiry: commit_turn runs before tick_deadline.
; Visual output: alternating full-screen backdrop colours after each turn.
; This deliberately blanks tile/sprite rendering. Not a rendered VRAM demo.
    org $0000
    jp start
    defs $66-$,0
    retn                      ; Pause NMI does not disturb main state
    defs $100-$,0
start:
    di
    ld sp,$c3f0               ; inside SG-1000's 1 KiB RAM too
    xor a
    ld hl,$c000
    ld b,8
clear_state:
    ld (hl),a
    inc hl
    djnz clear_state
    in a,($bf)                ; reset VDP command latch
    ld a,4
    out ($bf),a
    ld a,$80
    out ($bf),a               ; R0: mode 4, line interrupts disabled
    xor a
    out ($bf),a
    ld a,$81
    out ($bf),a               ; R1: display and frame IRQ disabled
    ld a,17
    out ($bf),a
    ld a,$c0
    out ($bf),a               ; CRAM entry 17
    ld a,$03
    out ($be),a               ; red
    ld a,$0c
    out ($be),a               ; green
    call show_turn
main:
    ld d,0                    ; this iteration has not accepted a clock tick
    ld a,(is_timed)
    or a
    jr z,read_actions
    call wait_frame
    inc d                     ; a fresh announcement was accepted
read_actions:
    in a,($dc)
    cpl
    and $30                   ; active-high button 1/2 state
    ld c,a
    ld a,(previous)
    cpl
    and c
    ld b,a                    ; newly pressed bits
    ld a,c
    ld (previous),a
    bit 5,b
    jr z,check_action
    ld a,(is_timed)
    xor 1
    ld (is_timed),a
    ld a,120
    ld (remaining),a          ; toggling mode starts a fresh deadline
check_action:
    bit 4,b
    call nz,commit_turn
    ld a,(is_timed)
    and d                     ; enabling the timer does not invent its first tick
    call nz,tick_deadline
    call show_turn
    jp main

; Backdrop selects visible feedback even with display disabled.
; AF clobbered, status reader cannot interrupt the two control writes.
show_turn:
    ld a,(turns)
    and 1
    add a,1
    out ($bf),a
    ld a,$87
    out ($bf),a
    ret

    include "../../../../../cross-platform/assembly/framework/turn-deadline/turn.inc"
    include "frame.inc"
    defs $7ff0-$,0
    db "TMR SEGA"             ; header; final checksum supplied by build.py
    db 0,0,0,0,0,0,0,$4c
