; Raster stripes: a timed test effect for the production verifier.
;
; Each frame, straight after the interrupt, the border changes colour once per
; scan line for 56 lines of the top border. The loop must take exactly one
; line's worth of T-states, which differs by model: 224 on the 48K and the
; Pentagon, 228 on the 128K, +2, +2A and +3. The program measures the frame to
; tell which it is running on and picks the matching loop. With the right loop
; the stripes are level; with the wrong one they slant.
;
; After FRAMES_TO_END frames it writes END_VALUE to END_MARKER, which the
; verifier reads to know the program reached its end.
;
; All code and data sit at $8000 or above, which no model contends, so the
; T-state counts below hold on every one of them. Each colour change falls in
; the horizontal retrace, so a correctly timed build shows level bands whatever
; phase it started in, while a wrong line length drifts the change into view.

FRAMES_TO_END   equ 150
END_VALUE       equ $A5
STRIPE_LINES    equ 56
END_MARKER      equ $8F00      ; fixed, so the verifier can read it

; MISTIME_128K and PADDING are set by the file that includes this one:
; stripes.asm (neither), stripes-mistimed.asm or stripes-padded.asm, the
; verifier's two controls.
MODEL           equ $8F01      ; 1: 48K, 2: 128K family, 3: Pentagon

        org $8000

start:
        di
        ld sp,$9000            ; stack in uncontended memory
        ; IM 2 with a 257-byte table of $FD at $FE00: whatever the data bus
        ; holds, the CPU jumps to $FDFD, where a JP leads to the handler.
        ld hl,$fe00
        ld de,$fe01
        ld bc,256
        ld (hl),$fd
        ldir
        ld a,$c3               ; JP isr at $FDFD
        ld ($fdfd),a
        ld hl,isr
        ld ($fdfe),hl
        ld a,$fe
        ld i,a
        im 2
        xor a
        out ($fe),a
        ld (END_MARKER),a

; Measure one frame: count a 35 T-state loop between two interrupts.
; 69,888 / 35 is about 1997 (48K); 70,908 / 35 about 2026 (128K family);
; 71,680 / 35 = 2048 (Pentagon).
        ei
        halt                   ; start on an interrupt
        xor a
        ld (tick),a
        ld hl,0
count:  inc hl                 ; 6
        ld a,(tick)            ; 13
        or a                   ; 4
        jr z,count             ; 12  -> 35 T-states a pass
        ; HL now holds the passes in one frame.
        ld de,2011             ; under 2011: the 48K
        or a
        sbc hl,de
        ld a,1
        jr c,is224
        ld de,2037-2011        ; 2011 to 2036: the 128K family
        sbc hl,de              ; carry is clear here
        ld a,2
        jr c,is228
        ld a,3                 ; 2037 and over: the Pentagon, at 224
is224:  ld hl,line224
        jr chosen
is228:  ld hl,line228+MISTIME_128K*(line224-line228)
chosen: ld (stripes+1),hl
        ld (MODEL),a           ; the verifier reads which model it found

main:   halt                   ; one frame per pass
stripes:
        call line224           ; operand rewritten above
        xor a
        out ($fe),a
        ld hl,(frames)
        inc hl
        ld (frames),hl
        ld de,FRAMES_TO_END
        or a
        sbc hl,de
        jr nz,main
        ld a,END_VALUE
        ld (END_MARKER),a
        jr main

; Each routine waits LEAD_IN NOPs, then changes the border once a line. The
; lead-in puts each change in the horizontal retrace, where the up-to-3
; T-state wake-up jitter of HALT can't be seen. Measured in Emu198x v0.48.3 by
; reading the captures: lead-ins of 6 to 18 NOPs hide the change on the 48K,
; and 6 to at least 15 on the 128K and Pentagon. 12 sits in the middle.
LEAD_IN         equ 12

; 224 T-states a line, for the 48K and Pentagon: 11+4+7+7+171+7+4+13 = 224.
line224:
        REPT LEAD_IN
        nop
        ENDM
        ld b,STRIPE_LINES
        ld a,1
loop224:
        out ($fe),a            ; 11
        inc a                  ; 4
        and 7                  ; 7
        ld e,11                ; 7
wait224:
        dec e                  ; 4
        jr nz,wait224          ; 12/7 -> 11 passes = 171
        cp (hl)                ; 7
        nop                    ; 4
        djnz loop224           ; 13
        ret

; 228 T-states a line, for the 128K family: the same with one more NOP.
line228:
        REPT LEAD_IN
        nop
        ENDM
        ld b,STRIPE_LINES
        ld a,1
loop228:
        out ($fe),a            ; 11
        inc a                  ; 4
        and 7                  ; 7
        ld e,11                ; 7
wait228:
        dec e                  ; 4
        jr nz,wait228          ; 171
        cp (hl)                ; 7
        nop                    ; 4
        nop                    ; 4
        djnz loop228           ; 13
        ret

isr:    push af
        ld a,1
        ld (tick),a
        pop af
        ei
        reti

tick:       db 0
frames:     dw 0

        IF PADDING
        ds 64,$55              ; harmless bytes (stripes-padded.asm)
        ENDIF

        end start
