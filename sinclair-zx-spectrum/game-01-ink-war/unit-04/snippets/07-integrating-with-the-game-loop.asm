check_keyboard:
        ; ... existing Q/A/O/P checks ...

        ; SPACE = claim
        call check_space_edge
        jr nz, .no_claim
        call claim_cell
.no_claim:

        ret
