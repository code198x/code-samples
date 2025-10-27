# Lesson 015: Enemy AI

Implement simple enemy AI with chase behaviour using arrays for entity management.

## Files

- `enemy-ai.amos` - Multiple enemies with chase AI

## Concepts

- **Enemy arrays** - Parallel arrays for position and state
- **Chase AI** - Move towards player position
- **Active state tracking** - Enable/disable enemies efficiently
- **Multiple independent entities** - Each enemy acts autonomously
- **Entity management** - Loop through all entities to update
- **AI patterns** - Simple but effective pursuit behaviour

## Enemy Data Structure

```amos
Dim ex(5)    ' Enemy X positions
Dim ey(5)    ' Enemy Y positions
Dim ea(5)    ' Enemy active states (1=active, 0=inactive)
```

**Parallel arrays:** Index i corresponds to same enemy across all arrays.

## Chase AI Algorithm

```amos
' For each enemy
If ex(i) < px Then Add ex(i), 1    ' Player is to the right
If ex(i) > px Then Dec ex(i), 1    ' Player is to the left
If ey(i) < py Then Add ey(i), 1    ' Player is below
If ey(i) > py Then Dec ey(i), 1    ' Player is above
```

**Result:** Enemy moves one pixel towards player each frame. Simple but effective.

## Entity Management Pattern

```amos
' CREATE entities
For i = 1 To enemyCount
  ex(i) = starting_x
  ey(i) = starting_y
  ea(i) = 1              ' Active
  Bob i+1, ex(i), ey(i), 2
Next i

' UPDATE entities
For i = 1 To enemyCount
  If ea(i) = 1 Then     ' Only process active enemies
    ' AI logic here
    Bob i+1, ex(i), ey(i), 2
  End If
Next i

' DESTROY entity
ea(i) = 0               ' Mark inactive
Bob Off i+1             ' Hide BOB
```

## BOB Number Management

**Player:** BOB 1
**Enemies:** BOBs 2-6 (array indices 1-5, BOB numbers i+1)
**Collectibles:** BOBs 7+ (if needed)

**Why i+1?**
- BOB 1 is player
- Enemy array starts at index 1
- Enemy 1 → BOB 2 (index+1)
- Enemy 2 → BOB 3, etc.

## AI Speed Control

```amos
' Slow chase (1 pixel/frame)
If ex(i) < px Then Add ex(i), 1

' Fast chase (2 pixels/frame)
If ex(i) < px Then Add ex(i), 2

' Very fast chase (3 pixels/frame)
If ex(i) < px Then Add ex(i), 3
```

Higher speed values make enemies more dangerous.

## Collision with Enemies

```amos
hit = Col(1)    ' Check player collisions

' Determine which enemy was hit
enemyNum = hit - 1    ' Convert BOB number to array index

' Verify it's an enemy (not player)
If enemyNum >= 1 and enemyNum <= 5 Then
  If ea(enemyNum) = 1 Then
    ea(enemyNum) = 0    ' Deactivate
    Bob Off hit         ' Hide
  End If
End If
```

## Running

1. Load AMOS Professional
2. Load `enemy-ai.amos`
3. Press F1 to run
4. Move player with joystick/arrows
5. Watch enemies chase you
6. Touch enemies to destroy them
7. Destroy all 5 to win
8. Press SPACE to quit

## AI Variations

### Patrol AI
```amos
' Move in pattern (not towards player)
Add ex(i), edx(i)     ' Move in direction
If ex(i) < minX or ex(i) > maxX Then edx(i) = -edx(i)  ' Bounce
```

### Flee AI
```amos
' Opposite of chase (run away from player)
If ex(i) < px Then Dec ex(i), 1    ' Player right, move left
If ex(i) > px Then Add ex(i), 1    ' Player left, move right
```

### Random Wander
```amos
' Move randomly
Add ex(i), Rnd(3) - 1    ' -1, 0, or 1
Add ey(i), Rnd(3) - 1
```

### Smart Chase (Diagonal)
```amos
' Current AI moves Manhattan distance (only horizontal or vertical)
' Smart chase moves diagonally (both at once)
If ex(i) < px Then Add ex(i), 1
If ey(i) < py Then Add ey(i), 1    ' Both happen same frame
```

## Extensions

Try:
- Add different enemy types (fast/slow/patrol/flee)
- Implement enemy spawning (create more over time)
- Add enemy health (multiple hits to destroy)
- Create formations (enemies maintain relative positions)
- Implement line-of-sight (only chase if can "see" player)
- Add obstacles (enemies avoid walls)
- Create enemy bullets/projectiles
- Implement AI difficulty levels
- Add enemy sound effects
- Create boss enemy with complex behaviour
