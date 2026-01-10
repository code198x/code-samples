; Ink War - Unit 02: The Attribute Grid
; Understanding the 32x24 cell grid and filling regions
;
; Learning objectives:
; - Understand the attribute grid layout (32 columns × 24 rows)
; - Calculate attribute addresses from row and column
; - Fill regions with colours
; - See BRIGHT colours in action

        org $8000           ; 32768 - our code starts here

; =============================================================================
; CONSTANTS
; =============================================================================

ATTR_START  equ $5800       ; Attribute memory starts here (768 bytes)
ATTR_SIZE   equ 768         ; 32 columns × 24 rows
ATTR_WIDTH  equ 32          ; Cells per row
BORDER_PORT equ $FE         ; Border colour port

; Colours (for attribute bytes)
BLACK       equ 0
BLUE        equ 1
RED         equ 2
MAGENTA     equ 3
GREEN       equ 4
CYAN        equ 5
YELLOW      equ 6
WHITE       equ 7

; Attribute bits
BRIGHT      equ %01000000   ; Bit 6 = bright
FLASH       equ %10000000   ; Bit 7 = flash

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        ; Set border to black
        ld a, BLACK
        out (BORDER_PORT), a

        ; First, clear the entire attribute area to white paper
        call clear_attributes

        ; Now demonstrate the checkerboard pattern
        call draw_checkerboard

        ; Fill some rows with different colours to show address calculation
        call fill_colour_bars

        ; Show BRIGHT vs normal colours
        call show_bright_demo

forever:
        jr forever

; =============================================================================
; SUBROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Clear all attribute memory to white paper, black ink
; Uses LDIR for fast block copy
; -----------------------------------------------------------------------------
clear_attributes:
        ld hl, ATTR_START   ; Source address
        ld de, ATTR_START+1 ; Destination (one byte ahead)
        ld bc, ATTR_SIZE-1  ; Number of bytes to copy (767)
        ld (hl), %00111000  ; White paper, black ink
        ldir                ; Copy: (DE) <- (HL), repeat BC times
        ret

; -----------------------------------------------------------------------------
; Draw a checkerboard pattern in the centre of the screen
; 8x8 grid starting at row 8, column 12
; -----------------------------------------------------------------------------
draw_checkerboard:
        ; Calculate start address: $5800 + (row × 32) + column
        ; Row 8: 8 × 32 = 256 = $100
        ; Column 12: + 12 = $10C
        ; Start: $5800 + $10C = $590C

        ld hl, ATTR_START + (8 * ATTR_WIDTH) + 12   ; Row 8, Column 12
        ld d, 0             ; Row counter (0-7)

checker_row:
        ld e, 0             ; Column counter (0-7)

checker_col:
        ; Alternate colours using XOR of row and column
        ; If (row XOR col) is odd, use red; else use blue
        ld a, d             ; Get row
        xor e               ; XOR with column
        and 1               ; Check bit 0
        jr z, checker_blue
        ld a, %00010000     ; Red paper, black ink
        jr checker_store
checker_blue:
        ld a, %00001000     ; Blue paper, black ink

checker_store:
        ld (hl), a          ; Write attribute
        inc hl              ; Next column
        inc e               ; Increment column counter
        ld a, e
        cp 8                ; Done 8 columns?
        jr nz, checker_col

        ; Move to next row: add (32 - 8) = 24 to get to next row start
        ld bc, ATTR_WIDTH - 8  ; 24 bytes to skip
        add hl, bc          ; Move to next row

        inc d               ; Next row
        ld a, d
        cp 8                ; Done 8 rows?
        jr nz, checker_row

        ret

; -----------------------------------------------------------------------------
; Fill rows with different colours to demonstrate address calculation
; Rows 0-2: coloured bands
; -----------------------------------------------------------------------------
fill_colour_bars:
        ; Row 0: Red band (address = $5800)
        ld hl, ATTR_START
        ld b, ATTR_WIDTH    ; 32 columns
        ld a, %00010000     ; Red paper
row0_loop:
        ld (hl), a
        inc hl
        djnz row0_loop

        ; Row 1: Green band (address = $5800 + 32 = $5820)
        ld hl, ATTR_START + ATTR_WIDTH
        ld b, ATTR_WIDTH
        ld a, %00100000     ; Green paper
row1_loop:
        ld (hl), a
        inc hl
        djnz row1_loop

        ; Row 2: Blue band (address = $5800 + 64 = $5840)
        ld hl, ATTR_START + (2 * ATTR_WIDTH)
        ld b, ATTR_WIDTH
        ld a, %00001000     ; Blue paper
row2_loop:
        ld (hl), a
        inc hl
        djnz row2_loop

        ret

; -----------------------------------------------------------------------------
; Demonstrate BRIGHT vs normal colours
; Row 20: normal colours, Row 21: bright colours
; -----------------------------------------------------------------------------
show_bright_demo:
        ; Row 20: Normal colours (address = $5800 + 20×32 = $5A80)
        ld hl, ATTR_START + (20 * ATTR_WIDTH)
        ld b, 8             ; Show 8 colours
        ld c, 0             ; Colour counter
normal_loop:
        ; Create paper colour from counter
        ld a, c
        add a, a            ; Shift left
        add a, a            ; Shift left
        add a, a            ; Now colour is in bits 5-3
        ld (hl), a          ; Write attribute
        inc hl
        inc c
        djnz normal_loop

        ; Row 21: Same colours but BRIGHT (address = $5800 + 21×32 = $5AA0)
        ld hl, ATTR_START + (21 * ATTR_WIDTH)
        ld b, 8             ; Show 8 colours
        ld c, 0             ; Colour counter
bright_loop:
        ; Create paper colour from counter + BRIGHT bit
        ld a, c
        add a, a            ; Shift left
        add a, a            ; Shift left
        add a, a            ; Now colour is in bits 5-3
        or BRIGHT           ; Add bright bit
        ld (hl), a          ; Write attribute
        inc hl
        inc c
        djnz bright_loop

        ret

        end start
