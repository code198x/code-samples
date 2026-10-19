; Include the maintained input-to-sound/input.inc once as well.
; A5=CUSTOM, CIA-A bit7 configured as input; caller owns physical joystick port2.
; read_joystick_edge samples once and returns new presses in D0.W.
; If already sampled this update, call detect_joystick_edges instead.
; Changes D0/D1/CCR. Other registers survive. State is writable WORDs.
; Zero initial history treats a held control as a first press. To suppress that,
; sample once and copy controls into joy_prev before entering the update loop.
read_joystick_edge:
    bsr read_controls
detect_joystick_edges:
    move.w joy_prev,d1
    not.w d1
    and.w controls,d1
    move.w controls,joy_prev
    move.w d1,d0
    rts
joy_prev: dc.w 0
