MAX_NOTES       = 12            ; More slots for 3 tracks

note_x:         !fill MAX_NOTES, $ff    ; X positions
note_track:     !fill MAX_NOTES, 0      ; Which track (0, 1, or 2)
