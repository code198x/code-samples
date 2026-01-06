; Song data: pairs of (delta_frames, track)
; delta = frames to wait before spawning this note
; track = 0 (top/X), 1 (middle/C), 2 (bottom/V)
; End marker: 0, 0

song_data:
            !byte 60, 1         ; After 60 frames, note on middle track
            !byte 40, 1         ; After 40 more frames, middle again
            !byte 40, 0         ; After 40 more frames, top track
            !byte 40, 2         ; After 40 more frames, bottom track
            ; ... more notes ...
            !byte 0, 0          ; End marker
