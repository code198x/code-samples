# Lesson 009: Sprite Gallery

Interactive sprite viewer demonstrating Bob command for automatic BOB management.

## Files

- `sprite-gallery.amos` - Interactive gallery with 6 different sprites

## Concepts

- **Bob command** (vs Paste Bob): Automatic BOB management with collision detection
- **Multiple BOBs**: Create sprite library with numbered BOBs
- **Bob Update**: Refresh all BOBs on screen
- **Wait Vbl**: Synchronize with vertical blank (50Hz PAL)
- **Interactive display**: Keyboard input with Inkey$
- **Animation frames**: Multiple images for same sprite

## Bob Command vs Paste Bob

### Paste Bob - Manual Control
```amos
Paste Bob x,y,number    ' Display BOB once at position
' You handle everything: erasing, redrawing, collision
```

### Bob Command - Automatic Management
```amos
Bob number,x,y,image    ' Position BOB and select image
Bob Update              ' Refresh all BOBs (call once per frame)
' AMOS handles: background save/restore, collision detection, sprite priority
```

**Use Bob command when:**
- You need collision detection
- You want automatic background restoration
- You're moving sprites frequently
- You need sprite priority management

**Use Paste Bob when:**
- Static display only
- You handle erasing manually
- Maximum control over rendering

## Multiple BOBs

```amos
' Create sprite images
Get Bob 1,x1,y1 To x2,y2    ' First sprite design
Get Bob 2,x1,y1 To x2,y2    ' Second sprite design
Get Bob 3,x1,y1 To x2,y2    ' Third sprite design

' Display them
Bob 1,100,100,1    ' BOB #1 using image #1
Bob 2,150,100,2    ' BOB #2 using image #2
Bob 3,200,100,3    ' BOB #3 using image #3
Bob Update         ' Refresh all at once
```

**BOB number vs Image number:**
- BOB number: Which sprite instance (1, 2, 3...)
- Image number: Which graphic to display (1, 2, 3...)
- You can change BOB 1's image from 1 to 2 for animation

## Wait Vbl - Vertical Blank Synchronization

```amos
Wait Vbl           ' Wait for next frame (50Hz PAL, 60Hz NTSC)
```

**Why synchronize?**
- Prevents tearing (display updating mid-frame)
- Smooth animation (50 frames per second)
- Consistent timing across different Amiga models

**PAL (Europe) vs NTSC (US):**
- PAL: 50Hz, 312 lines
- NTSC: 60Hz, 262 lines
- Wait Vbl works with either

## Programme Structure

```amos
' 1. SETUP
Screen Open / palette

' 2. CREATE SPRITE LIBRARY
Get Bob 1,...
Get Bob 2,...
Get Bob N,...

' 3. MAIN LOOP
Do
  ' Process input
  ' Update BOB positions
  Bob 1,x,y,image
  Bob 2,x,y,image

  ' Refresh display
  Bob Update
  Wait Vbl
Loop
```

## Running

1. Load AMOS Professional
2. Load `sprite-gallery.amos`
3. Press F1 to run
4. Use cursor keys to change sprite
5. Press SPACE to cycle through sprites
6. Press Q to quit
7. See all 6 sprites in gallery at bottom

## Hardware Used

**Blitter**: BOB creation and copying
**Agnus**: BOB memory management
**Copper**: Sprite priority
**Denise**: Display output

## Extensions

Try:
- Add more sprite designs (8, 10, 12 sprites)
- Animate sprites (multiple frames per sprite)
- Move sprites with cursor keys
- Add collision detection between BOBs
- Create simple game with Bob command
- Make sprite editor
- Save/load sprite libraries
