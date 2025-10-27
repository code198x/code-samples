# Lesson 016: Amiga Arcade

Complete arcade game synthesis combining ALL Phase 0 Tier 1 concepts.

## Files

- `amiga-arcade.amos` - Full game: menu, gameplay, game over, restart

## Concepts Synthesized

This lesson combines everything from lessons 1-15:

**Arc 1 (Structured Programming):**
- Procedures (Menu, PlayGame)
- Variables and scoring
- Do...Loop control flow

**Arc 2 (Data Structures):**
- Arrays (enemy and collectible data)
- Data management with Dim

**Arc 3 (BOB Graphics):**
- Screen Open and display modes
- Get Bob sprite creation
- Paste Bob / Bob command
- Drawing commands (Bar, Circle)
- Colour palette programming
- Bob Update synchronization

**Arc 4 (Paula Audio):**
- Sam Play sound effects
- Event-driven audio (collection, hit sounds)

**Arc 5 (Moving BOBs):**
- Joystick input (Jleft, Jright, etc.)
- Bob movement and positioning
- Collision detection (Col function)
- Bob Off for hiding sprites
- Timer countdown

**Arc 6 (Game Systems):**
- Enemy AI (chase behaviour)
- Multiple entity management
- Lives system
- Difficulty progression
- Win/lose conditions

## Game Architecture

```
┌─────────────────┐
│      Menu       │
│  (Procedure)    │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   PlayGame      │
│  (Procedure)    │
│                 │
│ 1. Setup        │
│ 2. Game Loop    │
│ 3. Game Over    │
└────────┬────────┘
         │
         ↓ (restart)
┌─────────────────┐
│  Back to Menu   │
└─────────────────┘
```

## Entity Management

**BOB allocation:**
- BOB 1: Player
- BOBs 11-18: Enemies (up to 8)
- BOBs 21-30: Collectibles (up to 10)

**Why this numbering?**
- Separated ranges prevent conflicts
- Easy collision detection (check BOB number range)
- Clear organization

## Game Loop Structure

```amos
Do
  ' 1. INPUT
  Read joystick/keyboard

  ' 2. PLAYER UPDATE
  Move player
  Check boundaries

  ' 3. ENEMY UPDATE
  For each active enemy
    Chase AI
    Update position
  Next

  ' 4. COLLISION
  Check player vs collectibles
  Check player vs enemies

  ' 5. GAME LOGIC
  Update score/lives/timer
  Check win/lose conditions
  Apply difficulty progression

  ' 6. DISPLAY
  Update HUD
  Show status

  ' 7. SYNCHRONIZE
  Wait Vbl
  Bob Update
Loop Until game_over
```

This pattern scales to any game complexity.

## Difficulty Progression

```amos
' At 50 points, enemies speed up
If score >= 50 and enemySpeed = 1 Then
  enemySpeed = 2
  Print "ENEMIES FASTER!"
End If
```

**Other progression ideas:**
- Add more enemies
- Reduce player speed
- Decrease timer countdown rate
- Increase enemy spawn frequency

## Procedure Benefits

**Without procedures:**
```amos
' All code in one block
' Hard to restart
' Variables never reset
' Can't return to menu
```

**With procedures:**
```amos
' Clean separation
PlayGame    ' Can call multiple times
Menu        ' Easy navigation
' Variables auto-reset per call
```

## Running

1. Load AMOS Professional
2. Load `amiga-arcade.amos`
3. Press F1 to run
4. Press 1 at menu to start
5. Collect yellow items (10 points each)
6. Avoid red enemies (lose 1 life per hit)
7. Beat 60-second timer
8. Watch enemies speed up at 50 points
9. See game over screen with final score
10. Returns to menu automatically

## Winning Strategy

**Maximize score:**
1. Collect items quickly (10 items × 10 = 100 points)
2. Keep moving (enemies are slow at first)
3. Use screen edges (enemies chase, predictable)
4. After 50 points, enemies speed up - be careful!
5. Sacrifice 1-2 lives if needed to get final items

**High score tips:**
- Circular movement patterns work well
- Don't stop moving
- Watch timer - don't waste time
- Learn enemy spawn positions

## Polish Elements

**Audio feedback:**
```amos
Sam Play 0,1    ' Collect item
Sam Play 1,5    ' Hit enemy
```

**Visual feedback:**
```amos
' Color-coded messages
Ink 2: Print "YOU WIN!"    ' Green
Ink 1: Print "GAME OVER!"  ' Red
Ink 4: Print "SCORE"       ' Yellow
```

**Timer urgency:**
- Displays seconds remaining
- Creates tension as time runs out

## Extensions

This game is a foundation. Extend it with:

### Graphics
- Add sprite animation (multiple frames)
- Create explosion effects (temporary BOBs)
- Add background scrolling
- Implement particle systems

### Gameplay
- Power-ups (speed boost, invincibility, time extension)
- Multiple enemy types (fast, slow, patrol, boss)
- Projectile weapons (player can shoot)
- Multiple levels (increase difficulty)
- Bonus stages

### Polish
- Background music (Music Bank)
- Screen shake on hit
- Health bar instead of lives counter
- Combo system (rapid collection bonus)
- High score table (save to disk)
- Attract mode (demo gameplay)

### Architecture
- State machine (title, gameplay, pause, game over)
- Save/load system
- Configuration options (difficulty, sound on/off)
- Two-player mode

## What You've Mastered

After completing all 16 lessons of Phase 0 Tier 1, you can now:

✅ Write structured AMOS programmes with procedures
✅ Use arrays and data structures
✅ Create and animate BOBs (hardware sprites)
✅ Draw graphics with Amiga's blitter
✅ Programme custom colour palettes
✅ Play sound effects with Paula audio chip
✅ Handle joystick/keyboard input
✅ Implement collision detection
✅ Manage timers and game state
✅ Create enemy AI
✅ Build complete playable games
✅ Structure code for maintainability
✅ Understand Amiga hardware capabilities

**You've graduated from Tier 1!** You can now create real Amiga games using AMOS Professional.

**Next: Phase 0 Tier 2** - Advanced techniques (scrolling, copper effects, sample banks, advanced AI, and more!)
