; Lesson 003: Keyboard Triggers
; Interactive musical keyboard - Press A/S/D/F/G/H/J/K to play C-major scale

        * = $0801       ; BASIC start address
        ; BASIC stub: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810       ; Machine code start ($0810 = 2064 decimal)

; ============================================================================
; FREQUENCY TABLE - C-major scale (C4-C5) A440 PAL tuning
; ============================================================================
freq_lo: !byte $67, $89, $ed, $3b, $13, $45, $da, $ce
freq_hi: !byte $11, $13, $15, $17, $1a, $1d, $20, $22
; C4=$1167, D4=$1389, E4=$15ED, F4=$173B, G4=$1A13, A4=$1D45, B4=$20DA, C5=$22CE

; ============================================================================
; KEYBOARD MATRIX SCAN CODES
; ============================================================================
; C64 keyboard is 8x8 matrix. Each key defined by row (0-7) and column (0-7).
; To scan: write column mask to $DC00, read row bits from $DC01.
; Bit=0 means pressed, bit=1 means not pressed (inverted logic).

; Mapping: A/S/D/F/G/H/J/K keys to C/D/E/F/G/A/B/C notes
; Key A: Row 1, Col 2
; Key S: Row 1, Col 5
; Key D: Row 2, Col 2
; Key F: Row 2, Col 5
; Key G: Row 3, Col 2
; Key H: Row 3, Col 5
; Key J: Row 4, Col 2
; Key K: Row 4, Col 5

; Column masks (bit=0 selects that column)
key_col: !byte $fb, $df, $fb, $df, $fb, $df, $fb, $df
; $FB = %11111011 = column 2
; $DF = %11011111 = column 5

; Row masks (bit to check after reading $DC01)
key_row: !byte $02, $02, $04, $04, $08, $08, $10, $10
; $02 = %00000010 = row 1
; $04 = %00000100 = row 2
; $08 = %00001000 = row 3
; $10 = %00010000 = row 4

num_keys = 8

; ============================================================================
; INITIALIZATION
; ============================================================================
init:
        jsr clear_sid
        jsr setup_cia
        jmp main

; ============================================================================
; MAIN LOOP - Scan keyboard continuously
; ============================================================================
main:
        ldx #$00                ; Start with key 0

scan_loop:
        ; Select column for this key
        lda key_col,x
        sta $dc00               ; Write column mask

        ; Read row data
        lda $dc01               ; Read all rows
        and key_row,x           ; Isolate the row we care about
        bne next_key            ; If bit=1, key not pressed

        ; Key is pressed (bit=0) - play the note!
        jsr play_note

next_key:
        inx                     ; Next key
        cpx #num_keys           ; All 8 keys scanned?
        bne scan_loop           ; No - continue scanning

        jmp main                ; Yes - restart scan from key 0

; ============================================================================
; PLAY NOTE - X register contains note index
; ============================================================================
play_note:
        ; Load frequency for this note
        lda freq_lo,x
        sta $d400               ; Voice 1 frequency low
        lda freq_hi,x
        sta $d401               ; Voice 1 frequency high

        ; Trigger note (gate on)
        lda #$11                ; Triangle waveform + gate on
        sta $d404               ; Voice 1 control

        rts

; ============================================================================
; CLEAR SID - Initialize all SID registers
; ============================================================================
clear_sid:
        lda #$00
        ldx #$00
clear_loop:
        sta $d400,x
        inx
        cpx #$1d                ; 29 SID registers
        bne clear_loop

        ; Set ADSR for fast, responsive sound
        lda #$09                ; Attack=0 (instant), Decay=9 (fast)
        sta $d405               ; Voice 1 Attack/Decay
        lda #$00                ; Sustain=0, Release=0 (immediate cutoff)
        sta $d406               ; Voice 1 Sustain/Release

        ; Set volume
        lda #$0f                ; Maximum volume
        sta $d418               ; Volume register

        rts

; ============================================================================
; SETUP CIA - Configure keyboard scanning
; ============================================================================
setup_cia:
        lda #$ff                ; All bits = output
        sta $dc02               ; Port A data direction (columns = output)

        lda #$00                ; All bits = input
        sta $dc03               ; Port B data direction (rows = input)

        rts
