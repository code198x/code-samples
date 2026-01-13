            ; Empty cell - count adjacent AI cells (offense)
            push    bc
            ld      a, c
            call    count_adjacent_ai
            ld      b, a                ; B = AI adjacent count

            ; Count adjacent human cells (defense)
            ld      a, c
            call    count_adjacent_p1
            add     a, b                ; A = adjacency score
            ld      b, a                ; B = adjacency score

            ; Add position bonus (corners=2, edges=1)
            ld      a, c
            call    get_position_bonus
            add     a, b                ; A = total score
            pop     bc

            ; Total score = AI adjacent + P1 adjacent + position bonus
            ; Example: corner with 1 AI neighbor and 1 P1 neighbor = 1+1+2 = 4
            ; Example: center with 2 AI neighbors = 2+0+0 = 2
