state_title:
            ; Read keyboard row for keys 1-5
            ld      a, ROW_12345
            in      a, (KEY_PORT)

            ; Check for key 1 (Two Player)
            bit     0, a                ; Key 1
            jr      z, .st_two_player

            ; Check for key 2 (AI Easy)
            bit     1, a                ; Key 2
            jr      z, .st_ai_easy

            ; Check for key 3 (AI Medium)
            bit     2, a                ; Key 3
            jr      z, .st_ai_medium

            ; Check for key 4 (AI Hard)
            bit     3, a                ; Key 4
            jr      z, .st_ai_hard

            jp      main_loop           ; No valid key - keep waiting

.st_two_player:
            xor     a                   ; GM_TWO_PLAYER = 0
            ld      (game_mode), a
            call    start_game
            jp      main_loop

.st_ai_easy:
            ld      a, GM_VS_AI
            ld      (game_mode), a
            ld      a, AI_EASY
            ld      (ai_difficulty), a
            call    start_game
            jp      main_loop

; .st_ai_medium and .st_ai_hard follow same pattern...
