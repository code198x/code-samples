; Lesson 004: Note Tables
; Data-driven music playback - "Mary Had a Little Lamb"

        * = $0801       ; BASIC start address
        ; BASIC stub: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810       ; Machine code start ($0810 = 2064 decimal)
        jmp init        ; Jump over data tables to initialization

; ============================================================================
; FREQUENCY TABLE - Chromatic scale C4-C5 (A440 PAL tuning)
; ============================================================================
; Index: 0=C4, 1=C#4, 2=D4, 3=D#4, 4=E4, 5=F4, 6=F#4, 7=G4, 8=G#4, 9=A4, 10=A#4, 11=B4, 12=C5
freq_lo: !byte $67, $72, $89, $aa, $ed, $3b, $94, $13, $a4, $45, $04, $da, $ce
freq_hi: !byte $11, $12, $13, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20, $22
; C4=$1167, C#4=$1272, D4=$1389, D#4=$14AA, E4=$15ED, F4=$173B, F#4=$1894
; G4=$1A13, G#4=$1BA4, A4=$1D45, A#4=$1F04, B4=$20DA, C5=$22CE

; ============================================================================
; MELODY DATA - "Mary Had a Little Lamb"
; ============================================================================
; Note indices: 0=C, 2=D, 4=E, 5=F, 7=G
melody:
        !byte 4, 2, 0, 2, 4, 4, 4       ; E D C D E E E
        !byte 2, 2, 2, 4, 7, 7          ; D D D E G G
        !byte 4, 2, 0, 2, 4, 4, 4, 4    ; E D C D E E E E
        !byte 2, 2, 4, 2, 0, $ff        ; D D E D C (end marker)

; Duration for each note (in delay iterations)
durations:
        !byte 4, 4, 4, 4, 4, 4, 8       ; Quarter notes + half
        !byte 4, 4, 8, 4, 4, 8
        !byte 4, 4, 4, 4, 4, 4, 4, 4
        !byte 4, 4, 4, 4, 8, 0

melody_len = 26

; ============================================================================
; INITIALIZATION
; ============================================================================
init:
        jsr clear_sid
        ldx #$00                ; Melody index

; ============================================================================
; MELODY PLAYBACK LOOP
; ============================================================================
play_loop:
        lda melody,x            ; Get note index
        cmp #$ff                ; Check for end marker
        beq done

        tay                     ; Y = note index for frequency lookup (save it!)

        ; HARD RESET the oscillator using TEST bit
        lda #$08                ; Set TEST bit (bit 3)
        sta $d404
        lda #$00                ; Clear everything
        sta $d404               ; Full stop

        lda freq_lo,y           ; Get frequency low byte
        sta $d400               ; Voice 1 frequency low
        lda freq_hi,y           ; Get frequency high byte
        sta $d401               ; Voice 1 frequency high

        lda #$21                ; Sawtooth waveform + gate ON
        sta $d404               ; Voice 1 control

        txa                     ; Save melody index FIRST
        pha
        lda durations,x         ; Get note duration (X still valid)
        jsr note_delay          ; Wait for note duration
        pla                     ; Restore melody index
        tax

        lda #$00                ; STOP the note completely
        sta $d404               ; Clear control register

        txa                     ; Save melody index again
        pha
        jsr short_pause         ; Brief gap between notes
        pla                     ; Restore melody index
        tax

        inx                     ; Next note
        jmp play_loop

done:
        lda #$14                ; Delay value (20 iterations)
        jsr note_delay          ; Long pause before repeating
        jmp init                ; Loop melody forever

; ============================================================================
; CLEAR SID - Initialize all SID registers
; ============================================================================
clear_sid:
        lda #$00
        ldx #$00
cls_loop:
        sta $d400,x
        inx
        cpx #$1d                ; 29 SID registers
        bne cls_loop

        ; Set ADSR for musical sound
        lda #$08                ; Attack=0 (instant), Decay=8 (medium)
        sta $d405               ; Voice 1 Attack/Decay
        lda #$b0                ; Sustain=11 (high), Release=0 (instant)
        sta $d406               ; Voice 1 Sustain/Release

        ; Set volume
        lda #$0f                ; Maximum volume
        sta $d418               ; Volume register

        rts

; ============================================================================
; NOTE_DELAY - Wait for note duration
; ============================================================================
; Input: A register = duration multiplier (from durations table)
note_delay:
        sta temp                ; Save duration multiplier
        lda #$00
nd_outer:
        pha                     ; Save outer loop counter
        ldx #$40                ; X = middle loop counter (reduced from $ff)
nd_middle:
        ldy #$ff                ; Y = inner loop counter
nd_inner:
        dey
        bne nd_inner            ; Inner delay loop (255 iterations)
        dex
        bne nd_middle           ; Middle loop (64 iterations)
        pla                     ; Restore outer counter
        clc
        adc #$01
        cmp temp                ; Compare with duration
        bne nd_outer
        rts

; ============================================================================
; SHORT_PAUSE - Brief gap between notes for clarity
; ============================================================================
short_pause:
        ldy #$80                ; Increased from $10 to $80
sp1:    ldx #$ff
sp2:    dex
        bne sp2
        dey
        bne sp1
        rts

; ============================================================================
; VARIABLES
; ============================================================================
temp:   !byte $00
