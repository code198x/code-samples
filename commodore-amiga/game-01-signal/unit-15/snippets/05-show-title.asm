;------------------------------------------------------------------------------
; SHOW_TITLE - Display title screen
;------------------------------------------------------------------------------
show_title:
            bsr     clear_screen
            bsr     wait_blit

            ; Hide frog sprite during title
            lea     frog_data,a0
            clr.l   (a0)

            ; Hide life sprites
            lea     life_icon_1,a0
            clr.l   (a0)
            lea     life_icon_2,a0
            clr.l   (a0)
            lea     life_icon_3,a0
            clr.l   (a0)

            ; Draw "SIGNAL" text centred on screen
            ; Each letter is 8 pixels wide, "SIGNAL" = 6 letters = 48 pixels
            ; Centre: (320-48)/2 = 136 pixels = 17 bytes
            lea     screen_plane,a2
            add.l   #TITLE_Y*SCREEN_W+17,a2

            lea     title_text,a1
            moveq   #5,d4                   ; 6 letters

.draw_letter:
            move.w  (a1)+,d0                ; Get letter index
            lsl.w   #4,d0                   ; *16 for font offset
            lea     letter_font,a0
            add.w   d0,a0

            move.l  a2,a3
            moveq   #7,d3
.copy_row:
            move.b  (a0),(a3)
            addq.l  #2,a0
            lea     SCREEN_W(a3),a3
            dbf     d3,.copy_row

            addq.l  #1,a2
            dbf     d4,.draw_letter

            rts
