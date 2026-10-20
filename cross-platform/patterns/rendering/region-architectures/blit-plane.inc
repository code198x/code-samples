; Copy one aligned 16x8 monochrome tile plane: A1 source, A2 destination, A5 custom base.
; Both buffers are Chip RAM. Source pitch 2 bytes; destination pitch 40 bytes.
; Preserves address/data registers; clobbers CCR and the named blitter registers.
; Caller owns blitter and enables master+blitter DMA; returns after completion.
region_blit_plane:
    bsr region_wait_blitter
    move.w #$09f0,$040(a5)
    clr.w $042(a5)
    move.w #$ffff,$044(a5)
    move.w #$ffff,$046(a5)
    move.l a1,$050(a5)
    move.l a2,$054(a5)
    clr.w $064(a5)
    move.w #38,$066(a5)
    move.w #$0201,$058(a5)
    bsr region_wait_blitter
    rts
region_wait_blitter:
    ; Initial read precedes the busy-bit polling loop (old Agnus precaution).
    tst.w $002(a5)
region_wait_busy:
    btst #6,$002(a5)
    bne region_wait_busy
    rts
