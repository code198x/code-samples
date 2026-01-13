; Blitter Register Definitions
; The Blitter is a DMA coprocessor for fast block copies

; Channel pointers (32-bit addresses)
BLTAPTH     equ $050            ; A channel pointer (source)
BLTDPTH     equ $054            ; D channel pointer (destination)

; Modulos (bytes to skip between rows)
BLTAMOD     equ $064            ; A channel modulo
BLTDMOD     equ $066            ; D channel modulo

; Masks (for partial word operations)
BLTAFWM     equ $044            ; A first word mask
BLTALWM     equ $046            ; A last word mask

; Control registers
BLTCON0     equ $040            ; Operation control
BLTCON1     equ $042            ; Mode control

; Size register (starts the blit!)
BLTSIZE     equ $058            ; [height 15:6] [width 5:0]
                                ; Width in words, height in lines
