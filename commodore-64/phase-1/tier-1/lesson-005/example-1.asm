; Lesson 005: Timing & Rhythm
; Frame-based music playback with CIA Timer A - "Mary Had a Little Lamb" at 120 BPM

        * = $0801       ; BASIC start address
        ; BASIC stub: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810       ; Machine code start ($0810 = 2064 decimal)
        jmp init        ; Jump to initialization

; ============================================================================
; TIMING CONSTANTS
; ============================================================================
; CIA Timer A values for 60Hz frame rate (PAL: 985248 Hz / 60 = 16421 cycles)
TIMER_LO = $2d          ; 16421 & $FF
TIMER_HI = $40          ; 16421 >> 8

; Musical timing at 120 BPM (2 beats per second)
; At 60 fps, quarter note = 0.5 seconds = 30 frames
QUARTER_NOTE = 30
EIGHTH_NOTE  = 15
HALF_NOTE    = 60

; ============================================================================
; FREQUENCY TABLE - Chromatic scale C4-C5 (A440 PAL tuning)
; ============================================================================
freq_lo: !byte $67, $72, $89, $aa, $ed, $3b, $94, $13, $a4, $45, $04, $da, $ce
freq_hi: !byte $11, $12, $13, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20, $22

; ============================================================================
; MELODY DATA - "Mary Had a Little Lamb"
; ============================================================================
; Note indices: 0=C, 2=D, 4=E, 5=F, 7=G
melody:
        !byte 4, 2, 0, 2, 4, 4, 4       ; E D C D E E E
        !byte 2, 2, 2, 4, 7, 7          ; D D D E G G
        !byte 4, 2, 0, 2, 4, 4, 4, 4    ; E D C D E E E E
        !byte 2, 2, 4, 2, 0, $ff        ; D D E D C (end marker)

; Duration for each note (in frames at 60 fps)
timing:
        !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
        !byte QUARTER_NOTE, QUARTER_NOTE, HALF_NOTE

        !byte QUARTER_NOTE, QUARTER_NOTE, HALF_NOTE
        !byte QUARTER_NOTE, QUARTER_NOTE, HALF_NOTE

        !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
        !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE

        !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
        !byte HALF_NOTE, 0

; ============================================================================
; VARIABLES
; ============================================================================
note_ptr:    !byte $00          ; Current position in melody
note_frames: !byte $00          ; Frames remaining for current note

; ============================================================================
; INITIALIZATION
; ============================================================================
init:
        jsr clear_sid           ; Initialize SID chip
        jsr init_timer          ; Set up CIA Timer A for 60Hz
        lda #$00
        sta note_ptr            ; Start at beginning of melody
        jsr next_note           ; Play first note
        jmp main_loop

; ============================================================================
; MAIN LOOP - Frame-based playback
; ============================================================================
main_loop:
        jsr wait_frame          ; Wait for next 60Hz tick

        ; Check if current note finished
        dec note_frames
        bne main_loop           ; Still playing current note

        ; Current note finished, start next note
        jsr next_note
        jmp main_loop

; ============================================================================
; NEXT NOTE - Start playing the next note in the melody
; ============================================================================
next_note:
        ; Turn off current note
        lda #$20                ; Sawtooth waveform, gate OFF
        sta $d404

        ; Get next note from melody
        ldx note_ptr
        lda melody,x
        cmp #$ff                ; Check for end marker
        beq restart_melody

        ; Play the note
        tay                     ; Y = note index for frequency lookup
        lda freq_lo,y
        sta $d400               ; Voice 1 frequency low
        lda freq_hi,y
        sta $d401               ; Voice 1 frequency high
        lda #$21                ; Sawtooth waveform + gate ON
        sta $d404               ; Voice 1 control

        ; Set duration for this note
        ldx note_ptr
        lda timing,x            ; Get duration in frames
        sta note_frames         ; Set frame counter

        ; Move to next note
        inc note_ptr
        rts

restart_melody:
        lda #$00
        sta note_ptr            ; Reset to start of melody
        jmp next_note           ; Start playing from beginning

; ============================================================================
; WAIT_FRAME - Wait for next CIA Timer A tick (60Hz)
; ============================================================================
wait_frame:
wf_loop:
        lda $dc0d               ; Read CIA #1 interrupt control register
        and #$01                ; Check bit 0 (Timer A underflow)
        beq wf_loop             ; If 0, timer hasn't fired yet - keep waiting

        ; Timer fired - we've completed one frame
        rts

; ============================================================================
; INIT_TIMER - Set up CIA Timer A for 60Hz timing
; ============================================================================
init_timer:
        lda #$00                ; Stop timer
        sta $dc0e               ; CIA #1 Timer A control register

        lda #TIMER_LO           ; Set timer value (16421 cycles for PAL 60Hz)
        sta $dc04               ; Timer A low byte
        lda #TIMER_HI
        sta $dc05               ; Timer A high byte

        lda #$11                ; %00010001 = Start timer, continuous mode, count system clock
        sta $dc0e               ; Timer A control register
        rts

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
