INCLUDE "yard.inc"
INCLUDE "joypad.inc"

Route EQU $C000
Previous EQU $C001
Result EQU $C002
LOWER_ROUTE EQU 0
UPPER_ROUTE EQU 1
READY EQU 0
DELIVERED EQU 1
MISSED EQU 2
GAME_BUTTONS EQU BUTTON_A | BUTTON_B | BUTTON_START

start:
    di
    ld sp,$fffe
    call setup_yard

    xor a
    ld [Previous],a
    call reset_attempt
    call draw
    call show_yard

frame:
    call wait_frame
    call read_buttons
    and GAME_BUTTONS
    ld c,a
    ld a,[Previous]
    cpl
    and c
    ld b,a                  ; Down now, not down last frame.
    ld a,c
    ld [Previous],a        ; Consume the sample even after a result.

    ld a,[Result]
    cp READY
    jr z,.ready
    ld a,b
    and BUTTON_B           ; Finished: only B can start another attempt.
    jr z,.redraw
    call reset_attempt
    jr .redraw

.ready:
    ld a,b
    and BUTTON_A           ; Ready: switch first, then check for dispatch.
    jr z,.dispatch
    ld a,[Route]
    xor UPPER_ROUTE
    ld [Route],a
.dispatch:
    ld a,b
    and BUTTON_START
    jr z,.redraw
    ld a,[Route]
    cp UPPER_ROUTE
    jr z,.deliver
    ld a,MISSED
    jr .store_result
.deliver:
    ld a,DELIVERED
.store_result:
    ld [Result],a
.redraw:
    call draw
    jr frame

reset_attempt:
    ld a,LOWER_ROUTE
    ld [Route],a
    ld a,READY
    ld [Result],a
    ret

; Draw the selected route and parcel/result. Call with LCD off or during VBlank.
draw:
    ld a,Track
    ld [UpperGate],a
    ld [LowerGate],a
    ld [LowerDepot],a
    ld [Home],a
    ld a,Target
    ld [UpperDepot],a
    xor a
    ld [Feedback],a

    ld a,[Route]
    cp UPPER_ROUTE
    jr z,.upper
    ld a,Arrow
    ld [LowerGate],a
    jr .place_parcel
.upper:
    ld a,Arrow
    ld [UpperGate],a
.place_parcel:
    ld a,[Result]
    cp READY
    jr z,.home
    cp DELIVERED
    jr nz,.missed
    ld a,Parcel
    ld [UpperDepot],a
    ld a,Check
    ld [Feedback],a
    ret
.missed:
    ld a,Parcel
    ld [LowerDepot],a
    ld a,Cross
    ld [Feedback],a
    ret
.home:
    ld a,Parcel
    ld [Home],a
    ret
