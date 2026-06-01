;------------------------------------------------------------------------------
; DISPLAY_TIMER - Show remaining seconds on screen
;------------------------------------------------------------------------------
display_timer:
            movem.l d0-d4/a0-a3,-(sp)

            ; Convert timer frames to seconds (timer / 50)
            move.w  timer(pc),d0
            ext.l   d0
            divu    #50,d0                  ; d0 = seconds remaining

            ; Convert to 2 decimal digits
            lea     timer_digits+4,a0       ; Point past end of buffer
            moveq   #1,d4                   ; 2 digits
.convert:
            divu    #10,d0
            swap    d0
            move.w  d0,-(a0)
            clr.w   d0
            swap    d0
            dbf     d4,.convert

            ; Draw 2 digits using CPU byte copies
            lea     timer_digits,a1
            lea     screen_plane,a2
            add.l   #TIMER_Y*SCREEN_W+TIMER_X/8,a2

            moveq   #1,d4                   ; 2 digits
.draw_digit:
            move.w  (a1)+,d0
            lsl.w   #4,d0                   ; *16 for font offset
            lea     digit_font,a0
            add.w   d0,a0

            move.l  a2,a3
            moveq   #7,d3                   ; 8 rows
.copy_row:
            move.b  (a0),(a3)
            addq.l  #2,a0
            lea     SCREEN_W(a3),a3
            dbf     d3,.copy_row

            addq.l  #1,a2                   ; Next digit position
            dbf     d4,.draw_digit

            movem.l (sp)+,d0-d4/a0-a3
            rts
