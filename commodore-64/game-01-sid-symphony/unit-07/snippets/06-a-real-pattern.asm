song_data:
            ; Intro - single notes, slow pace
            !byte 60, 1         ; Middle (C)
            !byte 40, 1         ; Middle again
            !byte 40, 0         ; Top (X)
            !byte 40, 2         ; Bottom (V)

            ; Build up - alternating pattern
            !byte 30, 1         ; C
            !byte 30, 0         ; X
            !byte 30, 1         ; C
            !byte 30, 2         ; V

            ; Faster section
            !byte 20, 0         ; X
            !byte 20, 1         ; C
            !byte 20, 2         ; V
            !byte 20, 0         ; X
            !byte 20, 1         ; C
            !byte 20, 2         ; V

            ; Chord hits (almost simultaneous)
            !byte 40, 0         ; X
            !byte 3, 1          ; C (almost instant)
            !byte 3, 2          ; V (chord!)

            ; End marker
            !byte 0, 0
