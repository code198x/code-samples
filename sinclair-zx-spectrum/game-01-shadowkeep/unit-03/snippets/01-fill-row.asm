; Shadowkeep — DJNZ: Fill a row

            org     32768

start:
            ld      a, 0
            out     ($fe), a        ; Black border

            ; Clear screen
            ld      hl, $4000
            ld      de, $4001
            ld      bc, 6911
            ld      (hl), 0
            ldir

            ; Fill row 12 with blue (all 32 columns)
            ld      hl, $5980       ; $5800 + (12 x 32)
            ld      b, 32           ; 32 cells
            ld      a, $09          ; Solid blue

.fill:      ld      (hl), a         ; Write attribute
            inc     hl              ; Next cell
            djnz    .fill           ; B = B - 1, loop if not zero

.loop:      halt
            jr      .loop

            end     start
