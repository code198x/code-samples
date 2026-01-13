;------------------------------------------------------------------------------
; READ_FIRE_EDGE - Detect fire button press (edge triggered)
; Returns: D0 = 1 if fire just pressed, 0 otherwise
;
; Edge detection prevents a held button from triggering multiple times.
; We only return true on the frame when the button transitions from
; not-pressed to pressed.
;------------------------------------------------------------------------------
read_fire_edge:
            btst    #7,$bfe001              ; Fire button (active low)
            seq     d0                      ; D0 = $FF if pressed, $00 if not
            and.w   #1,d0                   ; D0 = 1 if pressed
            move.w  fire_prev,d1
            move.w  d0,fire_prev
            not.w   d1                      ; D1 = 1 if was NOT pressed
            and.w   d1,d0                   ; D0 = 1 only on rising edge
            rts

; The SEQ instruction sets the destination to $FF if the Z flag is set.
; Since BTST clears Z when the tested bit is 0 (button pressed = active low),
; SEQ gives us $FF when pressed, $00 when not pressed.
