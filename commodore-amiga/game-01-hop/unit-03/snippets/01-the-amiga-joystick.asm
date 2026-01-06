JOY1DAT     equ $00c

            move.w  JOY1DAT(a5),d0  ; Read joystick register
            btst    #1,d0           ; Right?
            btst    #9,d0           ; Left?
