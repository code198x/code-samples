; ----------------------------------------------------------------------------
; Draw Cursor
; ----------------------------------------------------------------------------
; Shows the cursor at current position with FLASH attribute

draw_cursor:
            ; Calculate attribute address for cursor position
            ld      a, (cursor_row)
            add     a, BOARD_ROW    ; Add board offset
            ld      l, a
            ld      h, 0
            add     hl, hl          ; *32
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL    ; Add board offset
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            ld      (hl), CURSOR_ATTR ; Set FLASH attribute

            ret

; ----------------------------------------------------------------------------
; Clear Cursor
; ----------------------------------------------------------------------------
; Removes cursor flash from current position

clear_cursor:
            ; Calculate attribute address for cursor position
            ld      a, (cursor_row)
            add     a, BOARD_ROW
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            ld      (hl), EMPTY_ATTR ; Remove FLASH, back to white

            ret
