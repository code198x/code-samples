# Lesson 013: Collision Master

Hardware-accelerated collision detection for gameplay mechanics.

## Files

- `collision-master.amos` - Collectible game with collision detection

## Concepts

- **Col function** - Hardware collision detection
- **Bob Off** - Hide collected sprites
- **Multiple BOBs** - Player + items active simultaneously
- **Game loop** - Input → Movement → Collision → Display pattern
- **Pickup mechanics** - Detect, hide, score
- **Sound feedback** - Play sound on collision
- **Win condition** - Check score threshold

## Collision Detection

```amos
hit = Col(bob_number)
```

**Returns:**
- 0: No collision
- 1-N: BOB number that was hit

**Hardware-accelerated:** Amiga blitter checks collision automatically, no CPU overhead.

## Col Function Usage

```amos
' Check if player (BOB 1) hit anything
hit = Col(1)

If hit > 0 Then
  ' Collision detected
  Print "Hit BOB ";hit
End If
```

## Bob Off Command

```amos
Bob Off number    ' Hide BOB (efficient)
Bob On number     ' Show BOB again
```

**Why Bob Off instead of moving off-screen?**
- More efficient (blitter stops tracking)
- Saves background save/restore memory
- Cleaner than moving to (-100,-100)

## Multiple BOBs Pattern

```amos
' Create player
Bob 1, player_x, player_y, 1

' Create 10 collectibles
For i = 2 To 11
  Bob i, Rnd(280)+20, Rnd(220)+20, 2
Next i

' Check collisions
hit = Col(1)
If hit > 1 Then
  Bob Off hit       ' Hide collected item
  Add score, 10
End If
```

## Game Loop Architecture

```amos
Do
  ' 1. INPUT
  If Jleft(1) Then Dec x,2
  If Jright(1) Then Add x,2

  ' 2. MOVEMENT
  Bob 1,x,y,1

  ' 3. COLLISION
  hit = Col(1)
  If hit>1 Then
    Bob Off hit
    Add score,10
  End If

  ' 4. DISPLAY
  Print "Score: ";score

  ' 5. SYNC
  Wait Vbl
  Bob Update
Loop
```

This pattern appears in nearly all Amiga games.

## Collision Mechanics

**Bounding box collision:**
- Amiga checks rectangular BOB boundaries
- Not pixel-perfect (faster)
- Accurate enough for most games

**When does collision check happen?**
- After Bob Update call
- Blitter compares all active BOB positions
- Hardware sets collision flags
- Col() reads those flags

## Running

1. Load AMOS Professional
2. Load `collision-master.amos`
3. Press F1 to run
4. Move player (blue square) with joystick/arrows
5. Collect yellow circles (they disappear)
6. Watch score increase
7. Collect all 5 to win
8. Press SPACE to quit

## Hardware Used

**Blitter:**
- BOB display and movement
- Collision detection (compares BOB positions)
- Background save/restore

**Agnus:**
- BOB coordinate tracking
- Collision flag management

**Paula:**
- Sound effects on collection

## Game Variations

### Easy Mode
```amos
' Larger collectibles (easier to hit)
Get Bob 2,0,0 To 32,32
```

### Hard Mode
```amos
' Moving collectibles
For i=2 To 6
  Add item_x(i), item_dx(i)
  Bob i, item_x(i), item_y(i), 2
Next i
```

### Timer Challenge
```amos
Timer = 20*50    ' 20 seconds
If Timer <= 0 Then Print "TIME'S UP!"
```

## Extensions

Try:
- Add enemy sprites (lose points on collision)
- Create different collectible types (different points)
- Implement power-ups (speed boost, invincibility)
- Add lives system (lose life on enemy hit)
- Create moving collectibles
- Add particle effects on collection
- Implement combo system (rapid collections)
- Add high score table
