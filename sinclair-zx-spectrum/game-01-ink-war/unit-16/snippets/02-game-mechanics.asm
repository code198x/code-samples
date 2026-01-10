; Core game mechanics summary
;
; BOARD: 8x8 grid using ZX Spectrum attributes
; Each cell is one attribute byte at $5800-$5AFF

BOARD_SIZE  equ 8
ATTR_START  equ $5800

; PLAYERS: Track ownership and scores
EMPTY   equ 0
PLAYER1 equ 1               ; Red
PLAYER2 equ 2               ; Cyan (Blue)

board_state: defs 64, 0     ; Who owns each cell
p1_score:    defb 0         ; Cells owned by P1
p2_score:    defb 0         ; Cells owned by P2

; CLAIMING: Check empty, update state and display
check_claim:
        ; If cell empty, claim it
        call get_board_state_address
        ld a, (hl)
        or a
        jr nz, invalid_move
        call valid_move
        ret

; TURNS: Alternate between players
switch_player:
        ld a, (current_player)
        ld b, a
        ld a, 3
        sub b               ; 3-1=2, 3-2=1
        ld (current_player), a
        ret

; WINNING: Check when board is full
check_game_end:
        ; Count empty cells
        ; If zero, transition to results
        ret
