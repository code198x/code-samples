check_pause:
    ; Calculate newly pressed buttons
    lda buttons_prev
    eor #$FF            ; invert previous state
    and buttons         ; mask with current state
    sta temp            ; temp = newly pressed buttons

    ; Save current buttons for next frame
    lda buttons
    sta buttons_prev

    ; Check if START was just pressed
    lda temp
    and #BTN_START
    beq @done           ; not a new press

    ; Toggle pause flag
    lda pause_flag
    eor #1              ; flip between 0 and 1
    sta pause_flag

    ; Update display
    beq @unpause
    jsr draw_pause_text
    rts
@unpause:
    jsr clear_pause_text
@done:
    rts
