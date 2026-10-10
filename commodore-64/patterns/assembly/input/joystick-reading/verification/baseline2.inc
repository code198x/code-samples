; =============================================================================
; JOYSTICK READING - BASIC
; Read joystick 2 from CIA#1
; Taught: Game 6 (SID Symphony), Unit 4
; CPU: ~20 cycles | Memory: ~30 bytes
; =============================================================================

CIA1_PRA    = $DC00     ; CIA#1 Data Port A (joystick 2)

JOY_UP      = %00000001
JOY_DOWN    = %00000010
JOY_LEFT    = %00000100
JOY_RIGHT   = %00001000
JOY_FIRE    = %00010000

; Read joystick and store state
; Returns: A = raw joystick bits (inverted: 0 = pressed)
read_joystick:
    lda CIA1_PRA        ; Read joystick port
    eor #$FF            ; Invert so 1 = pressed
    rts

; Check if specific direction/button pressed
; Usage: jsr read_joystick, then check with AND
;
; Example:
;   jsr read_joystick
;   and #JOY_FIRE
;   bne fire_pressed
