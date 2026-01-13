; ----------------------------------------------------------------------------
; Update Title State - Wait for fire button to start
; ----------------------------------------------------------------------------

update_title:
            ; Check joystick port 2 fire button
            lda CIA1_PRA
            and #$10            ; Bit 4 = fire button
            beq fire_pressed    ; Low = pressed

            ; Also accept space bar as alternative
            lda #$7F            ; Select keyboard row 7
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Space bar
            beq fire_pressed

            ; No input - stay on title screen
            lda #$FF
            sta CIA1_PRA        ; Reset CIA
            rts

fire_pressed:
            lda #$FF
            sta CIA1_PRA        ; Reset CIA

            ; Start the game!
            jsr init_game       ; Initialize all game systems
            lda #STATE_PLAYING
            sta game_state      ; Transition to playing state
            rts

; ----------------------------------------------------------------------------
; Update Results - Return to title on fire
; ----------------------------------------------------------------------------

update_results:
            lda CIA1_PRA
            and #$10
            beq results_fire

            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq results_fire

            lda #$FF
            sta CIA1_PRA
            rts

results_fire:
            lda #$FF
            sta CIA1_PRA

            ; Return to title - complete game loop
            jsr show_title
            lda #STATE_TITLE
            sta game_state
            rts
