;------------------------------------------------------------------------------
; DISPLAY_LEVEL - Show current level on screen (single digit 1-9)
;------------------------------------------------------------------------------
display_level:
            movem.l d0-d4/a0-a3,-(sp)

            ; Get level (1-9, clamp display to 9)
            move.w  level(pc),d0
            cmp.w   #9,d0
            ble.s   .level_ok
            moveq   #9,d0                   ; Cap display at 9
.level_ok:

            ; Draw single digit for level
            lea     screen_plane,a2
            add.l   #LEVEL_Y*SCREEN_W+LEVEL_X/8,a2

            ; Get digit graphics
            lsl.w   #4,d0                   ; *16 for font offset
            lea     digit_font,a0
            add.w   d0,a0

            ; Copy 8 rows, 1 byte each
            moveq   #7,d3
.copy_row:
            move.b  (a0),(a2)
            addq.l  #2,a0
            lea     SCREEN_W(a2),a2
            dbf     d3,.copy_row

            movem.l (sp)+,d0-d4/a0-a3
            rts
