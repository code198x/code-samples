; Meet the Machine - Unit 15: The Machine Speaks Back
; Assemble with: acme -f cbm -o sid.prg sid.asm
;
; The SID is the C64's sound chip - a three-voice synthesiser. You set a voice's
; pitch, its envelope, and the volume, then pick a waveform and open the "gate".
; The chip holds the note on its own while the CPU does nothing.

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00   ; 10 SYS 2061

*= $080d

        ; a background colour, so the screen shows it's running
        lda #$00
        sta $d020           ; border black
        lda #$06
        sta $d021           ; background blue

        ; clear the start-up text away to a blank screen
        ldx #0
clear   lda #$20            ; space
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne clear

        ; ----------------------------------------------- YOUR CODE START
        ; --- set up SID voice 1 ---
        lda #$0f
        sta $d418           ; master volume to maximum (0-15)

        lda #$00
        sta $d400           ; frequency, low byte
        lda #$11
        sta $d401           ; frequency, high byte  -> the pitch

        lda #$00
        sta $d405           ; attack 0, decay 0
        lda #$f0
        sta $d406           ; sustain 15, release 0  -> the note holds at full

        lda #$21
        sta $d404           ; sawtooth waveform + gate ON  -> the note starts
        ; ------------------------------------------------- YOUR CODE END

loop    jmp loop            ; the CPU idles; the SID plays on by itself
