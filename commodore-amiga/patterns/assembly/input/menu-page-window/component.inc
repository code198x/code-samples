; SPDX-License-Identifier: MIT
; Keep a Menu Selection Visible. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
menu_page_window_init:
    move.b #0,d0
    move.b d0,TOP
    move.b d0,ROW
    move.b d0,VISIBLE
    move.b d0,VALID
    move.b d0,SELECTED
    move.b d0,ITEM_COUNT
    move.b d0,PAGE_ROWS
    move.b d0,T0
    move.b d0,T1
    rts
menu_page_window_step:
; ROW = 0
    move.b #0,d0
    move.b d0,ROW
; VISIBLE = 0
    move.b #0,d0
    move.b d0,VISIBLE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if ITEM_COUNT == 0:
    move.b ITEM_COUNT,d0
    cmp.b #0,d0
    beq menu_page_window_L1
    jmp menu_page_window_L2
menu_page_window_L1:
; return
    rts
    jmp menu_page_window_L3
menu_page_window_L2:
menu_page_window_L3:
; if PAGE_ROWS == 0:
    move.b PAGE_ROWS,d0
    cmp.b #0,d0
    beq menu_page_window_L4
    jmp menu_page_window_L5
menu_page_window_L4:
; return
    rts
    jmp menu_page_window_L6
menu_page_window_L5:
menu_page_window_L6:
; if SELECTED >= ITEM_COUNT:
    move.b SELECTED,d0
    move.b ITEM_COUNT,d1
    cmp.b d1,d0
    bcc menu_page_window_L7
    jmp menu_page_window_L8
menu_page_window_L7:
; return
    rts
    jmp menu_page_window_L9
menu_page_window_L8:
menu_page_window_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; if ITEM_COUNT > PAGE_ROWS:
    move.b ITEM_COUNT,d0
    move.b PAGE_ROWS,d1
    cmp.b d1,d0
    bhi menu_page_window_L10
    jmp menu_page_window_L11
menu_page_window_L10:
; T0 = ITEM_COUNT - PAGE_ROWS
    move.b ITEM_COUNT,d0
    move.b PAGE_ROWS,d1
    sub.b d1,d0
    move.b d0,T0
    jmp menu_page_window_L12
menu_page_window_L11:
menu_page_window_L12:
; if TOP > T0:
    move.b TOP,d0
    move.b T0,d1
    cmp.b d1,d0
    bhi menu_page_window_L13
    jmp menu_page_window_L14
menu_page_window_L13:
; TOP = T0
    move.b T0,d0
    move.b d0,TOP
    jmp menu_page_window_L15
menu_page_window_L14:
menu_page_window_L15:
; if SELECTED < TOP:
    move.b SELECTED,d0
    move.b TOP,d1
    cmp.b d1,d0
    bcs menu_page_window_L16
    jmp menu_page_window_L17
menu_page_window_L16:
; TOP = SELECTED
    move.b SELECTED,d0
    move.b d0,TOP
    jmp menu_page_window_L18
menu_page_window_L17:
; T1 = SELECTED - TOP
    move.b SELECTED,d0
    move.b TOP,d1
    sub.b d1,d0
    move.b d0,T1
; if T1 >= PAGE_ROWS:
    move.b T1,d0
    move.b PAGE_ROWS,d1
    cmp.b d1,d0
    bcc menu_page_window_L19
    jmp menu_page_window_L20
menu_page_window_L19:
; T1 = SELECTED - PAGE_ROWS
    move.b SELECTED,d0
    move.b PAGE_ROWS,d1
    sub.b d1,d0
    move.b d0,T1
; TOP = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,TOP
    jmp menu_page_window_L21
menu_page_window_L20:
menu_page_window_L21:
menu_page_window_L18:
; ROW = SELECTED - TOP
    move.b SELECTED,d0
    move.b TOP,d1
    sub.b d1,d0
    move.b d0,ROW
; VISIBLE = ITEM_COUNT - TOP
    move.b ITEM_COUNT,d0
    move.b TOP,d1
    sub.b d1,d0
    move.b d0,VISIBLE
; if VISIBLE > PAGE_ROWS:
    move.b VISIBLE,d0
    move.b PAGE_ROWS,d1
    cmp.b d1,d0
    bhi menu_page_window_L22
    jmp menu_page_window_L23
menu_page_window_L22:
; VISIBLE = PAGE_ROWS
    move.b PAGE_ROWS,d0
    move.b d0,VISIBLE
    jmp menu_page_window_L24
menu_page_window_L23:
menu_page_window_L24:
    rts
component_end:
