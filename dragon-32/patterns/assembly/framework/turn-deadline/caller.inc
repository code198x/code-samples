TURN equ $7200
EXPIRIES equ $7201
KEY equ $7202
CONTEXT equ $7210
start:
    pshs cc,dp,d,x,y,u
    clr TURN
    clr EXPIRIES
    ldx #CONTEXT
    ldd #DURATION
    std ,x
    jsr clock_read
    jsr deadline_init
main:
    ldx #CONTEXT
    jsr clock_read
    jsr deadline_poll
    jsr $8006
    sta KEY
    ldx #CONTEXT
    jsr dispatch
    jsr draw_state
    lda KEY
    cmpa #'Q'
    bne main
    puls cc,dp,d,x,y,u,pc
; Direct text cells only; display each status byte as two hex digits.
draw_state:
    ldu #TURN
    ldy #$0400
    jsr draw_byte
    ldu #EXPIRIES
    ldy #$0403
    jsr draw_byte
    ldu #CONTEXT+4
    ldy #$0406
    jsr draw_byte
    rts
draw_byte:
    lda ,u
    lsra
    lsra
    lsra
    lsra
    jsr hex_digit
    sta ,y+
    lda ,u
    anda #15
    jsr hex_digit
    sta ,y
    rts
hex_digit:
    cmpa #10
    blo hex_number
    adda #7
hex_number:
    adda #48
    anda #63
    rts
