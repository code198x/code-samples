; Gloaming — Unit 4: Reading the Keys
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 reads one key — P — and recolours the figure green while it's held.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure at rest
RIGHT_ATTR  equ     %01000100       ; BRIGHT, INK green (4) — holding P

LAMP_COL    equ     15
LAMP_ROW    equ     11
THIRD       equ     LAMP_ROW / 8
CHARROW     equ     LAMP_ROW - THIRD * 8
LAMP_SCR    equ     $4000 + THIRD * $0800 + CHARROW * 32 + LAMP_COL
LAMP_ATTR_ADDR equ  $5800 + LAMP_ROW * 32 + LAMP_COL

; --- the keyboard half-row holding O and P ---
KEYS_OP     equ     $DFFE           ; high byte $DF selects this half-row

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

            ; --- top and bottom walls ---
            ld      hl, $5800
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ; --- left and right walls ---
            ld      hl, $5800
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

            ; --- draw the lamplighter (colour, then shape) ---
            ld      hl, LAMP_ATTR_ADDR
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

            ; --- start the 50 Hz heartbeat ---
            im      1
            ei

game_loop:
            halt                    ; wait for the next frame

            ; --- INPUT: read P and recolour the figure while it's held ---
            ld      bc, KEYS_OP     ; BC = $DFFE — the address IS the question
            in      a, (c)          ; bottom 5 bits = keys, 0 = held (active low)
            ld      d, LAMP_ATTR    ; assume nothing held → white at rest
            bit     0, a            ; P (right)?  Z set = bit is 0 = held
            jr      nz, .not_right
            ld      d, RIGHT_ATTR   ; green
.not_right:
            ld      a, d
            ld      (LAMP_ATTR_ADDR), a   ; one attribute write — his cell recolours

            jr      game_loop

; The lamplighter's shape — eight bytes, one per pixel row (from Unit 2).
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
