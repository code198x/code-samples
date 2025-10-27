# Lesson 011: Music Player

Interactive music player with visual feedback using Paula audio.

## Files

- `music-player.amos` - Multi-track music player with UI

## Concepts

- **Music Bank** - Load and play multi-channel music files
- **Music command** - Play/stop music tracks
- **Music variables** - Check playback status with Music(0) and Music(1)
- **Tempo control** - Set playback speed with Tempo command
- **Audio visualization** - Update display based on music status
- **Interactive UI** - Keyboard-driven music control

## Music System

AMOS Professional includes a complete music system:
- **Music Bank**: Container for multiple music tracks
- **Multi-channel**: Uses all 4 Paula channels simultaneously
- **Pattern-based**: Music stored as note patterns, not samples
- **Tempo control**: Adjustable playback speed

## Music Commands

```amos
Music Bank Load "file.abk"    ' Load music bank
Music number                  ' Play track (1-N)
Music Stop                    ' Stop playback
Tempo number                  ' Set tempo (50 = 1 second per beat)
```

## Music Variables

```amos
position=Music(0)    ' Current playback position
playing=Music(1)     ' Is music playing? (0=no, 1=yes)
```

## Programme Structure

```amos
' 1. SETUP
Screen Open / palette / UI

' 2. MAIN LOOP
Do
  ' Get input
  ' Control music (play/stop/track selection)
  ' Update visual feedback
  ' Synchronize with Wait Vbl
Loop

' 3. CLEANUP
Music Stop
```

## Running

1. Load AMOS Professional
2. Load `music-player.amos`
3. Press F1 to run
4. Press 1-5 to select tracks
5. Press S to stop playback
6. Press Q to quit
7. Watch visual feedback update

**Note**: Demo uses samples as music bank substitute. In real usage, load `.abk` music files.

## Hardware Used

**Paula**: 4-channel music playback
- All 4 channels used simultaneously
- Hardware mixing (no CPU overhead)
- Pattern-based sequencing
- Tempo-synchronized playback

## Music Bank Files

AMOS music banks (`.abk` files) contain:
- Note patterns for 4 channels
- Instrument definitions
- Tempo information
- Loop points

Created with AMOS Music editor or tracker software.

## Extensions

Try:
- Load real music banks (`.abk` files)
- Add volume control with Vol command
- Create playlist with track queue
- Add visual spectrum analyzer
- Implement fade in/out effects
- Add track information display
- Create random/shuffle modes
- Add tempo adjustment controls
