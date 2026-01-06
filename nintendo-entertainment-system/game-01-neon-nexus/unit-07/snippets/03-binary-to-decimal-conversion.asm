.proc div100
    ldx #0
@loop:
    cmp #100
    bcc @done
    sec
    sbc #100
    inx
    jmp @loop
@done:
    sta temp
    txa
    rts
.endproc
