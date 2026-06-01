; Joystick Reading
; Port 2 joystick data is at JOY1DAT ($dff00c)
; Bits use Gray code - XOR adjacent bits to decode direction

read_joystick:
            move.w  JOY1DAT(a5),d0      ; Read raw joystick data
            move.w  d0,d1
            lsr.w   #1,d1               ; Shift for XOR
            eor.w   d1,d0               ; Decode Gray code

            ; After decode:
            ; Bit 0 = Down
            ; Bit 1 = Right
            ; Bit 8 = Up
            ; Bit 9 = Left
            rts

; Example: Check if up is pressed
            btst    #8,d0
            beq.s   .not_up
            ; Up pressed...
.not_up:
