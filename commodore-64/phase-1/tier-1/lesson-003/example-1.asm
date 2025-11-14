; Lesson 003: Keyboard Triggers
; Interactive musical keyboard - Press A/S/D/F/G/H/J/K to play C-major scale

        * = $0801       ; BASIC start address
        ; BASIC stub: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810       ; Machine code start ($0810 = 2064 decimal)
        jmp init        ; Jump over data tables to initialization

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
; Key A: Row 1, Col 2  →  Write $FD to $DC00, check bit 2 in $DC01
; Key S: Row 1, Col 5  →  Write $FD to $DC00, check bit 5 in $DC01
; Key D: Row 2, Col 2  →  Write $FB to $DC00, check bit 2 in $DC01
; Key F: Row 2, Col 5  →  Write $FB to $DC00, check bit 5 in $DC01
; Key G: Row 3, Col 2  →  Write $F7 to $DC00, check bit 2 in $DC01
; Key H: Row 3, Col 5  →  Write $F7 to $DC00, check bit 5 in $DC01
; Key J: Row 4, Col 2  →  Write $EF to $DC00, check bit 2 in $DC01
; Key K: Row 4, Col 5  →  Write $EF to $DC00, check bit 5 in $DC01

; Row select masks (write to $DC00 - bit=0 selects that row)
key_row_sel: !byte $fd, $fd, $fb, $fb, $f7, $f7, $ef, $ef
; $FD = %11111101 = row 1 (A, S)
; $FB = %11111011 = row 2 (D, F)
; $F7 = %11110111 = row 3 (G, H)
; $EF = %11101111 = row 4 (J, K)

; Column check masks (read from $DC01 - bit=0 means key pressed)
key_col_chk: !byte $04, $20, $04, $20, $04, $20, $04, $20
; $04 = %00000100 = column 2 (A, D, G, J)
; $20 = %00100000 = column 5 (S, F, H, K)

num_keys = 8

; ============================================================================
; VARIABLES
; ============================================================================
current_note: !byte $ff         ; Currently playing note ($ff = none)

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
        ldy #$00                ; Y = flag: 0 = no key pressed yet

scan_loop:
        ; Select row for this key
        lda key_row_sel,x
        sta $dc00               ; Write row select mask to Port A

        ; Read column data
        lda $dc01               ; Read columns from Port B
        and key_col_chk,x       ; Isolate the column we care about
        bne next_key            ; If bit=1, key not pressed, skip to next

        ; Key IS pressed (bit=0) - check if it's a new note
        ldy #$01                ; Flag: a key was pressed this scan
        cpx current_note        ; Same note as last time?
        beq next_key            ; Yes - skip (already playing)

        ; New note - play it
        jsr play_note

next_key:
        inx                     ; Next key
        cpx #num_keys           ; All 8 keys scanned?
        bne scan_loop           ; No - continue scanning

        ; After scanning all keys, check if any were pressed
        cpy #$00                ; Was any key pressed this cycle?
        bne main                ; Yes - keep gate on, restart scan

        ; No keys pressed - turn gate off and reset note tracker
        lda #$10                ; Triangle waveform + gate OFF
        sta $d404               ; Voice 1 control register
        lda #$ff                ; Reset current note
        sta current_note

        jmp main                ; Restart scan from key 0

; ============================================================================
; PLAY NOTE - X register contains note index
; ============================================================================
play_note:
        ; Save current note
        stx current_note

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

        ; Set ADSR for sustained sound
        lda #$00                ; Attack=0 (instant), Decay=0 (no decay)
        sta $d405               ; Voice 1 Attack/Decay
        lda #$f0                ; Sustain=15 (full volume), Release=0 (instant off)
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
