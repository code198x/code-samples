; High score entry structure
HS_SCORE        equ     0       ; Score (4 bytes, long word)
HS_NAME         equ     4       ; Name (3 bytes + padding)
HS_SIZE         equ     8       ; Total size per entry

NUM_SCORES      equ     5       ; Top 5 scores

; High score table (in data section with defaults)
high_scores:
            dc.l    5000        ; Score 1
            dc.b    "AAA",0     ; Name 1
            dc.l    4000        ; Score 2
            dc.b    "BBB",0     ; Name 2
            dc.l    3000        ; Score 3
            dc.b    "CCC",0     ; Name 3
            dc.l    2000        ; Score 4
            dc.b    "DDD",0     ; Name 4
            dc.l    1000        ; Score 5
            dc.b    "EEE",0     ; Name 5
