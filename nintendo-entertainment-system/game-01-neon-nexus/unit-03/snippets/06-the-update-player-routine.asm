.proc update_player
    ; Check Up
    lda buttons
    and #BTN_UP
    beq @check_down
    dec player_y            ; Move up (Y decreases)

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_left
    inc player_y            ; Move down (Y increases)

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_right
    dec player_x            ; Move left (X decreases)

@check_right:
    lda buttons
    and #BTN_RIGHT
    beq @done
    inc player_x            ; Move right (X increases)

@done:
    ; Copy position to shadow OAM
    lda player_y
    sta $0200               ; Sprite 0 Y position
    lda player_x
    sta $0203               ; Sprite 0 X position
    rts
.endproc
