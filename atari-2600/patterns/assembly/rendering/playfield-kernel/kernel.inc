; Enter in horizontal blank at start of first picture line.
; NTSC: 24 bands, eight scanlines each. Caller clears VBLANK beforehand.
; No JSR, input, sound or buffer changes inside this loop.
; PF stores finish at CPU cycles 7,14,21 after each WSYNC release.
pf_kernel:
    ldy #0
    lda #24
    sta PF+14
pf_kernel_band:
    lda #8
    sta PF+13
pf_kernel_line:
    sta $02                   ; WSYNC: next scanline boundary
    lda PF_BUFFER,y           ; 4 cycles, no page crossing at $80..$c7
    sta $0d                   ; PF0, write ends at cycle 7
    lda PF_BUFFER+1,y
    sta $0e                   ; PF1, cycle 14
    lda PF_BUFFER+2,y
    sta $0f                   ; PF2, cycle 21 (visible starts at 22 2/3)
    dec PF+13
    bne pf_kernel_line
    iny
    iny
    iny
    dec PF+14
    bne pf_kernel_band
    rts                       ; caller must finish this final line before blanking
pf_kernel_end:
