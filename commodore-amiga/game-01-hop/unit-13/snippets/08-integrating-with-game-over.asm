update_gameover:
            bsr     update_blink
            bsr     clear_playfield

            ; Draw "GAME OVER"
            move.w  #30,d1
            move.w  #112,d0
            lea     gameover_text,a0
            bsr     draw_text

            ; Draw high score table
            bsr     draw_high_scores

            ; Draw "PRESS FIRE" if visible
            tst.w   blink_visible
            beq.s   .skip_prompt
            move.w  #200,d1
            move.w  #104,d0
            lea     press_fire_text,a0
            bsr     draw_text
.skip_prompt:
            ; ... fire button handling
