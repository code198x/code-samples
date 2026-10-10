CIA1_PRB    = $DC01     ; CIA#1 Data Port B (joystick 1)

; Read joystick 1
; Standard idiom: write $7F to PRA first to disable keyboard column scan,
; then read PRB cleanly
read_joystick1:
    lda #$7F
    sta CIA1_PRA        ; Park PRA so PRB reads only the joystick
    lda CIA1_PRB
    eor #$FF            ; Invert so 1 = pressed
    rts
