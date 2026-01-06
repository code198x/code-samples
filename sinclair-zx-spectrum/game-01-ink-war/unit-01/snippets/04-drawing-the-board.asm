; Draw the game board LAST (direct to attribute memory)
            call draw_board

            ; Infinite loop - we're done
.hang:
            halt
            jr .hang
