        ; Increment score (BCD)
        sed                     ; Decimal mode
        lda score
        clc
        adc #$01
        sta score
        cld                     ; Back to binary mode

        ; Update score display — tens digit
        lda score
        lsr
        lsr
        lsr
        lsr                     ; High nybble in A (0-9)
        clc
        adc #$30                ; Convert to screen code
        sta $0400               ; Write tens digit

        ; Update score display — ones digit
        lda score
        and #$0f                ; Low nybble in A (0-9)
        clc
        adc #$30                ; Convert to screen code
        sta $0401               ; Write ones digit
