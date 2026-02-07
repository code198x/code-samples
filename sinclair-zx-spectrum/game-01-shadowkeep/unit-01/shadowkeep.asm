; ============================================================================
; SHADOWKEEP — Unit 1: A Coloured Block
; ============================================================================
; A maze explorer for the ZX Spectrum
; This unit: place coloured blocks on screen using attribute memory
;
; No keyboard, no movement — just colour on screen.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1 — solid blue block
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0 — white block
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow) — bright yellow
HAZARD      equ     $90             ; FLASH + PAPER 2 (red) — flashing red

; ----------------------------------------------------------------------------
; Entry point
; ----------------------------------------------------------------------------

start:
            ; Black border
            ld      a, 0
            out     ($fe), a

            ; Clear screen (bitmap + attributes)
            ; This fills $4000-$5AFF with zeros — black everywhere
            ld      hl, $4000
            ld      de, $4001
            ld      bc, 6911
            ld      (hl), 0
            ldir

            ; --- Draw the room ---

            ; Walls
            ld      a, WALL

            ; Top wall (row 10, cols 14-18)
            ld      ($594e), a      ; Row 10, col 14
            ld      ($594f), a      ; Row 10, col 15
            ld      ($5950), a      ; Row 10, col 16
            ld      ($5951), a      ; Row 10, col 17
            ld      ($5952), a      ; Row 10, col 18

            ; Side walls (rows 11-13)
            ld      ($596e), a      ; Row 11, col 14 (left)
            ld      ($5972), a      ; Row 11, col 18 (right)
            ld      ($598e), a      ; Row 12, col 14
            ld      ($5992), a      ; Row 12, col 18
            ld      ($59ae), a      ; Row 13, col 14
            ld      ($59b2), a      ; Row 13, col 18

            ; Bottom wall (row 14, cols 14-18)
            ld      ($59ce), a      ; Row 14, col 14
            ld      ($59cf), a      ; Row 14, col 15
            ld      ($59d0), a      ; Row 14, col 16
            ld      ($59d1), a      ; Row 14, col 17
            ld      ($59d2), a      ; Row 14, col 18

            ; Floor
            ld      a, FLOOR

            ; Row 11 floor (cols 15-17)
            ld      ($596f), a      ; Row 11, col 15
            ld      ($5970), a      ; Row 11, col 16
            ld      ($5971), a      ; Row 11, col 17

            ; Row 12 floor (cols 15, 17 — col 16 is treasure)
            ld      ($598f), a      ; Row 12, col 15
            ld      ($5991), a      ; Row 12, col 17

            ; Row 13 floor (cols 15-16 — col 17 is hazard)
            ld      ($59af), a      ; Row 13, col 15
            ld      ($59b0), a      ; Row 13, col 16

            ; Treasure — bright yellow (row 12, col 16)
            ld      a, TREASURE
            ld      ($5990), a

            ; Hazard — flashing red (row 13, col 17)
            ld      a, HAZARD
            ld      ($59b1), a

            ; --- Done ---

.loop:      halt
            jr      .loop

            end     start
