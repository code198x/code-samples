; Active note tracking using parallel arrays
;
; Each active note needs:
;   - active flag (0 = inactive, 1 = active)
;   - X position (column 0-39)
;   - track (1, 2, or 3)
;   - note value (for SID playback)
;
; We support up to 8 simultaneous notes

MAX_NOTES       = 8             ; Maximum active notes
NOTE_INACTIVE   = 0
NOTE_ACTIVE     = 1

; Note state arrays (parallel arrays again!)
note_active:    !fill MAX_NOTES, 0      ; Is this slot in use?
note_x:         !fill MAX_NOTES, 0      ; Column position
note_track:     !fill MAX_NOTES, 0      ; Which track (1-3)
note_value:     !fill MAX_NOTES, 0      ; SID frequency high byte
