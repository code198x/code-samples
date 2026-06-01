; ============================================================================
; PRIMER — Beat 11: Call, Return, and a Stack You Can See
; ============================================================================
; When a job is worth a name, package it into a SUBROUTINE:
;
;   call fill_row  -- jump to fill_row, but REMEMBER where we came from
;   ret            -- go back to wherever the matching call was
;
; That's BASIC's GOSUB / RETURN -- except you can see how it works. CALL
; pushes the return address onto the STACK (real memory, pointed at by SP);
; RET pops it back off. Open the memory view at SP and you can watch the
; address go on and come off.
;
; We write fill_row ONCE, then call it twice -- different row, different
; colour each time. One definition, two uses.
; ============================================================================

            org     32768

start:
            ld      hl, $5800        ; row 0 (top)
            ld      a, $17           ; red   (PAPER 2, INK 7)
            call    fill_row         ; paint row 0 red

            ld      hl, $5820        ; row 1 (one cell-row down, +32)
            ld      a, $0F           ; blue  (PAPER 1, INK 7)
            call    fill_row         ; paint row 1 blue

.loop:
            halt
            jr      .loop

; --- fill_row: colour 32 cells from HL with the attribute in A -------------
fill_row:
            ld      b, 32            ; 32 cells in a row
.fr:
            ld      (hl), a          ; colour the cell with A
            inc     hl               ; step along
            djnz    .fr              ; ...32 times
            ret                      ; back to whoever called us

            end     start
