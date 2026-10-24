; SPDX-License-Identifier: MIT
; Keep a Menu Selection Visible. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
menu_page_window_init:
    ld a,0
    ld (TOP),a
    ld (ROW),a
    ld (VISIBLE),a
    ld (VALID),a
    ld (SELECTED),a
    ld (ITEM_COUNT),a
    ld (PAGE_ROWS),a
    ld (T0),a
    ld (T1),a
    ret
menu_page_window_step:
; ROW = 0
    ld a,0
    ld (ROW),a
; VISIBLE = 0
    ld a,0
    ld (VISIBLE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if ITEM_COUNT == 0:
    ld a,(ITEM_COUNT)
    cp 0
    jp z,menu_page_window_L1
    jp menu_page_window_L2
menu_page_window_L1:
; return
    ret
    jp menu_page_window_L3
menu_page_window_L2:
menu_page_window_L3:
; if PAGE_ROWS == 0:
    ld a,(PAGE_ROWS)
    cp 0
    jp z,menu_page_window_L4
    jp menu_page_window_L5
menu_page_window_L4:
; return
    ret
    jp menu_page_window_L6
menu_page_window_L5:
menu_page_window_L6:
; if SELECTED >= ITEM_COUNT:
    ld a,(SELECTED)
    ld b,a
    ld a,(ITEM_COUNT)
    ld c,a
    ld a,b
    cp c
    jp nc,menu_page_window_L7
    jp menu_page_window_L8
menu_page_window_L7:
; return
    ret
    jp menu_page_window_L9
menu_page_window_L8:
menu_page_window_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; if ITEM_COUNT > PAGE_ROWS:
    ld a,(ITEM_COUNT)
    ld b,a
    ld a,(PAGE_ROWS)
    ld c,a
    ld a,b
    cp c
    jp z,menu_page_window_L11
    jp nc,menu_page_window_L10
    jp menu_page_window_L11
menu_page_window_L10:
; T0 = ITEM_COUNT - PAGE_ROWS
    ld a,(ITEM_COUNT)
    ld b,a
    ld a,(PAGE_ROWS)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
    jp menu_page_window_L12
menu_page_window_L11:
menu_page_window_L12:
; if TOP > T0:
    ld a,(TOP)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,menu_page_window_L14
    jp nc,menu_page_window_L13
    jp menu_page_window_L14
menu_page_window_L13:
; TOP = T0
    ld a,(T0)
    ld (TOP),a
    jp menu_page_window_L15
menu_page_window_L14:
menu_page_window_L15:
; if SELECTED < TOP:
    ld a,(SELECTED)
    ld b,a
    ld a,(TOP)
    ld c,a
    ld a,b
    cp c
    jp c,menu_page_window_L16
    jp menu_page_window_L17
menu_page_window_L16:
; TOP = SELECTED
    ld a,(SELECTED)
    ld (TOP),a
    jp menu_page_window_L18
menu_page_window_L17:
; T1 = SELECTED - TOP
    ld a,(SELECTED)
    ld b,a
    ld a,(TOP)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; if T1 >= PAGE_ROWS:
    ld a,(T1)
    ld b,a
    ld a,(PAGE_ROWS)
    ld c,a
    ld a,b
    cp c
    jp nc,menu_page_window_L19
    jp menu_page_window_L20
menu_page_window_L19:
; T1 = SELECTED - PAGE_ROWS
    ld a,(SELECTED)
    ld b,a
    ld a,(PAGE_ROWS)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; TOP = T1 + 1
    ld a,(T1)
    add a,1
    ld (TOP),a
    jp menu_page_window_L21
menu_page_window_L20:
menu_page_window_L21:
menu_page_window_L18:
; ROW = SELECTED - TOP
    ld a,(SELECTED)
    ld b,a
    ld a,(TOP)
    ld c,a
    ld a,b
    sub c
    ld (ROW),a
; VISIBLE = ITEM_COUNT - TOP
    ld a,(ITEM_COUNT)
    ld b,a
    ld a,(TOP)
    ld c,a
    ld a,b
    sub c
    ld (VISIBLE),a
; if VISIBLE > PAGE_ROWS:
    ld a,(VISIBLE)
    ld b,a
    ld a,(PAGE_ROWS)
    ld c,a
    ld a,b
    cp c
    jp z,menu_page_window_L23
    jp nc,menu_page_window_L22
    jp menu_page_window_L23
menu_page_window_L22:
; VISIBLE = PAGE_ROWS
    ld a,(PAGE_ROWS)
    ld (VISIBLE),a
    jp menu_page_window_L24
menu_page_window_L23:
menu_page_window_L24:
    ret
component_end:
