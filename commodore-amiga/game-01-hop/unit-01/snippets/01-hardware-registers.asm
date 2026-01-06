CUSTOM      equ $dff000

; DMA and interrupt control
DMACONR     equ $002        ; DMA control read
DMACON      equ $096        ; DMA control write
INTENA      equ $09a        ; Interrupt enable
INTREQ      equ $09c        ; Interrupt request

; Copper registers
COP1LC      equ $080        ; Copper list 1 address
COPJMP1     equ $088        ; Restart copper at COP1LC

; Colour registers
COLOR00     equ $180        ; Background colour
