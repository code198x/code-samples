            ; --- Check game state ---
            move.w  game_state,d0
            cmp.w   #GAME_TITLE,d0
            beq     .title_update
            cmp.w   #GAME_COMPLETE,d0
            beq     .complete_update

            ; --- PLAYING: Process all creatures ---
            ; ...creature processing...
            bra     .frame_end

            ; --- TITLE: wait for fire ---
.title_update:
            btst    #6,$bfe001
            bne     .frame_end
            bsr     start_game
            bra     .frame_end

            ; --- COMPLETE: wait for fire to restart ---
.complete_update:
            btst    #6,$bfe001
            bne     .frame_end
            bsr     clear_bitplane
            bsr     draw_title
            move.w  #GAME_TITLE,game_state
            move.w  #COLOUR_PANEL_BG,panel_bg_val

.frame_end:
