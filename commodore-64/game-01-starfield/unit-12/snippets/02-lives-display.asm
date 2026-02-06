        ; --- init_game (lives section) ---

        ; Lives
        lda #$03
        sta lives
        lda #$33            ; Screen code for '3'
        sta $0427

        ; --- One-time setup (colour) ---

        ; Set lives colour to white (persists across restarts)
        lda #$01
        sta $d827
