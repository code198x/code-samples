; 21 rows, three bytes per row: a 24x21 outline, with a central cross.
; The 64th byte is padding, not another row.
* = $2000
sprite_shape:
    !byte $ff, $ff, $ff
    !for row, 1, 9 {
        !byte $80, $18, $01
    }
    !byte $ff, $ff, $ff
    !for row, 1, 9 {
        !byte $80, $18, $01
    }
    !byte $ff, $ff, $ff
    !byte 0
