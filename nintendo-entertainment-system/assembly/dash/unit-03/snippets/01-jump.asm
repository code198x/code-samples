    ; --- Jump check ---
    lda buttons
    and #BTN_A              ; A button pressed?
    beq @no_jump
    lda on_ground
    beq @no_jump            ; Already airborne — can't jump again
    lda #JUMP_VEL
    sta vel_y               ; Set upward velocity
    lda #0
    sta on_ground           ; Leave the ground
@no_jump:
