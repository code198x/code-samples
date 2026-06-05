; Gloaming — Unit 3: The Heartbeat, made visible (an aside, not a step)
; The heartbeat is invisible by design — the screen holds steady. This variant
; writes a per-frame counter to the BORDER, so its colour steps once per beat:
; proof the loop really is running 50 times a second. The real game keeps a
; black border, so this is a demonstration, not part of the cumulative build.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black (0), INK white (7) — the figure

LAMP_COL    equ     15
LAMP_ROW    equ     11
THIRD       equ     LAMP_ROW / 8
CHARROW     equ     LAMP_ROW - THIRD * 8
LAMP_SCR    equ     $4000 + THIRD * $0800 + CHARROW * 32 + LAMP_COL
LAMP_ATTR_ADDR equ  $5800 + LAMP_ROW * 32 + LAMP_COL

start:
            ; --- the border starts black ---
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

            ; --- draw the lamplighter ---
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

            im      1
            ei

game_loop:
            halt                    ; wait one frame
            ld      a, (tick)
            inc     a
            ld      (tick), a
            out     ($FE), a        ; border steps to a new colour every frame
            jr      game_loop

tick:
            defb    0

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
