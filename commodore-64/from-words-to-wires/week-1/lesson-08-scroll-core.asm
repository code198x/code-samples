        !to "scrollcore.prg",cbm
        * = $C200

; Mailboxes
VIEW_OFF   = $FB      ; current scroll offset
PLAYER_X   = $FC
STATUS     = $FD

MAP_PTR    = $6000    ; assume map data copied here
SCREEN     = $0400

SCROLL     CLC
           LDA VIEW_OFF
           ADC #$01
           CMP #$40
           BCC .store
           LDA #$00
.store     STA VIEW_OFF

; Draw 24 columns based on VIEW_OFF
           LDX #0
.col       LDY VIEW_OFF
           CLC
           TYA
           ADC X
           TAX
           LDA MAP_PTR,X
           STA SCREEN,X
           INX
           CPX #24
           BNE .col

; Update player sprite using mailbox
           LDA PLAYER_X
           STA $D000

           LDA #0
           STA STATUS
           RTS
