; Crystal Cascade - Lesson 1 Complete
; Final parallax world with animation

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
        
        ; Main display loop
main_loop:
        ; Wait for vertical blank (smooth 50Hz animation)
        move.l  gfxbase,a6
        jsr     -228(a6)        ; WaitTOF()
        
        ; Update parallax scrolling
        bsr     update_parallax
        
        ; Animate crystal effects
        bsr     animate_crystals
        
        ; Check for exit (simplified - just run for a while)
        move.l  animation_counter,d0
        cmpi.l  #1000,d0        ; Run for ~20 seconds at 50Hz
        blt     main_loop
        
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

update_parallax:
        ; Update scroll positions for each layer
        move.l  scroll_bg,d0
        addq.l  #1,d0           ; Background scrolls 1 pixel per frame
        andi.l  #$0f,d0         ; Wrap at 16 pixels
        move.l  d0,scroll_bg
        
        move.l  scroll_mid,d1   
        addq.l  #2,d1           ; Midground scrolls 2 pixels per frame
        andi.l  #$0f,d1         ; Wrap at 16 pixels  
        move.l  d1,scroll_mid
        
        move.l  scroll_fg,d2
        addq.l  #4,d2           ; Foreground scrolls 4 pixels per frame
        andi.l  #$0f,d2         ; Wrap at 16 pixels
        move.l  d2,scroll_fg
        
        ; Apply scroll values to hardware
        ; Combine scroll values into BPLCON1 register
        move.w  d0,d3           ; Background scroll (bits 3-0)
        lsl.w   #4,d1           ; Middle scroll to bits 7-4
        or.w    d1,d3
        lsl.w   #4,d2           ; Foreground scroll to bits 11-8  
        or.w    d2,d3
        
        move.w  d3,$dff102      ; BPLCON1 - horizontal scroll register
        
        rts

animate_crystals:
        ; Simple crystal pulse animation
        ; Cycle through crystal colors to create "energy" effect
        
        move.l  animation_counter,d0
        addq.l  #1,d0
        move.l  d0,animation_counter
        
        ; Change crystal colors based on frame counter
        andi.l  #$1f,d0         ; Keep in range 0-31 for slower animation
        
        ; Calculate color intensity
        move.w  d0,d1
        cmpi.w  #16,d1
        bcc     fade_down
        
        ; Fade up (0-15)
        lsr.w   #1,d1           ; Divide by 2 for slower fade
        lsl.w   #4,d1           ; Multiply by 16 for intensity
        ori.w   #$0f0f,d1       ; Add cyan component
        move.w  d1,$dff188      ; COLOR04 - crystal color
        bra     crystal_done
        
fade_down:
        ; Fade down (16-31)  
        subi.w  #16,d1          ; Convert to 0-15 range
        lsr.w   #1,d1           ; Divide by 2
        neg.w   d1              ; Reverse: 7-0
        addq.w  #8,d1           ; Make 15-8
        lsl.w   #4,d1           ; Multiply by 16
        ori.w   #$0f0f,d1       ; Maintain cyan base
        move.w  d1,$dff188      ; COLOR04 - crystal color
        
crystal_done:
        rts

; Data section
        SECTION DATA,DATA
gfxname:
        dc.b    'graphics.library',0
        even

; Background layer - distant crystals (slowest parallax)
background_data:
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 1: Empty
        dc.w    $0100,$0000,$0000,$0000,$0000,$0000,$0000,$0080  ; Row 2: Sparse crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 3: Empty
        dc.w    $0000,$0000,$0200,$0000,$0000,$0040,$0000,$0000  ; Row 4: More crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 5: Empty
        dc.w    $0000,$0010,$0000,$0000,$0800,$0000,$0000,$0000  ; Row 6: Scattered
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 7: Empty
        dc.w    $0020,$0000,$0000,$0400,$0000,$0000,$0002,$0000  ; Row 8: Pattern
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 9: Empty
        dc.w    $0000,$0000,$0100,$0000,$0000,$0000,$0000,$0040  ; Row 10: More
        dcb.w   246*8,$0000     ; Fill remaining 246 rows with empty pattern

; Middle layer - medium crystals (medium parallax speed)  
midground_data:
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 1: Empty
        dc.w    $0000,$0400,$0000,$0000,$0000,$0000,$0020,$0000  ; Row 2: Larger crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 3: Empty
        dc.w    $0800,$0000,$0000,$0100,$0000,$0000,$0000,$0010  ; Row 4: Spread out
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 5: Empty
        dc.w    $0000,$0000,$1000,$0000,$0000,$0008,$0000,$0000  ; Row 6: Medium size
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 7: Empty
        dc.w    $0000,$0200,$0000,$0000,$0040,$0000,$0000,$0000  ; Row 8: Distributed
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 9: Empty
        dc.w    $0004,$0000,$0000,$0000,$0000,$0000,$2000,$0000  ; Row 10: Edge crystals
        dcb.w   246*8,$0000     ; Fill remaining rows

; Foreground layer - large crystals (fastest parallax)
foreground_data:  
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 1: Empty
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 2: Empty
        dc.w    $1000,$0000,$0000,$0000,$0000,$0000,$0000,$0008  ; Row 3: Big crystals
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 4: Empty
        dc.w    $0000,$0000,$2000,$0000,$0000,$0004,$0000,$0000  ; Row 5: Sparse but visible
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 6: Empty
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 7: Empty
        dc.w    $0000,$4000,$0000,$0000,$0000,$0000,$0002,$0000  ; Row 8: Large formations
        dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  ; Row 9: Empty
        dc.w    $0000,$0000,$0000,$8000,$0001,$0000,$0000,$0000  ; Row 10: Edge features
        dcb.w   246*8,$0000     ; Fill remaining rows

        SECTION BSS,BSS
gfxbase:
        ds.l    1               ; Graphics library base pointer
animation_counter:
        ds.l    1               ; Frame counter for animation
scroll_bg:      ds.l    1       ; Background scroll position
scroll_mid:     ds.l    1       ; Midground scroll position  
scroll_fg:      ds.l    1       ; Foreground scroll position