INCLUDE "yard.inc"
INCLUDE "joypad.inc"

Route EQU $C000
PreviousA EQU $C001
LOWER_ROUTE EQU 0
UPPER_ROUTE EQU 1

start:
    di
    ld sp,$fffe
    call setup_yard

    ld a,LOWER_ROUTE
    ld [Route],a
    xor a                   ; No A press in the previous sample yet.
    ld [PreviousA],a
    call draw_gates
    call show_yard

frame:
    call wait_frame
    call read_buttons
    and BUTTON_A
    ld c,a                  ; C holds this frame's A bit.
    ld a,[PreviousA]
    cpl
    and c
    ld b,a                  ; New press = A down now AND not down before.
    ld a,c
    ld [PreviousA],a        ; Remember releases too, to allow another press.

    ld a,b
    and a
    jr z,.redraw
    ld a,[Route]
    xor UPPER_ROUTE         ; Flip the route's single bit: 0 ↔ 1.
    ld [Route],a
.redraw:
    call draw_gates
    jr frame

; Set just the two arrows' map cells, with LCD off or during VBlank.
draw_gates:
    ld a,[Route]
    cp UPPER_ROUTE
    jr z,.upper
    ld a,Track
    ld [UpperGate],a
    ld a,Arrow
    ld [LowerGate],a
    ret
.upper:
    ld a,Track
    ld [LowerGate],a
    ld a,Arrow
    ld [UpperGate],a
    ret
