# Lesson 012: BOB Movement

Move BOBs with joystick or keyboard input using smooth coordinate updates.

## Files

- `bob-movement.amos` - Interactive sprite movement demo

## Concepts

- **Bob command** - Update BOB position each frame
- **Joystick input** - Jleft, Jright, Jup, Jdown functions
- **Coordinate system** - X (0-319), Y (0-255) in low-res mode
- **Movement speed** - Control velocity by add/subtract amount
- **Boundary checking** - Prevent sprites moving off screen
- **Bob X/Y** - Read current BOB coordinates
- **Smooth movement** - Update position every frame with Wait Vbl

## Joystick Functions

```amos
Jleft(port)   ' Returns -1 if left pressed, 0 otherwise
Jright(port)  ' Returns -1 if right pressed, 0 otherwise
Jup(port)     ' Returns -1 if up pressed, 0 otherwise
Jdown(port)   ' Returns -1 if down pressed, 0 otherwise
```

**Port numbers:**
- Port 1: Joystick in right port (standard)
- Port 0: Joystick in left port (player 2)

**Keyboard fallback:** Arrow keys work automatically via Jleft/Jright functions

## Movement Pattern

```amos
' Read input
If Jleft(1) Then Dec x,speed   ' Move left
If Jright(1) Then Add x,speed  ' Move right
If Jup(1) Then Dec y,speed     ' Move up
If Jdown(1) Then Add y,speed   ' Move down

' Update BOB
Bob 1,x,y,1

' Refresh display
Wait Vbl
Bob Update
```

## Boundary Checking

```amos
' Prevent moving off screen edges
' Screen: 320x256, BOB: 16x16

If x<0 Then x=0           ' Left edge
If x>304 Then x=304       ' Right edge (320-16)
If y<0 Then y=0           ' Top edge
If y>240 Then y=240       ' Bottom edge (256-16)
```

## Speed Control

```amos
speed=1     ' Slow movement
speed=2     ' Normal movement
speed=4     ' Fast movement
speed=8     ' Very fast movement
```

Higher values = faster movement per frame.

## Position Reading

```amos
' Get BOB coordinates
current_x = Bob X(1)
current_y = Bob Y(1)

' Use for calculations
distance = Bob X(1) - target_x
```

## Running

1. Load AMOS Professional
2. Load `bob-movement.amos`
3. Press F1 to run
4. Connect joystick to right port (or use arrow keys)
5. Move sprite with joystick/keys
6. Watch smooth 50fps movement
7. Press SPACE to quit

## Hardware Used

**Input:**
- CIA-A: Joystick port reading via memory-mapped I/O
- Keyboard: Arrow keys read via CIA

**Graphics:**
- Blitter: BOB display and background save/restore
- Denise: Screen output
- Agnus: BOB coordinate management

## Extensions

Try:
- Add diagonal movement (check two directions at once)
- Implement acceleration/deceleration
- Add sprite rotation based on direction
- Create momentum (don't stop instantly)
- Add "walking" animation (change Bob image while moving)
- Implement screen wrapping (off left → appear right)
- Add speed power-ups
