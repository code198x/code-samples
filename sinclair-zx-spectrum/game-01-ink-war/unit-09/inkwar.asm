; Ink War - Unit 09: Move Validation
; Enhanced validation with audio feedback
;
; Learning objectives:
; - Robust move validation
; - Audio feedback using the beeper
; - Clear feedback for valid vs invalid moves
; - Defensive programming patterns

        org $8000

; =============================================================================
; CONSTANTS
; =============================================================================

ATTR_START  equ $5800
ATTR_WIDTH  equ 32
ATTR_SIZE   equ 768

BOARD_SIZE  equ 8
BOARD_TOP   equ 8
BOARD_LEFT  equ 12
BORDER_TOP  equ 7
BORDER_LEFT equ 11
BORDER_SIZE equ 10

BORDER_PORT equ $FE
KEYBOARD_PORT equ $FE

ROW_A_G     equ $FD
ROW_Q_T     equ $FB
ROW_P_Y     equ $DF
ROW_SPC_B   equ $7F

EMPTY       equ 0
PLAYER1     equ 1
PLAYER2     equ 2

BLACK_ATTR  equ %00000000
WHITE_ATTR  equ %00111111
EMPTY_ATTR  equ %00111000
P1_ATTR     equ %01010000
P2_ATTR     equ %01001000

INDICATOR_ROW equ 2
INDICATOR_COL equ 12

; =============================================================================
; VARIABLES
; =============================================================================

cursor_row:     defb 0
cursor_col:     defb 0
prev_keys:      defb 0
current_player: defb PLAYER1

board_state:    defs 64, 0

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        xor a
        out (BORDER_PORT), a

        call clear_screen
        call draw_border
        call draw_board
        call draw_turn_indicator

        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a
        call draw_cursor

main_loop:
        halt
        call read_keys
        call move_cursor
        call check_claim
        jr main_loop

; =============================================================================
; MOVE VALIDATION
; =============================================================================

; -----------------------------------------------------------------------------
; Check if Space was pressed and validate the claim
; -----------------------------------------------------------------------------
check_claim:
        bit 4, d
        ret z

        ; Get board state for current cell
        call get_board_state_address  ; HL = address in board_state
        ld a, (hl)

        ; Validate: is the cell empty?
        or a
        jr nz, invalid_move

        ; Valid move - claim the cell
        call valid_move
        ret

invalid_move:
        ; Cell is occupied - provide clear feedback
        call play_error_sound

        ; Flash border red briefly
        ld a, 2             ; Red
        out (BORDER_PORT), a
        call short_delay
        call short_delay    ; Extra delay for emphasis
        xor a
        out (BORDER_PORT), a

        ; Turn does NOT change
        ret

valid_move:
        ; Claim the cell
        call get_board_state_address
        ld a, (current_player)
        ld (hl), a

        ; Update display
        call update_cell_display

        ; Success feedback
        call play_success_sound

        ld a, 4             ; Green
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a

        ; Switch turns
        call switch_player
        ret

; -----------------------------------------------------------------------------
; Get address in board_state array for current cursor position
; Output: HL = address in board_state
; -----------------------------------------------------------------------------
get_board_state_address:
        ld a, (cursor_row)
        add a, a
        add a, a
        add a, a            ; ×8
        ld hl, board_state
        ld e, a
        ld d, 0
        add hl, de
        ld a, (cursor_col)
        ld e, a
        ld d, 0
        add hl, de
        ret

; =============================================================================
; SOUND ROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Play a pleasant tone for successful claim
; Rising pitch, short duration
; -----------------------------------------------------------------------------
play_success_sound:
        ld hl, 200          ; Starting pitch (lower = higher pitch)
        ld b, 3             ; Number of notes

success_loop:
        push bc
        push hl

        ld de, 150          ; Duration
        call beep

        pop hl
        ld bc, 30
        or a
        sbc hl, bc          ; Increase pitch (lower number)
        pop bc
        djnz success_loop
        ret

; -----------------------------------------------------------------------------
; Play a harsh buzz for invalid move
; Low, rough sound
; -----------------------------------------------------------------------------
play_error_sound:
        ld hl, 800          ; Low pitch
        ld de, 300          ; Longer duration
        call beep
        ret

; -----------------------------------------------------------------------------
; Generate a beep through the speaker
; Input: HL = pitch (lower = higher frequency), DE = duration
; -----------------------------------------------------------------------------
beep:
        ; Toggle speaker bit and wait
beep_loop:
        ld a, 16            ; Speaker bit
        out (BORDER_PORT), a
        ld b, l             ; Pitch delay
pitch_high:
        djnz pitch_high

        xor a               ; Speaker off
        out (BORDER_PORT), a
        ld b, l
pitch_low:
        djnz pitch_low

        dec de
        ld a, d
        or e
        jr nz, beep_loop
        ret

; =============================================================================
; TURN SYSTEM
; =============================================================================

switch_player:
        ld a, (current_player)
        ld b, a
        ld a, 3
        sub b
        ld (current_player), a
        call draw_turn_indicator
        call draw_cursor
        ret

draw_turn_indicator:
        ld hl, ATTR_START + (INDICATOR_ROW * ATTR_WIDTH) + INDICATOR_COL
        ld b, 8
        ld a, BLACK_ATTR
