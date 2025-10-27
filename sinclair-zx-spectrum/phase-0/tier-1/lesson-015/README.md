# ZX Spectrum Lesson 015 - Enemy Chase

## Files

- `simple-chase.bas` - Basic enemy AI with chase behavior
- `escape-maze.bas` - Complete chase game with maze, collectibles, and lives system

## Running the Code

### On Real Hardware
1. Switch on your ZX Spectrum
2. Type in the program line by line
3. Type `RUN` and press ENTER

### On Emulator (Fuse, ZXSpin, etc.)
1. Start the emulator
2. Type in the program or load the .bas file
3. Type `RUN` and press ENTER

## What It Does

### simple-chase.bas
Basic enemy AI demonstration:
- Player (@) starts at top-left
- Enemy (!) starts at bottom-right
- Enemy moves toward player each frame
- Enemy closes distance horizontally and vertically
- Game over when enemy catches player
- PAUSE 3 slows game to playable speed
- No walls - open playfield

### escape-maze.bas
Complete chase game with multiple mechanics:
- Maze with walls and gaps
- Four collectible stars to gather
- Enemy chases player through maze
- Enemy respects walls (won't walk through them)
- Lives system (3 lives)
- Losing life resets positions
- Win by collecting all stars before losing all lives
- Game over if lives reach zero
- Victory message shows remaining lives

## Key Concepts

- **Simple AI** - Enemy moves toward player by comparing positions
- **Multiple objects** - Track player (PX, PY) and enemy (EX, EY) separately
- **Chase algorithm** - Compare X coordinates, move closer; compare Y coordinates, move closer
- **Collision detection** - Check if player and enemy positions match
- **Lives system** - LIVES variable decrements on collision
- **Position reset** - After death, return player and enemy to start
- **AI collision** - Enemy checks SCREEN$ before moving (respects walls)
- **Game pacing** - PAUSE slows game loop to manageable speed

## Controls

### Both Programs
- Q - Move up
- A - Move down
- O - Move left
- P - Move right
- Avoid the enemy!

### escape-maze.bas Only
- Collect all 4 stars to win
- You have 3 lives
- Each collision loses one life

## Technical Details

- **AI algorithm**: Compare positions, move one step closer each frame
  - IF EX<PX THEN LET EX=EX+1 (enemy left of player, move right)
  - IF EX>PX THEN LET EX=EX-1 (enemy right of player, move left)
  - IF EY<PY THEN LET EY=EY+1 (enemy above player, move down)
  - IF EY>PY THEN LET EY=EY-1 (enemy below player, move up)
- **Collision check**: IF PX=EX AND PY=EY (both coordinates match)
- **AI wall detection**: Check SCREEN$(NEY,NEX) before moving enemy
- **PAUSE 3**: Delays 3/50 second (0.06 sec) between frames
- **Position reset**: Set PX, PY, EX, EY back to start values after death
- **Victory condition**: Checked after collection, not after collision

## Game Flow

### simple-chase.bas
1. Place player and enemy at opposite corners
2. Game loop:
   - Read player input (INKEY$)
   - Move player based on input
   - AI: Move enemy one step toward player
   - Check if positions match
   - If caught → game over
   - PAUSE to slow game
3. Repeat until caught

### escape-maze.bas
1. Draw maze with walls and gaps
2. Place 4 stars
3. Initialize LIVES=3, SCORE=0
4. Place player (top center) and enemy (bottom center)
5. Game loop:
   - Read player input
   - Check player destination (SCREEN$)
   - Move player if valid
   - AI: Calculate new enemy position toward player
   - Check enemy destination (SCREEN$)
   - Move enemy if valid (respects walls)
   - Check collision
   - If collision → lose life, reset positions
   - If lives=0 → game over
   - If score=items → victory
6. Repeat until win or lose

## Chase Algorithm

The enemy uses simple "move toward player" logic:
- Compare enemy X to player X
- If enemy is left of player (EX<PX) → move right (EX+1)
- If enemy is right of player (EX>PX) → move left (EX-1)
- Compare enemy Y to player Y
- If enemy is above player (EY<PY) → move down (EY+1)
- If enemy is below player (EY>PY) → move up (EY-1)

This creates diagonal movement when enemy is offset both horizontally and vertically. Enemy always closes distance on both axes.

## Lives System

- LIVES starts at 3
- Each collision: LIVES=LIVES-1
- After collision:
  - Play death sound (BEEP 0.2,5)
  - Reset player to start position
  - Reset enemy to start position
  - PAUSE 50 (1 second break before resuming)
- If LIVES=0 → trigger game over

## Notes

- Simple AI doesn't pathfind - walks into walls if direct route blocked
- Enemy moves every frame (not just when player moves)
- PAUSE value affects difficulty (lower = faster, harder)
- Lives system adds forgiveness (learn enemy patterns without instant game over)
- Maze creates strategic element (use walls to block enemy temporarily)
- Collecting all stars while avoiding enemy requires planning
- Enemy speed = player speed (one cell per frame)
- No diagonal player movement (QAOP keys only)
