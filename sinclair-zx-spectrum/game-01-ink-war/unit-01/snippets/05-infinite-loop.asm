; Infinite loop to keep the program running
; Without this, we'd return to BASIC and the screen would change

forever:
        jr forever          ; Jump Relative to self - loops forever
