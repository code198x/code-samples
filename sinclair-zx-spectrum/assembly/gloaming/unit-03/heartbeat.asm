; ============================================================================
; GLOAMING — Unit 3: The Heartbeat
; ============================================================================
; The square is built and the lamplighter stands in it (Units 1-2) — but the
; program only ran once and then idled. A game is not a picture; it is a thing
; that runs, frame after frame, forever. It needs a *loop*. And not just any
; loop: one locked to the screen, so the game runs at the same steady pace on
; every Spectrum, fast or slow.
;
; The Spectrum draws the screen 50 times a second, and each time it finishes
; it raises an *interrupt* — a tap on the shoulder, 50 times a second, exactly.
; We tell the Z80 to listen for it (`IM 1`, `EI`), and then a single `HALT`
; sleeps the processor until the next tap arrives. One HALT, one frame. Put
; that HALT at the top of a loop and the loop beats at 50 Hz — the heartbeat
; every later unit moves to.
;
; The program now has two parts:
;
;   SETUP (once): everything from Unit 2 — border, cobbles, walls, the
;   lamplighter — drawn a single time before the heartbeat starts.
;
;   THE LOOP (forever): HALT to wait for the frame, then the three stages a
;   game repeats every frame — read INPUT, UPDATE the world, DRAW it. They are
;   empty skeletons today (input arrives in Unit 4, movement in Unit 5); the
;   point of this unit is the beating loop they live in.
;
; On screen nothing changes — the same square, the same lamplighter, holding
; perfectly steady. That steadiness *is* the result: the program is now alive
; and paced, doing nothing yet, but ready to do everything.
; ============================================================================

            org     32768

; --- the cell vocabulary, as attribute bytes (from Unit 1) ---
COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black (0), INK white (7) — the figure

; --- where the lamplighter stands (from Unit 2) ---
LAMP_COL    equ     15
LAMP_ROW    equ     11
THIRD       equ     LAMP_ROW / 8
CHARROW     equ     LAMP_ROW - THIRD * 8
LAMP_SCR    equ     $4000 + THIRD * $0800 + CHARROW * 32 + LAMP_COL
LAMP_ATTR_ADDR equ  $5800 + LAMP_ROW * 32 + LAMP_COL

; ============================================================================
; SETUP — runs once, before the heartbeat starts.
; ============================================================================
start:
            ; --- the border goes black — the night beyond the square ---
            ld      a, 0
            out     ($FE), a

            ; --- wash the whole grid in cobbles ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ; --- draw the wall frame ---
            ld      hl, $5800       ; top row
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0       ; bottom row
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ld      hl, $5800       ; left and right columns
            ld      b, 24
.sides:
            ld      (hl), WALL
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), WALL
            pop     hl
            ld      de, 32
            add     hl, de
            djnz    .sides

            ; --- draw the lamplighter (his colour, then his shape) ---
            ld      hl, LAMP_ATTR_ADDR
            ld      (hl), LAMP_ATTR

            ld      hl, LAMP_SCR
            ld      de, lamplighter
            ld      b, 8
.draw:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h               ; next screen row down (+256)
            djnz    .draw

; ============================================================================
; THE HEARTBEAT — start the 50 Hz frame interrupt, then loop on it forever.
; ============================================================================
            ; `IM 1` selects the ROM's interrupt handler — the one fired once
            ; per screen, 50 times a second. `EI` lets the interrupts through.
            im      1
            ei

game_loop:
            halt                    ; sleep here until the next frame interrupt

            ; --- INPUT ---  read the keys.       (Unit 4 fills this in.)
            ; --- UPDATE --- move the world on.   (Unit 5 fills this in.)
            ; --- DRAW ---   redraw what changed.  (nothing moves yet.)

            jr      game_loop       ; round again — one pass per frame, forever

; ----------------------------------------------------------------------------
; The lamplighter's shape — eight bytes, one per pixel row (from Unit 2).
; ----------------------------------------------------------------------------
lamplighter:
            defb    %00111100       ; ..XXXX..   head
            defb    %00111100       ; ..XXXX..   head
            defb    %00011000       ; ...XX...   neck
            defb    %01111110       ; .XXXXXX.   arms
            defb    %00011000       ; ...XX...   body
            defb    %00011000       ; ...XX...   body
            defb    %00100100       ; ..X..X..   legs
            defb    %01000010       ; .X....X.   feet

            end     start
