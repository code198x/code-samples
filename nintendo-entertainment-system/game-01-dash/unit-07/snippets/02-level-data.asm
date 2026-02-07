; Three unique row types — most rows share the same data.

level_empty_row:
    .byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
    .byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

level_platform_row:
    .byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 3,3,3,3
    .byte 3,3,3,3, 0,0,0,0, 0,0,0,0, 0,0,0,0

level_ground_row:
    .byte 3,3,3,3, 3,3,3,3, 3,3,3,3, 3,3,3,3
    .byte 3,3,3,3, 3,3,3,3, 3,3,3,3, 3,3,3,3

; Row pointer tables (30 entries — one per nametable row)
level_rows_lo:
    .byte <level_empty_row      ; Rows 0-19 (empty sky)
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_platform_row   ; Row 20: floating platform
    .byte <level_empty_row      ; Rows 21-25 (empty)
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_empty_row
    .byte <level_ground_row     ; Rows 26-29: ground
    .byte <level_ground_row
    .byte <level_ground_row
    .byte <level_ground_row
