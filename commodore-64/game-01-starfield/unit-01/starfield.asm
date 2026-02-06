; Starfield - Unit 1: Ship on Screen
; Assemble with: acme -f cbm -o starfield.prg starfield.asm

; ------------------------------------------------
; BASIC stub — launches machine code with SYS 2061
; ------------------------------------------------
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

; ------------------------------------------------
; Main program
; ------------------------------------------------
*= $080d
        ; Black screen
        lda #$00
        sta $d020           ; Border colour
        sta $d021           ; Background colour

        ; Clear the screen (fill with spaces)
        ldx #$00
-       lda #$20            ; Space character
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne -

        ; Tell VIC-II where sprite 0's graphic data lives
        ; Block number = address / 64.  $2000 / 64 = 128.
        lda #128
        sta $07f8           ; Sprite 0 data pointer

        ; Position sprite 0 near centre-bottom of screen
        lda #172            ; X position
        sta $d000           ; Sprite 0 X position
        lda #220            ; Y position
        sta $d001           ; Sprite 0 Y position

        ; Set sprite 0 colour to white
        lda #$01
        sta $d027           ; Sprite 0 colour

        ; Enable sprite 0
        lda #%00000001      ; Bit 0 = sprite 0
        sta $d015           ; Sprite enable register

        ; Loop forever
-       jmp -

; ------------------------------------------------
; Sprite data at $2000 (block 128)
; 24 pixels wide x 21 rows = 63 bytes
; Each row: 3 bytes, bit 7 = leftmost pixel
; ------------------------------------------------
*= $2000
        ;                       Pixels
        !byte $00,$18,$00   ;        ##
        !byte $00,$3c,$00   ;       ####
        !byte $00,$3c,$00   ;       ####
        !byte $00,$7e,$00   ;      ######
        !byte $00,$7e,$00   ;      ######
        !byte $00,$ff,$00   ;     ########
        !byte $00,$ff,$00   ;     ########
        !byte $01,$ff,$80   ;    ##########
        !byte $03,$ff,$c0   ;   ############
        !byte $07,$ff,$e0   ;  ##############
        !byte $07,$ff,$e0   ;  ##############
        !byte $07,$e7,$e0   ;  ###..####..###
        !byte $03,$c3,$c0   ;   ##....##....##
        !byte $01,$ff,$80   ;    ##########
        !byte $00,$ff,$00   ;     ########
        !byte $00,$ff,$00   ;     ########
        !byte $00,$db,$00   ;     ##.##.##
        !byte $00,$db,$00   ;     ##.##.##
        !byte $00,$66,$00   ;      ##..##
        !byte $00,$24,$00   ;       #..#
        !byte $00,$00,$00   ;
