; new_press = buttons AND (NOT buttons_prev)
lda buttons_prev
eor #$FF            ; invert: 0s become 1s
and buttons         ; bits set only if down NOW and NOT before
