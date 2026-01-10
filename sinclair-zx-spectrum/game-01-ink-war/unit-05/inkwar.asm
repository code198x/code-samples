; Ink War - Unit 05: Keyboard Input
; Read the keyboard and respond to key presses
;
; Learning objectives:
; - Understand the Spectrum keyboard matrix
; - Read specific keys (Q, A, O, P, Space)
; - Detect new key presses (debouncing)
; - Provide visual feedback

        org $8000

; =============================================================================
; CONSTANTS
; =============================================================================

; Ports
BORDER_PORT equ $FE
KEYBOARD_PORT equ $FE       ; Same port, different usage

; Keyboard half-rows (active low - 0 = pressed)
; The high byte of the port address selects the half-row
ROW_CAPS_V  equ $FE         ; CAPS SHIFT, Z, X, C, V
ROW_A_G     equ $FD         ; A, S, D, F, G
ROW_Q_T     equ $FB         ; Q, W, E, R, T
ROW_1_5     equ $F7         ; 1, 2, 3, 4, 5
ROW_0_6     equ $EF         ; 0, 9, 8, 7, 6
ROW_P_Y     equ $DF         ; P, O, I, U, Y
ROW_ENT_H   equ $BF         ; ENTER, L, K, J, H
ROW_SPC_B   equ $7F         ; SPACE, SYM SHIFT, M, N, B

; Bit positions within each half-row (active low)
BIT_0       equ %00000001   ; Rightmost key in half-row
BIT_1       equ %00000010
BIT_2       equ %00000100
BIT_3       equ %00001000
BIT_4       equ %00010000   ; Leftmost key in half-row

; Our control keys:
; Q (up)    = ROW_Q_T, bit 0
; A (down)  = ROW_A_G, bit 0
; O (left)  = ROW_P_Y, bit 1
; P (right) = ROW_P_Y, bit 0
; Space     = ROW_SPC_B, bit 0

; Colours for border feedback
BLACK       equ 0
BLUE        equ 1
RED         equ 2
MAGENTA     equ 3
GREEN       equ 4
CYAN        equ 5
YELLOW      equ 6
WHITE       equ 7

; =============================================================================
; VARIABLES
; =============================================================================

prev_keys:  defb 0          ; Previous key state for debouncing

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        ; Set initial border colour
        ld a, BLACK
        out (BORDER_PORT), a

        ; Clear previous key state
        xor a
        ld (prev_keys), a

main_loop:
        ; Wait for vertical blank (simple timing)
        halt

        ; Read keyboard and respond
        call read_keys

        jr main_loop

; =============================================================================
; SUBROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Read keyboard and flash border for each key pressed
; Uses debouncing to detect new presses only
; -----------------------------------------------------------------------------
read_keys:
        ; Read all our control keys into a single byte
        ; Bit 0 = Q (up)
        ; Bit 1 = A (down)
        ; Bit 2 = O (left)
        ; Bit 3 = P (right)
        ; Bit 4 = Space (action)

        ld e, 0             ; Build key state in E

        ; Check Q (up)
        ld a, ROW_Q_T       ; Select Q-T row
        in a, (KEYBOARD_PORT)
        bit 0, a            ; Test Q key
        jr nz, not_q        ; Jump if NOT pressed (active low)
        set 0, e            ; Set bit 0 in our key state
not_q:

        ; Check A (down)
        ld a, ROW_A_G
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_a
        set 1, e
not_a:

        ; Check O (left)
        ld a, ROW_P_Y
        in a, (KEYBOARD_PORT)
        bit 1, a
        jr nz, not_o
        set 2, e
not_o:

        ; Check P (right)
        ld a, ROW_P_Y
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_p
        set 3, e
not_p:

        ; Check Space (action)
        ld a, ROW_SPC_B
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_space
        set 4, e
not_space:

        ; E now contains current key state
        ; Compare with previous to find NEW presses

        ld a, (prev_keys)   ; Get previous state
        cpl                 ; Invert it
        and e               ; AND with current = newly pressed keys
        ld d, a             ; D = newly pressed keys

        ; Save current state for next frame
        ld a, e
        ld (prev_keys), a

        ; Now respond to newly pressed keys (in D)
        ; Flash border different colours for each key

        bit 0, d            ; Q pressed?
        jr z, no_q_press
        ld a, RED
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_q_press:

        bit 1, d            ; A pressed?
        jr z, no_a_press
        ld a, GREEN
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_a_press:

        bit 2, d            ; O pressed?
        jr z, no_o_press
        ld a, CYAN
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_o_press:

        bit 3, d            ; P pressed?
        jr z, no_p_press
        ld a, YELLOW
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_p_press:

        bit 4, d            ; Space pressed?
        jr z, no_spc_press
        ld a, WHITE
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_spc_press:

        ret

; -----------------------------------------------------------------------------
; Short delay for visible flash
; -----------------------------------------------------------------------------
short_delay:
        ld bc, $1000        ; Delay counter
delay_loop:
        dec bc
        ld a, b
        or c
        jr nz, delay_loop
        ret

        end start
