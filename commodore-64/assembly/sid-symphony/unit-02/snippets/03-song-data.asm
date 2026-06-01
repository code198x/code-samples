; Song data format: pairs of (beat, track)
; Beat = which beat to spawn (0, 1, 2, ...)
; Track = which track (1=top/Z, 2=middle/X, 3=bottom/C)
; $FF = end of song (loops back to start)

song_data:
            ; Bar 1 (beats 0-7)
            !byte 0, 1          ; Beat 0, track 1 (Z)
            !byte 2, 2          ; Beat 2, track 2 (X)
            !byte 4, 3          ; Beat 4, track 3 (C)
            !byte 6, 1          ; Beat 6, track 1 (Z)

            ; Bar 2 (beats 8-15)
            !byte 8, 2          ; Beat 8, track 2
            !byte 10, 3         ; Beat 10, track 3
            !byte 12, 1         ; Beat 12, track 1
            !byte 14, 2         ; Beat 14, track 2

            ; Bar 3 (beats 16-23)
            !byte 16, 3
            !byte 18, 1
            !byte 20, 2
            !byte 22, 3

            ; Bar 4 (beats 24-31) - faster pattern
            !byte 24, 1
            !byte 25, 2         ; Consecutive beats!
            !byte 26, 3
            !byte 28, 1
            !byte 29, 2
            !byte 30, 3

            !byte $FF           ; End marker - song loops
