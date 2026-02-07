; Shadowkeep — One coloured cell

            org     32768

start:
            ; Black border
            ld      a, 0            ; 0 = black
            out     ($fe), a        ; Write to border port

            ; Clear screen (bitmap + attributes)
            ; This uses LDIR — we'll learn how it works in Unit 3
            ld      hl, $4000       ; Start of screen memory
            ld      de, $4001       ; Destination = start + 1
            ld      bc, 6911        ; 6912 bytes - 1
            ld      (hl), 0         ; First byte = 0
            ldir                    ; Copy to rest

            ; Write one attribute at row 12, column 16
            ; Address = $5800 + (12 x 32) + 16 = $5990
            ld      a, $30          ; Yellow PAPER, black INK
            ld      ($5990), a

.loop:      halt
            jr      .loop

            end     start