clear_ind:
        ld (hl), a
        inc hl
        djnz clear_ind

        ld hl, ATTR_START + (INDICATOR_ROW * ATTR_WIDTH) + INDICATOR_COL
        ld a, (current_player)
        cp PLAYER1
        jr nz, ind_p2
        ld a, P1_ATTR
        jr draw_ind
ind_p2:
        ld a, P2_ATTR
draw_ind:
        ld b, 8
ind_loop:
        ld (hl), a
        inc hl
        djnz ind_loop
        ret

; =============================================================================
; DISPLAY ROUTINES
; =============================================================================

update_cell_display:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address
        ld a, (current_player)
        cp PLAYER1
        jr nz, disp_p2
        ld a, P1_ATTR
        jr disp_done
disp_p2:
        ld a, P2_ATTR
disp_done:
        ld (hl), a
        ret

; =============================================================================
; CURSOR ROUTINES
; =============================================================================

draw_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address
        push hl
        call get_board_state
        pop hl
        or a
        jr z, cursor_empty
        ld a, (hl)
        or %10000000
        ld (hl), a
        ret
cursor_empty:
        ld a, (current_player)
        cp PLAYER1
        jr nz, cursor_p2
        ld a, P1_ATTR
        jr cursor_flash
cursor_p2:
        ld a, P2_ATTR
cursor_flash:
        or %10000000
        ld (hl), a
        ret

erase_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address
        push hl
        call get_board_state
        pop hl
        or a
        jr nz, erase_claimed
        ld a, EMPTY_ATTR
        jr erase_done
erase_claimed:
        cp PLAYER1
        jr nz, erase_p2
        ld a, P1_ATTR
        jr erase_done
erase_p2:
        ld a, P2_ATTR
erase_done:
        ld (hl), a
        ret

get_board_state:
        ld a, (cursor_row)
        add a, a
        add a, a
        add a, a
        ld hl, board_state
        ld e, a
        ld d, 0
        add hl, de
        ld a, (cursor_col)
        ld e, a
        ld d, 0
        add hl, de
        ld a, (hl)
        ret

get_cell_address:
        ld a, BOARD_TOP
        add a, b
        ld l, a
        ld h, 0
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        ld a, BOARD_LEFT
        add a, c
        ld e, a
        ld d, 0
        add hl, de
        ld de, ATTR_START
        add hl, de
        ret

; =============================================================================
; INPUT ROUTINES
; =============================================================================

read_keys:
        ld e, 0
        ld a, ROW_Q_T
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_q
        set 0, e
not_q:
        ld a, ROW_A_G
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_a
        set 1, e
not_a:
        ld a, ROW_P_Y
        in a, (KEYBOARD_PORT)
        bit 1, a
        jr nz, not_o
        set 2, e
not_o:
        bit 0, a
        jr nz, not_p
        set 3, e
not_p:
        ld a, ROW_SPC_B
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_space
        set 4, e
not_space:
        ld a, (prev_keys)
        cpl
        and e
        ld d, a
        ld a, e
        ld (prev_keys), a
        ret

move_cursor:
        ld a, d
        and %00001111
        ret z
        call erase_cursor
        bit 0, d
        jr z, not_up
        ld a, (cursor_row)
        or a
        jr z, not_up
        dec a
        ld (cursor_row), a
not_up:
        bit 1, d
        jr z, not_down
        ld a, (cursor_row)
        cp BOARD_SIZE - 1
        jr z, not_down
        inc a
        ld (cursor_row), a
not_down:
        bit 2, d
        jr z, not_left
        ld a, (cursor_col)
        or a
        jr z, not_left
        dec a
        ld (cursor_col), a
not_left:
        bit 3, d
        jr z, not_right
        ld a, (cursor_col)
        cp BOARD_SIZE - 1
        jr z, not_right
        inc a
        ld (cursor_col), a
not_right:
        call draw_cursor
        ret

; =============================================================================
; UTILITY ROUTINES
; =============================================================================

short_delay:
        ld bc, $0800
delay_loop:
        dec bc
        ld a, b
        or c
        jr nz, delay_loop
        ret

clear_screen:
        ld hl, ATTR_START
        ld de, ATTR_START + 1
        ld bc, ATTR_SIZE - 1
        ld (hl), BLACK_ATTR
        ldir
        ret

draw_border:
        ld a, WHITE_ATTR
        ld hl, ATTR_START + (BORDER_TOP * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
border_top:
        ld (hl), a
        inc hl
        djnz border_top
        ld hl, ATTR_START + ((BORDER_TOP + BORDER_SIZE - 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
border_bottom:
        ld (hl), a
        inc hl
        djnz border_bottom
        ld hl, ATTR_START + ((BORDER_TOP + 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE - 2
border_sides:
        push bc
        push hl
        ld (hl), a
        ld de, BORDER_SIZE - 1
        add hl, de
        ld (hl), a
        pop hl
        ld de, ATTR_WIDTH
        add hl, de
        pop bc
        djnz border_sides
        ret

draw_board:
        ld hl, ATTR_START + (BOARD_TOP * ATTR_WIDTH) + BOARD_LEFT
        ld c, BOARD_SIZE
draw_board_row:
        push hl
        ld b, BOARD_SIZE
        ld a, EMPTY_ATTR
draw_board_col:
        ld (hl), a
        inc hl
        djnz draw_board_col
        pop hl
        ld de, ATTR_WIDTH
        add hl, de
        dec c
        jr nz, draw_board_row
        ret

        end start
