; Z80 turn state, caller must initialise all bytes to zero.
; Storage belongs to the caller; no interrupts access it.
turns       equ $c000            ; 16-bit wraparound count
clock_ticks equ $c002            ; 16-bit accepted display announcements
remaining   equ $c004            ; 8-bit countdown, 120 accepted ticks per turn
is_timed    equ $c005            ; 0 = untimed, 1 = timed
previous    equ $c006            ; previous active-high action bits
expiries    equ $c007            ; 8-bit expiry count

; commit_turn: increment turn count and start a fresh deadline.
; Outputs: turns++, remaining=120. Clobbers AF, HL. No display access.
commit_turn:
    ld hl,(turns)
    inc hl
    ld (turns),hl
    ld a,120
    ld (remaining),a
    ret

; tick_deadline: call once for each accepted clock tick, only in timed mode.
; Outputs: clock_ticks++; at zero expiries++, commit_turn.
; Clobbers AF, HL. Does not wait, read input or draw.
tick_deadline:
    ld hl,(clock_ticks)
    inc hl
    ld (clock_ticks),hl
    ld a,(remaining)
    dec a
    ld (remaining),a
    ret nz
    ld a,(expiries)
    inc a
    ld (expiries),a
    jp commit_turn
