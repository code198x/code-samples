            ; Draw room from data table
            ld      hl, $594c           ; Attribute address: row 10, col 12
            ld      de, room_data       ; Pointer to room bytes
            ld      c, ROOM_HEIGHT      ; Row counter

.row:       ld      b, ROOM_WIDTH       ; Column counter
.cell:      ld      a, (de)             ; Read one cell from table
            ld      (hl), a             ; Write to attribute memory
            inc     de                  ; Next data byte
            inc     hl                  ; Next screen column
            djnz    .cell               ; Repeat for row width

            ; Skip to next row: add (32 - ROOM_WIDTH) to HL
            push    de                  ; Save data pointer
            ld      de, ROW_SKIP        ; 32 - 9 = 23
            add     hl, de
            pop     de                  ; Restore data pointer
            dec     c
            jr      nz, .row
