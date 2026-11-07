; Original colour display using the SNK cartridge/USER contract.
; Header and recognition words: SNK Development Manual, System Program 6-9.
        dc.l $10f300,$c00402
        dcb.l 23,exception
        dc.l vblank,timer
        dcb.l 37,exception
        dc.b "NEO-GEO",0
        dc.w $1980
        dc.l $1000,$100000
        dc.w 0
        dc.b 0,0
        dc.l info,info,info
        jmp user.l
        jmp user.l
        jmp user.l
        jmp user.l
        dcb.b 72,0
        dc.l recognition
recognition:
        dc.w $7600,$4a6d,$0a14,$6600,$003c,$206d,$0a04,$3e2d
        dc.w $0a08,$13c0,$0030,$0001,$3210,$0c01,$00ff,$671a
        dc.w $3028,$0002,$b02d,$0ace,$6610,$3028,$0004,$b02d
        dc.w $0acf,$6606,$b22d,$0ad0,$6708,$5088,$51cf,$ffd4
        dc.w $3607,$4e75,$206d,$0a04,$3e2d,$0a08,$3210,$e049
        dc.w $0c01,$00ff,$671a,$3010,$b02d,$0ace,$6612,$3028
        dc.w $0002,$e048,$b02d,$0acf,$6606,$b22d,$0ad0,$6708
        dc.w $5888,$51cf,$ffd8,$3607,$4e75
        dcb.b 256,0
info:
        dc.b "COLOUR DISPLAY",0
        dcb.b 241,0
user:
        cmpi.b #2,$10fdae
        bcs.s finish
        move.w #$4f00,$401ffe
        move.w #$2000,sr
wait:
        move.b d0,$300001
        bra.s wait
finish:
        jmp $c00444
vblank:
        btst #7,$10fd80
        bne.s active
        jmp $c00438
active:
        move.w #4,$3c000c
        move.b d0,$300001
        movem.l d0-d7/a0-a6,-(sp)
        jsr $c0044a
        movem.l (sp)+,d0-d7/a0-a6
        rte
timer:
        move.w #2,$3c000c
exception:
        rte

        dcb.b 2980,0
