; Time bonus calculation when reaching home
; Called from check_home after marking home as filled

            ; Time bonus: remaining seconds * 2 points
            move.w  timer(pc),d0
            ext.l   d0
            divu    #50,d0              ; Convert frames to seconds
            and.l   #$ffff,d0           ; Keep only quotient (mask off remainder)
            add.l   d0,d0               ; *2 for bonus
            add.l   d0,score            ; Add time bonus

; If player reaches home with 30 seconds remaining:
; 30 * 2 = 60 bonus points added to score
