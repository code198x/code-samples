# Lesson 014: Collect & Score

Complete game with timer, win/lose conditions, and game state management.

## Files

- `collect-and-score.amos` - Full collectible game with timer

## Concepts

- **Timer command** - Countdown timer (50 ticks = 1 second)
- **Game states** - Playing, Won, Lost
- **Win conditions** - Score threshold AND time remaining
- **Lose conditions** - Timer expires before target reached
- **Game loop** - Complete input-logic-collision-display cycle
- **Procedure structure** - Allows restart without rerunning setup
- **Game over handling** - Clear feedback and state cleanup

## Timer System

```amos
Timer = value     ' Set timer (50 Hz ticks)
time = Timer      ' Read current timer value
```

**Timing:**
- 50 ticks = 1 second (PAL: 50Hz)
- 60 ticks = 1 second (NTSC: 60Hz)
- Counts down automatically
- Reaches 0 and stops (doesn't go negative)

**Examples:**
```amos
Timer = 10*50     ' 10 seconds
Timer = 30*50     ' 30 seconds
Timer = 60*50     ' 1 minute

' Display seconds remaining
Print Timer/50
```

## Game States

```amos
' State management pattern
state = 0    ' 0=playing, 1=won, 2=lost

Do
  ' Game logic

  If score >= target Then state = 1: Exit
  If Timer <= 0 Then state = 2: Exit
Loop

' Handle result based on state
If state = 1 Then Print "YOU WIN!"
If state = 2 Then Print "TIME'S UP!"
```

## Win/Lose Conditions

**Multiple exit conditions:**
```amos
Do
  ' Game loop

  ' Win: Reached target score
  If score >= target Then Exit

  ' Lose: Time expired
  If Timer <= 0 Then Exit

  Wait Vbl
Loop

' Check which condition triggered
If score >= target Then
  ' Won
Else
  ' Lost (must be timer)
End If
```

## Complete Game Structure

```amos
' 1. SETUP PHASE
Screen Open
Create sprites
Initialize variables

' 2. GAME LOOP
Do
  Input
  Movement
  Collision
  Update display
  Check win/lose
  Wait Vbl
Loop

' 3. GAME OVER
Display result
Show final score
Wait for input

' 4. CLEANUP
Hide BOBs
Clear screen
```

## Procedure Pattern for Restart

```amos
Procedure PlayGame
  ' Complete game in procedure
  ' Can be called multiple times
End Proc

' Main program
PlayGame

' Can add restart loop:
Do
  PlayGame
  Print "Play again? (Y/N)"
Loop Until Upper$(Inkey$) = "N"
```

**Why use Procedure?**
- Encapsulates complete game
- Easy to restart (just call again)
- Variables reset each time
- Clean separation of game logic

## Running

1. Load AMOS Professional
2. Load `collect-and-score.amos`
3. Press F1 to run
4. Collect 100 points (10 collectibles × 10 points)
5. Beat the 30-second timer
6. See win/lose message
7. Press any key after game over

## Difficulty Tuning

**Easier:**
```amos
target = 50           ' Lower target
Timer = 60*50         ' More time
```

**Harder:**
```amos
target = 150          ' Higher target
Timer = 20*50         ' Less time
speed = 3             ' Faster movement (harder control)
```

**Balanced:**
```amos
' Number of collectibles = target/10
' Time should be: (collectibles * 3) seconds
' Example: 10 items × 10 points = 100 target
'          10 items × 3 = 30 seconds
```

## Game Feel Improvements

### Sound Feedback
```amos
' Different sounds for events
Sam Play 0,1    ' Collect item
Sam Play 1,5    ' Win
Sam Play 2,10   ' Lose
```

### Visual Feedback
```amos
' Flash screen on collection
If hit > 0 Then
  Ink Rnd(15)+1
  Circle px,py,20
End If
```

### Tension Building
```amos
' Change color when time running low
If Timer < 500 Then Ink 3    ' Red warning
```

## Extensions

Try:
- Add multiple levels (increase difficulty)
- Create different collectible types (5, 10, 20 points)
- Add moving obstacles (lose points if hit)
- Implement power-ups (time extension, score multiplier)
- Create combo system (rapid collection bonus)
- Add lives system (3 hits before game over)
- Implement high score table with name entry
- Add background music (Music Bank)
- Create particle effects on collection
- Add difficulty selection menu
- Implement save/load high scores to disk

## Complete Game Architecture

```amos
' INITIALIZATION
Screen setup
Load assets (sprites, sounds, music)

' GAME LOOP
While playing
  Read input
  Update player
  Update enemies/items
  Check collisions
  Update score/timer
  Check win/lose
  Render frame
  Synchronize
End While

' GAME OVER
Stop game elements
Display result
Offer restart

' CLEANUP
Release resources
Return to menu/quit
```

This structure scales from simple games to complex ones.
