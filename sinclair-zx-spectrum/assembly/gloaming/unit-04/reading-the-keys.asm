; ============================================================================
; GLOAMING — Unit 4: Reading the Keys
; ============================================================================
; The heartbeat beats (Unit 3), but the loop's INPUT stage is empty — the
; lamplighter can't feel you. This unit fills it in: every frame, we ask the
; keyboard whether a direction key is held, and prove the machine heard us by
; recolouring the figure on the spot. Red when you hold O (left), green when
; you hold P (right), pale white when you hold nothing. He doesn't move yet —
; that's Unit 5 — but he *reacts*, fifty times a second.
;
; The Spectrum reads its keyboard through one port, $FE. The keys are wired
; into eight "half-rows" of five keys each, and which half-row you read is
; chosen by the HIGH byte of the port address. We want O and P, which both
; live in the half-row selected by high byte $DF — so we read port $DFFE.
;
; The reply is one byte, and the five keys are its bottom five bits — but
; ACTIVE LOW: a bit reads 0 while its key is held, 1 while it's up. (The
; hardware pulls the line down when you press; "pressed" is the absence of the
; usual 1.) So we test for a *zero* bit to find a held key.
;
; Half-row $DFFE, bottom five bits:   bit0=P  bit1=O  bit2=I  bit3=U  bit4=Y
;
; We read it with `IN A,(C)` (BC on the address bus = the full port $DFFE),
; then `BIT n,A` each key's bit and recolour to match.
; ============================================================================

            org     32768

; --- the cell vocabulary, as attribute bytes (from Unit 1) ---
COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure at rest

; feedback colours — bright INK on black PAPER (this unit only; Unit 5 replaces
; "recolour" with real movement)
LEFT_ATTR   equ     %01000010       ; BRIGHT, INK red (2)   — holding O
RIGHT_ATTR  equ     %01000100       ; BRIGHT, INK green (4) — holding P

; --- where the lamplighter stands (from Unit 2) ---
LAMP_COL    equ     15
LAMP_ROW    equ     11
THIRD       equ     LAMP_ROW / 8
CHARROW     equ     LAMP_ROW - THIRD * 8
LAMP_SCR    equ     $4000 + THIRD * $0800 + CHARROW * 32 + LAMP_COL
LAMP_ATTR_ADDR equ  $5800 + LAMP_ROW * 32 + LAMP_COL

; --- the keyboard half-row holding O and P ---
KEYS_OP     equ     $DFFE           ; high byte $DF selects this half-row

; ============================================================================
; SETUP — runs once, before the heartbeat starts.
; ============================================================================
start:
            ld      a, 0            ; border black — the night beyond the square
            out     ($FE), a

            ld      hl, $5800       ; wash the grid in cobbles
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ld      hl, $5800       ; wall frame — top row
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

            ld      hl, LAMP_ATTR_ADDR   ; the lamplighter — colour, then shape
            ld      (hl), LAMP_ATTR

            ld      hl, LAMP_SCR
            ld      de, lamplighter
            ld      b, 8
.draw:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw

; ============================================================================
; THE HEARTBEAT — 50 Hz loop (Unit 3), with the INPUT stage now filled in.
; ============================================================================
            im      1
            ei

game_loop:
            halt                    ; wait for the next frame

            ; --- INPUT: read O/P and recolour the figure to show what's held ---
            ld      bc, KEYS_OP     ; BC = $DFFE — the address IS the question
            in      a, (c)          ; bottom 5 bits = keys, 0 = held
            ld      d, LAMP_ATTR    ; assume nothing held → white at rest
            bit     1, a            ; O (left)?  Z set = bit is 0 = held
            jr      nz, .not_left
            ld      d, LEFT_ATTR    ; red
.not_left:
            bit     0, a            ; P (right)?
            jr      nz, .not_right
            ld      d, RIGHT_ATTR   ; green
.not_right:
            ld      a, d
            ld      (LAMP_ATTR_ADDR), a   ; one attribute write — his cell recolours

            ; --- UPDATE --- move the world on.   (Unit 5 fills this in.)
            ; --- DRAW ---   his shape is already drawn; only the colour changed.

            jr      game_loop

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
