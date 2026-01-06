update_title:
            ; Update blink effect
            bsr     update_blink

            ; Clear the playfield
            bsr     clear_playfield

            ; Draw "HOP" title (centred, large)
            ; We'll draw it at line 80, centred horizontally
            move.w  #80,d1          ; Y position
            move.w  #136,d0         ; X position (320/2 - 24 for "HOP")
            lea     title_text,a0
            bsr     draw_text

            ; Draw "PRESS FIRE TO START" if visible
            tst.w   blink_visible
            beq.s   .skip_prompt
            move.w  #160,d1         ; Y position
            move.w  #80,d0          ; X position
            lea     press_fire_text,a0
            bsr     draw_text
.skip_prompt:

            ; Check fire button
            btst    #7,CIAAPRA
            bne.s   .no_fire

            ; Fire pressed - start game
            bsr     start_new_game
            move.w  #MODE_PLAYING,game_mode
.no_fire:
            rts

title_text:
            dc.b    "HOP",0
            even

press_fire_text:
            dc.b    "PRESS FIRE",0
            even
