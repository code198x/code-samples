; Joystick Edge Detection
; Triggers only on new presses, not held directions

read_joystick_edge:
            ; Read and decode joystick
            move.w  JOY1DAT(a5),d0
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d1,d0           ; D0 = decoded current state

            ; Edge detection: current AND NOT previous
            ; This gives us bits that just became 1
            move.w  joy_prev,d1
            not.w   d1              ; D1 = NOT previous
            and.w   d0,d1           ; D1 = newly pressed only

            ; Save current for next frame
            move.w  d0,joy_prev

            move.w  d1,d0           ; Return newly pressed
            rts

; Without edge detection: holding UP would cause
; multiple hops. With edge detection: one press = one hop.
