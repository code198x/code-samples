; ============================================================================
; SHADOWKEEP — Unit 2: Reading Colour
; ============================================================================
; Draws the room from Unit 1, then modifies cells using AND and OR.
;
; AND extracts or clears bits. OR sets bits.
; Together they let you read, check, and change any part of an attribute.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow)
HAZARD      equ     $90             ; FLASH + PAPER 2 (red)

; ----------------------------------------------------------------------------
; Entry point
; ----------------------------------------------------------------------------

start:
            ; Black border
            ld      a, 0
            out     ($fe), a

            ; Clear screen (bitmap + attributes)
            ld      hl, $4000
            ld      de, $4001
            ld      bc, 6911
            ld      (hl), 0
            ldir

            ; ==================================================================
            ; Draw the room (same as Unit 1)
            ; ==================================================================

            ; Walls
            ld      a, WALL

            ; Top wall (row 10, cols 14-18)
            ld      ($594e), a
            ld      ($594f), a
            ld      ($5950), a
            ld      ($5951), a
            ld      ($5952), a

            ; Side walls (rows 11-13)
            ld      ($596e), a
            ld      ($5972), a
            ld      ($598e), a
            ld      ($5992), a
            ld      ($59ae), a
            ld      ($59b2), a

            ; Bottom wall (row 14, cols 14-18)
            ld      ($59ce), a
            ld      ($59cf), a
            ld      ($59d0), a
            ld      ($59d1), a
            ld      ($59d2), a

            ; Floor
            ld      a, FLOOR

            ld      ($596f), a
            ld      ($5970), a
            ld      ($5971), a
            ld      ($598f), a
            ld      ($5991), a
            ld      ($59af), a
            ld      ($59b0), a

            ; Treasure
            ld      a, TREASURE
            ld      ($5990), a

            ; Hazard
            ld      a, HAZARD
            ld      ($59b1), a

            ; ==================================================================
            ; Unit 2: Modify cells with AND and OR
            ; ==================================================================

            ; --- OR to set BRIGHT on floor cells ---
            ; Read each cell, set bit 6, write back

            ld      a, ($596f)      ; Row 11, col 15 (floor)
            or      $40             ; Set BRIGHT
            ld      ($596f), a

            ld      a, ($5970)      ; Row 11, col 16
            or      $40
            ld      ($5970), a

            ld      a, ($5971)      ; Row 11, col 17
            or      $40
            ld      ($5971), a

            ; --- OR to add FLASH to treasure ---
            ; It's already BRIGHT ($70) — adding FLASH makes it $F0

            ld      a, ($5990)      ; Row 12, col 16 (treasure)
            or      $80             ; Set FLASH
            ld      ($5990), a      ; Now BRIGHT + FLASH yellow

            ; --- AND to remove FLASH from hazard ---
            ; It was $90 (FLASH + red) — removing FLASH leaves $10 (static red)

            ld      a, ($59b1)      ; Row 13, col 17 (hazard)
            and     $7f             ; Clear FLASH (bit 7)
            ld      ($59b1), a      ; Now just red — defused

            ; --- AND + OR to change wall colour ---
            ; Change one wall from blue to red (a hidden passage?)

            ld      a, ($5951)      ; Row 10, col 17 (top wall)
            and     $c0             ; Clear PAPER and INK, keep FLASH/BRIGHT
            or      $12             ; PAPER 2 (red) + INK 2 (red)
            ld      ($5951), a      ; Wall is now red

            ; --- Done ---

.loop:      halt
            jr      .loop

            end     start
