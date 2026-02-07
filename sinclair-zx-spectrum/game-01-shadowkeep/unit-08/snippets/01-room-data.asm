; Room data — one byte per cell, read left to right, top to bottom.
; The drawing loop reads this table and writes each byte to attribute memory.

room_data:
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            db      WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, TREASURE, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, HAZARD, FLOOR, FLOOR, FLOOR, WALL
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
