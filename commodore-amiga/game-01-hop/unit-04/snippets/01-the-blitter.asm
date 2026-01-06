wait_blit:
            btst    #6,DMACONR(a5)  ; Check BBUSY flag
            bne.s   wait_blit
            rts
