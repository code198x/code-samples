; The endings' voices: a short rest first, so the pen chime or
; the last squelch can finish saying its piece.
winsting:   dc.w    0,24
            dc.w    NOTE_C,7, NOTE_E,7, NOTE_G,7, NOTE_C/2,22
            dc.w    -2
losesting:  dc.w    0,20
            dc.w    NOTE_E,12, NOTE_D,12, NOTE_C,12, NOTE_C*2,30
            dc.w    -2

; Baa Baa Black Sheep, one phrase at a time: period, frames.
; 0 period = a rest; -1 = back to the top.
