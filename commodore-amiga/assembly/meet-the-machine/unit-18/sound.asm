;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 18: Paula Makes a Sound
;
; Paula is the sound chip. You hand her a sample - a list of numbers describing
; a waveform - tell her how loud, how fast and how long, and switch on her DMA.
; She then plays it on her own, looping, while the CPU does nothing. Here: a tone.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
BPLCON0     equ $100
COLOR00     equ $180
AUD0LC      equ $0a0            ; channel 0 sample address (long)
AUD0LEN     equ $0a4            ; length in words
AUD0PER     equ $0a6            ; period (pitch)
AUD0VOL     equ $0a8            ; volume (0-64)

SAMPLELEN   equ 32              ; bytes in the sample (one square-wave cycle)

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- a background colour, so the screen shows it's running ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; ----------------------------------------------- YOUR CODE START
            ; --- hand Paula the sample and start it on channel 0 ---
            lea     sample,a0
            move.l  a0,AUD0LC(a5)       ; where the waveform lives
            move.w  #SAMPLELEN/2,AUD0LEN(a5)  ; its length in words
            move.w  #320,AUD0PER(a5)    ; period - lower is higher-pitched
            move.w  #64,AUD0VOL(a5)     ; full volume

            move.w  #$8281,DMACON(a5)   ; DMA on: master + Copper + audio ch0
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

;──────────────────────────────────────────────────────────────
; The sample: one cycle of a square wave - half high, half low.
; Paula reads signed 8-bit numbers; $40 is +64, $c0 is -64.
;──────────────────────────────────────────────────────────────
            even
sample:
            dc.b    $40,$40,$40,$40,$40,$40,$40,$40
            dc.b    $40,$40,$40,$40,$40,$40,$40,$40
            dc.b    $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
            dc.b    $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0

            even
copperlist:
            dc.w    BPLCON0,$0200       ; no bitplanes - just a flat colour
            dc.w    COLOR00,$008f       ; background blue, "sound is playing"
            dc.w    $ffff,$fffe
