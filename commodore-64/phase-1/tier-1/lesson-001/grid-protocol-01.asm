; GRID PROTOCOL: Terminal Activation
; Lesson 1 - Establishing first contact with the Grid
; Year: 2085 - Post-Collapse Era
; 
; Objective: Activate a C64 terminal and establish Grid connection
; Output: Black screen with cyan border, "GRID PROTOCOL ACTIVE" message

;===============================================================================
; GATEWAY PROTOCOL (BASIC STUB)
;===============================================================================
!to "grid-protocol-01.prg", cbm    ; Output with CBM format (adds load address)

*=$0801
        ; Minimal BASIC stub - every byte counts in the Grid
        !byte $0b,$08          ; Next line pointer: $080b
        !byte $0a,$00          ; Line number: 10
        !byte $9e              ; SYS token
        !byte $32,$30,$36,$31  ; "2061" as PETSCII
        !byte $00              ; End of line
        !byte $00,$00          ; End of program

;===============================================================================
; GRID INITIALIZATION
;===============================================================================
*=$080d                        ; 2061 decimal - earliest safe entry

grid_init:
        ; Activate terminal visuals
        lda #$03               ; Cyan frequency (Grid signature)
        sta $d020              ; Border activation register
        
        lda #$00               ; Black void (data absence)
        sta $d021              ; Background activation register
        
;===============================================================================
; DATA MATRIX PURGE
;===============================================================================
        ; Clear first 768 bytes (3 pages)
        ldx #0                 ; Initialize scan position
clear_matrix:
        lda #$20               ; Space character (empty cell)
        sta $0400,x            ; Screen page 1 (256 bytes)
        sta $0500,x            ; Screen page 2 (256 bytes)
        sta $0600,x            ; Screen page 3 (256 bytes)
        
        ; Set corresponding colors to cyan
        lda #$03               ; Cyan frequency
        sta $d800,x            ; Color page 1
        sta $d900,x            ; Color page 2
        sta $da00,x            ; Color page 3
        
        inx                    ; Next position
        bne clear_matrix       ; Loop until X wraps to 0
        
        ; Handle remaining 232 bytes (1000 - 768 = 232)
        ldx #0
clear_final:
        lda #$20               ; Space character
        sta $0700,x            ; Screen page 4 (partial)
        lda #$03               ; Cyan frequency
        sta $db00,x            ; Color page 4 (partial)
        
        inx
        cpx #232               ; Stop at exactly 1000 total
        bne clear_final

;===============================================================================
; GRID IDENTIFICATION BROADCAST
;===============================================================================
        ; Display identification message
        ldx #0                 ; Message index
display_id:
        lda grid_message,x     ; Load character
        beq idle_loop          ; Zero = end of message
        sta $0400+12*40+10,x   ; Row 12, Column 10 (centered)
        inx
        jmp display_id         ; Next character

;===============================================================================
; TERMINAL IDLE LOOP
;===============================================================================
idle_loop:
        jmp idle_loop          ; Maintain terminal power

;===============================================================================
; DATA SECTION
;===============================================================================
grid_message:
        ; "GRID PROTOCOL ACTIVE" in screen codes
        !byte 7,18,9,4,32                    ; "GRID "
        !byte 16,18,15,20,15,3,15,12,32      ; "PROTOCOL "
        !byte 1,3,20,9,22,5                  ; "ACTIVE"
        !byte 0                               ; Terminator

;===============================================================================
; TECHNICAL NOTES
;===============================================================================
; Memory Layout:
; - $0801-$080C: Gateway protocol (BASIC stub)
; - $080D+: Grid operation code
; - $0400-$07E7: Screen matrix (exactly 1000 bytes)
; - $D800-$DBE7: Color matrix (exactly 1000 bytes)
; - $D020: Border control
; - $D021: Background control
;
; Screen Codes (not PETSCII):
; - A-Z: 1-26
; - 0-9: 48-57
; - Space: 32
;
; Grid Protocol Standards:
; - Cyan ($03): Normal operations
; - Red ($02): Contamination alert
; - Green ($05): Agricultural data
; - Yellow ($07): Power grid status