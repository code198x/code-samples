update_name_entry:
            bsr     read_joystick

            ; Check for letter change
            tst.b   joy_up
            bne.s   .check_up
            tst.b   joy_down
            bne.s   .check_down
            bra     .check_fire

.check_up:
            tst.b   joy_up_prev
            bne     .check_fire     ; Already held
            ; Increment letter
            move.w  entry_position,d0
            lea     entry_chars,a0
            move.b  (a0,d0.w),d1
            addq.b  #1,d1
            cmpi.b  #'Z'+1,d1
            bne.s   .store_up
            move.b  #'A',d1
.store_up:
            move.b  d1,(a0,d0.w)
            bsr     play_hop_sound
            bra     .check_fire

.check_down:
            tst.b   joy_down_prev
            bne.s   .check_fire
            ; Decrement letter
            move.w  entry_position,d0
            lea     entry_chars,a0
            move.b  (a0,d0.w),d1
            subq.b  #1,d1
            cmpi.b  #'A'-1,d1
            bne.s   .store_down
            move.b  #'Z',d1
.store_down:
            move.b  d1,(a0,d0.w)
            bsr     play_hop_sound
            bra.s   .check_fire

.check_fire:
            ; Check fire button (with delay)
            tst.w   fire_delay
            beq.s   .do_fire_check
            subq.w  #1,fire_delay
            bra.s   .draw_entry

.do_fire_check:
            btst    #7,CIAAPRA
            bne.s   .draw_entry

            ; Fire pressed - advance position
            bsr     play_score_sound
            addq.w  #1,entry_position
            cmpi.w  #3,entry_position
            blt.s   .not_done

            ; All three entered - save name
            bsr     save_entry_name
            move.w  #MODE_GAMEOVER,game_mode
            move.w  #30,fire_delay

.not_done:
            move.w  #10,fire_delay

.draw_entry:
            ; Draw the entry screen
            bsr     clear_playfield

            ; Draw "NEW HIGH SCORE"
            move.w  #80,d1
            move.w  #88,d0
            lea     new_hs_text,a0
            bsr     draw_text

            ; Draw current entry
            move.w  #120,d1
            move.w  #144,d0
            lea     entry_chars,a0
            bsr     draw_text

            ; Highlight current position with underscore
            move.w  entry_position,d0
            lsl.w   #3,d0           ; *8 for character width
            addi.w  #144,d0         ; Base X
            move.w  #130,d1
            bsr     draw_underscore

            rts
