; Note storage uses parallel arrays
; Each note has a track (1-3) and column position

MAX_NOTES   = 8                 ; Maximum notes on screen at once

note_track:
            !fill MAX_NOTES, 0  ; Track number (0=inactive, 1-3=active)

note_col:
            !fill MAX_NOTES, 0  ; Screen column position (1-37)

; To find an empty slot, scan for note_track[x] == 0
; To process all notes, loop through and skip where note_track[x] == 0
