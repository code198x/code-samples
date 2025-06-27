; Crystal Cascade - Lesson 1 Step 3
; Basic bitplane setup

        SECTION CODE,CODE

start:
        ; Save system state
        move.l  $4.w,a6         ; Get ExecBase  
        move.l  #gfxname,a1     ; Graphics library name
        moveq   #0,d0           ; Any version
        jsr     -552(a6)        ; OpenLibrary()
        move.l  d0,gfxbase      ; Store graphics.library base
        
        ; Take over the display
        move.l  gfxbase,a6      ; Graphics library base
        jsr     -456(a6)        ; OwnBlitter()
        jsr     -228(a6)        ; WaitTOF() - wait for frame
        
        ; Set up our custom display
        bsr     setup_display
        
        ; Wait for user input (simplified)
        move.l  #1000000,d0     ; Simple delay counter
delay_loop:
        subq.l  #1,d0
        bne     delay_loop
        
        ; Restore system
        move.l  gfxbase,a6      ; Graphics library base  
        jsr     -458(a6)        ; DisownBlitter()
        
        ; Clean exit
        move.l  #0,d0
        rts

setup_display:
        ; Disable display during setup
        move.w  #$0000,$dff096  ; DMACON - disable all DMA
        
        ; Set up bitplane pointers for 3 layers
        ; Background layer (bitplane 0)
        move.l  #background_data,$dff0e0    ; BPL1PTH/L
        
        ; Middle layer (bitplane 1)  
        move.l  #midground_data,$dff0e4     ; BPL2PTH/L
        
        ; Foreground layer (bitplane 2)
        move.l  #foreground_data,$dff0e8    ; BPL3PTH/L
        
        ; Configure display parameters
        move.w  #$3000,$dff100  ; BPLCON0 - 3 bitplanes, color mode
        move.w  #$0000,$dff102  ; BPLCON1 - no horizontal scroll yet
        move.w  #$0000,$dff104  ; BPLCON2 - standard priority
        
        ; Set display window  
        move.w  #$2c81,$dff08e  ; DIWSTRT - display window start
        move.w  #$2cc1,$dff090  ; DIWSTOP - display window stop
        
        ; Set data fetch window
        move.w  #$0038,$dff092  ; DDFSTRT - data fetch start  
        move.w  #$00d0,$dff094  ; DDFSTOP - data fetch stop
        
        ; Set up color palette for parallax layers
        move.w  #$0000,$dff180  ; COLOR00 - background (black)
        move.w  #$0004,$dff182  ; COLOR01 - background layer (dark blue)
        move.w  #$0048,$dff184  ; COLOR02 - middle layer (medium blue)
        move.w  #$008f,$dff186  ; COLOR03 - foreground layer (bright blue)
        move.w  #$0fff,$dff188  ; COLOR04 - crystals (white)
        move.w  #$0f80,$dff18a  ; COLOR05 - energy (yellow)
        move.w  #$0f08,$dff18c  ; COLOR06 - danger (red)
        move.w  #$00f0,$dff18e  ; COLOR07 - power (green)
        
        ; Enable display with bitplane DMA
        move.w  #$8380,$dff096  ; DMACON - enable display, bitplane, copper DMA
        
        rts

; Data section
        SECTION DATA,DATA
gfxname:
        dc.b    'graphics.library',0
        even

; Background layer - distant crystals (slowest parallax)
background_data:
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Empty row
        dc.w    $0100,$0000,$0000,$0000,$0000,$0000,$0000,$0080  ; Sparse crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Empty
        dc.w    $0000,$0000,$0200,$0000,$0000,$0040,$0000,$0000  ; More crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Pattern continues...
        dcb.w   256*8,0         ; Fill rest with zeros (256 lines * 8 words/line)

; Middle layer - medium crystals (medium parallax speed)  
midground_data:
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0400,$0000,$0000,$0000,$0000,$0020,$0000  ; Larger crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0800,$0000,$0000,$0100,$0000,$0000,$0000,$0010  ; Spread out
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dcb.w   256*8,0         ; Fill with pattern

; Foreground layer - large crystals (fastest parallax)
foreground_data:  
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $1000,$0000,$0000,$0000,$0000,$0000,$0000,$0008  ; Big crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dc.w    $0000,$0000,$2000,$0000,$0000,$0004,$0000,$0000  ; Sparse but visible
        dcb.w   256*8,0         ; Pattern continues

        SECTION BSS,BSS
gfxbase:
        ds.l    1               ; Graphics library base pointer