;───────────────────────────────────────
; Count territories for each player
; Output: p1_count and p2_count updated
;───────────────────────────────────────
count_territories:
        ; Reset counts
        xor a
        ld (p1_count), a
        ld (p2_count), a

        ; Scan all 64 cells
        ld hl, board_state
        ld b, 64

.count_loop:
        ld a, (hl)
        cp 1
        jr nz, .not_p1
        ; Player 1 owns this cell
        ld a, (p1_count)
        inc a
        ld (p1_count), a
        jr .next

.not_p1:
        cp 2
        jr nz, .next
        ; Player 2 (AI) owns this cell
        ld a, (p2_count)
        inc a
        ld (p2_count), a

.next:
        inc hl
        djnz .count_loop
        ret

p1_count:       defb 0
p2_count:       defb 0
