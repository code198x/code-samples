check_keyboard:
        ; SPACE = claim (check first)
        call check_space_edge
        jr nz, .not_space
        call claim_cell
        ret
.not_space:

        ; Q = up
        ; ... rest of movement checks ...
