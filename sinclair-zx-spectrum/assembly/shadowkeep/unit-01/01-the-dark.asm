; ============================================================================
; SHADOWKEEP — Unit 1, Stage 1: The Dark
; ============================================================================
; The keep is dark. Magic has gone wrong; the lights are out. Before any
; single cell of meaning, we set the world.
;
; Two acts:
;
;   1. The BORDER — the edge of the screen, outside the playable area — goes
;      black. One port write does it. We meet OUT for the first time.
;
;   2. The 768 attribute cells of the playable area are washed in dark blue
;      stone — the keep's foundation colour. One LDIR cascade does it. We
;      meet the Z80's block-fill idiom.
;
; After this stage runs, the screen is uniformly dark. No torches yet.
; The keep awaits.
; ============================================================================

            org     32768

start:
            ; --- the BORDER goes black ---
            ; Port $FE bits 0-2 control the BORDER colour (0-7).
            ; Loading A with 0 and writing it to port $FE selects black.
            ld      a, 0
            out     ($FE), a

            ; --- attribute memory washed in dark stone ---
            ; PAPER 1 (blue) on INK 0 (black) = $08. Writing this to
            ; every one of the 768 attribute bytes turns the entire screen
            ; into solid dark blue stone.
            ;
            ; The LDIR cascade: HL points at the source, DE at the
            ; destination, BC holds the count. The trick is DE = HL + 1
            ; and the first byte at HL is already set — LDIR then copies
            ; (HL) -> (DE), increments both pointers, decrements BC, and
            ; repeats until BC = 0. The single byte at $5800 propagates
            ; forward through every cell.
            ld      hl, $5800       ; source: first attribute cell
            ld      de, $5801       ; destination: one cell forward
            ld      (hl), $08       ; seed the cascade
            ld      bc, 767         ; remaining cells to fill
            ldir                    ; one instruction, 767 copies

; ----------------------------------------------------------------------------
; Idle loop — wait for frames, never exit.
; ----------------------------------------------------------------------------

.loop:
            halt
            jr      .loop

            end     start
