; Baa Baa Black Sheep, one phrase at a time: period, frames.
; 0 period = a rest; -1 = back to the top.
jingle:
            dc.w    NOTE_C,18, NOTE_C,18, NOTE_G,18, NOTE_G,18
            dc.w    NOTE_A,9,  NOTE_A,9,  NOTE_A,9,  NOTE_A,9
            dc.w    NOTE_G,32, 0,14
            dc.w    NOTE_F,18, NOTE_F,18, NOTE_E,18, NOTE_E,18
            dc.w    NOTE_D,9,  NOTE_D,9,  NOTE_D,9,  NOTE_D,9
            dc.w    NOTE_C,32, 0,60
            dc.w    -1
hopgap:     dc.w    COOLDOWN            ; This sheep's hop rhythm
