            even
step_sample:
            dc.b    $60,$40,$20,$10,$08,$04,$02,$01
            dc.b    $fe,$fc,$f8,$f0,$e0,$d0,$c0,$b0
            dc.b    $50,$30,$18,$0c,$06,$03,$01,$00
            dc.b    $ff,$fd,$fa,$f4,$e8,$d8,$c8,$b8
STEP_SAMPLE_LEN equ *-step_sample
