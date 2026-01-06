btst    #7,$bfe001      ; Fire pressed?
            beq.s   .fire_pressed   ; Yes if bit is clear
