read_joystick:
            ; Read and decode JOY1DAT
            move.w  JOY1DAT(a5),d0
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d1,d0               ; Decode up/down

            ; Edge detection
            move.w  joy_prev,d1
            not.w   d1
            and.w   d0,d1               ; D1 = newly pressed
            move.w  d0,joy_prev         ; Save for next frame

            move.w  d1,d0               ; Return in D0
            rts
