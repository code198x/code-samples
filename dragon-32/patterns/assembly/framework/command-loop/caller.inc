; EXEC $7000 under Dragon 32 BASIC. Reserve above CLEAR 200,&H6FFF.
start:
    pshs cc,dp,d,x,y,u
    lda #INITIAL
    jsr turn_init
    jsr draw_box
main:
    lda #RESET_EACH
    beq keep_state
    clra
    jsr turn_init
keep_state:
    jsr show_turn
poll:
    jsr $8006
    tsta
    beq poll
    cmpa #'Q'
    beq finished
    cmpa #'1'
    bne main
    jsr turn_advance
    jsr trigger_sound
    bra main
finished:
    puls cc,dp,d,x,y,u,pc
