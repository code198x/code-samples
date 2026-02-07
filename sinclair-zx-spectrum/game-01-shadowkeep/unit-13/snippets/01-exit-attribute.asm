; Exit door — a new attribute value
;
; The room needs a goal. An exit door, marked by a colour
; the player can see but hasn't encountered before.
;
; Cyan paper stands out against white floors and blue walls:

EXIT        equ     $28             ; PAPER 5 (cyan) + INK 0

; Room data now includes the exit cell:

room_data:
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            db      WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, TREASURE, FLOOR, WALL
            db      WALL, FLOOR, TREASURE, FLOOR, FLOOR, FLOOR, WALL, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, HAZARD, FLOOR, FLOOR, TREASURE, WALL
            db      WALL, WALL, WALL, WALL, WALL, EXIT, WALL, WALL, WALL

; The exit is in the bottom wall (row 4, col 5 of the room).
; It's visible from the start — a cyan gap in the blue wall.
; The player can see where they need to go.
