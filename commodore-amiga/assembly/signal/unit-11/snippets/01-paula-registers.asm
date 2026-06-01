; Paula Audio Registers
; Channel 0 registers for sound playback

; Paula audio registers (channel 0)
AUD0LC      equ $0a0           ; Sample pointer (long)
AUD0LEN     equ $0a4           ; Sample length in words
AUD0PER     equ $0a6           ; Period (pitch): lower = higher
AUD0VOL     equ $0a8           ; Volume: 0-64

; Audio DMA control
; DMACON bit 0 = AUD0 channel enable
; To disable: move.w #$0001,DMACON(a5)
; To enable:  move.w #$8001,DMACON(a5)

; Period values (approximate):
; 200 = high pitch (chirp)
; 300 = medium pitch
; 500 = low pitch (death)

; Sample format:
; - 8-bit signed values (-128 to +127)
; - $7f = maximum positive, $80 = maximum negative
; - Must be in Chip RAM for DMA access
; - Length in words (bytes / 2)
