; SPDX-License-Identifier: MIT
; Keep a Menu Selection Visible. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
menu_page_window_init:
    lda #0
    sta TOP
    sta ROW
    sta VISIBLE
    sta VALID
    sta SELECTED
    sta ITEM_COUNT
    sta PAGE_ROWS
    sta T0
    sta T1
    rts
menu_page_window_step:
; ROW = 0
    lda #0
    sta ROW
; VISIBLE = 0
    lda #0
    sta VISIBLE
; VALID = 0
    lda #0
    sta VALID
; if ITEM_COUNT == 0:
    lda ITEM_COUNT
    cmp #0
    beq menu_page_window_L4
menu_page_window_L5:
    jmp menu_page_window_L2
menu_page_window_L4:
    jmp menu_page_window_L1
menu_page_window_L1:
; return
    rts
    jmp menu_page_window_L3
menu_page_window_L2:
menu_page_window_L3:
; if PAGE_ROWS == 0:
    lda PAGE_ROWS
    cmp #0
    beq menu_page_window_L9
menu_page_window_L10:
    jmp menu_page_window_L7
menu_page_window_L9:
    jmp menu_page_window_L6
menu_page_window_L6:
; return
    rts
    jmp menu_page_window_L8
menu_page_window_L7:
menu_page_window_L8:
; if SELECTED >= ITEM_COUNT:
    lda SELECTED
    cmp ITEM_COUNT
    bcs menu_page_window_L14
menu_page_window_L15:
    jmp menu_page_window_L12
menu_page_window_L14:
    jmp menu_page_window_L11
menu_page_window_L11:
; return
    rts
    jmp menu_page_window_L13
menu_page_window_L12:
menu_page_window_L13:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; if ITEM_COUNT > PAGE_ROWS:
    lda ITEM_COUNT
    cmp PAGE_ROWS
    beq menu_page_window_L20
    bcs menu_page_window_L19
menu_page_window_L20:
    jmp menu_page_window_L17
menu_page_window_L19:
    jmp menu_page_window_L16
menu_page_window_L16:
; T0 = ITEM_COUNT - PAGE_ROWS
    lda ITEM_COUNT
    sec
    sbc PAGE_ROWS
    sta T0
    jmp menu_page_window_L18
menu_page_window_L17:
menu_page_window_L18:
; if TOP > T0:
    lda TOP
    cmp T0
    beq menu_page_window_L25
    bcs menu_page_window_L24
menu_page_window_L25:
    jmp menu_page_window_L22
menu_page_window_L24:
    jmp menu_page_window_L21
menu_page_window_L21:
; TOP = T0
    lda T0
    sta TOP
    jmp menu_page_window_L23
menu_page_window_L22:
menu_page_window_L23:
; if SELECTED < TOP:
    lda SELECTED
    cmp TOP
    bcc menu_page_window_L29
menu_page_window_L30:
    jmp menu_page_window_L27
menu_page_window_L29:
    jmp menu_page_window_L26
menu_page_window_L26:
; TOP = SELECTED
    lda SELECTED
    sta TOP
    jmp menu_page_window_L28
menu_page_window_L27:
; T1 = SELECTED - TOP
    lda SELECTED
    sec
    sbc TOP
    sta T1
; if T1 >= PAGE_ROWS:
    lda T1
    cmp PAGE_ROWS
    bcs menu_page_window_L34
menu_page_window_L35:
    jmp menu_page_window_L32
menu_page_window_L34:
    jmp menu_page_window_L31
menu_page_window_L31:
; T1 = SELECTED - PAGE_ROWS
    lda SELECTED
    sec
    sbc PAGE_ROWS
    sta T1
; TOP = T1 + 1
    lda T1
    clc
    adc #1
    sta TOP
    jmp menu_page_window_L33
menu_page_window_L32:
menu_page_window_L33:
menu_page_window_L28:
; ROW = SELECTED - TOP
    lda SELECTED
    sec
    sbc TOP
    sta ROW
; VISIBLE = ITEM_COUNT - TOP
    lda ITEM_COUNT
    sec
    sbc TOP
    sta VISIBLE
; if VISIBLE > PAGE_ROWS:
    lda VISIBLE
    cmp PAGE_ROWS
    beq menu_page_window_L40
    bcs menu_page_window_L39
menu_page_window_L40:
    jmp menu_page_window_L37
menu_page_window_L39:
    jmp menu_page_window_L36
menu_page_window_L36:
; VISIBLE = PAGE_ROWS
    lda PAGE_ROWS
    sta VISIBLE
    jmp menu_page_window_L38
menu_page_window_L37:
menu_page_window_L38:
    rts
component_end:
