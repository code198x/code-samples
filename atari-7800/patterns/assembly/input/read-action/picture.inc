; MARIA direct four-byte object header in RAM; width is one byte.
; DLL uses the same object in sixteen zones. Graphics data spans sixteen pages
; because each zone offset is added to the graphics address high byte.
init_picture:
    lda #0
    sta $1905
    sta $20
    sta $1944
    sta $1945
    lda #14
    sta $23
    lda #<graphics
    sta $1940
    lda #$1f
    sta $1941
    lda #>graphics
    sta $1942
    lda #72
    sta $1943
    rts
draw_picture:
    lda turns
    and #1
    asl
    asl
    asl
    asl
    clc
    adc #72
    sta $1943
    rts
