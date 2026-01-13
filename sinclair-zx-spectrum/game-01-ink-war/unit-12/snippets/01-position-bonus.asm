; ----------------------------------------------------------------------------
; Get Position Bonus
; ----------------------------------------------------------------------------
; A = cell index (0-63)
; Returns A = position bonus (corner=2, edge=1, center=0)

get_position_bonus:
            ; Get row and column from index
            ld      b, a
            and     %00000111           ; Column (0-7)
            ld      c, a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111           ; Row (0-7)
            ld      b, a                ; B = row, C = col

            ; Check for corner (row=0 or 7, col=0 or 7)
            ld      a, b
            or      a
            jr      z, .gpb_row_edge    ; Row 0
            cp      7
            jr      z, .gpb_row_edge    ; Row 7
            ; Row is not edge
            ld      a, c
            or      a
            jr      z, .gpb_edge        ; Col 0, row not edge = edge
            cp      7
            jr      z, .gpb_edge        ; Col 7, row not edge = edge
            ; Neither row nor col is edge = center
            xor     a                   ; Return 0
            ret

.gpb_row_edge:
            ; Row is 0 or 7, check column
            ld      a, c
            or      a
            jr      z, .gpb_corner      ; Col 0 = corner
            cp      7
            jr      z, .gpb_corner      ; Col 7 = corner
            ; Row edge but not corner
            jr      .gpb_edge

.gpb_corner:
            ld      a, 2                ; Corner bonus
            ret

.gpb_edge:
            ld      a, 1                ; Edge bonus
            ret
