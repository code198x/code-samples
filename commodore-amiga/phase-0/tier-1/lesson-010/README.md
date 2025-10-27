# Lesson 010: Paula Sound

Introduction to the Amiga's 4-channel audio system.

## Files

- `paula-sound.amos` - Interactive 4-channel sound demo

## Concepts

- **Paula audio chip** - 4 independent 8-bit PCM channels
- **Sam Play** - Play sound samples on specific channels
- **Channel routing** - 0,2=left speaker, 1,3=right speaker
- **Built-in samples** - AMOS includes 40 pre-loaded samples (1-40)
- **PCM audio** - Pulse Code Modulation, 8-bit signed samples

## Paula Audio System

Paula provides 4 independent audio channels:
- **Channel 0**: Left speaker
- **Channel 1**: Right speaker
- **Channel 2**: Left speaker
- **Channel 3**: Right speaker

Each channel can play different samples simultaneously at different pitches and volumes.

## Sam Play Command

```amos
Sam Play channel,sample
```

- **channel**: 0-3 (which audio channel)
- **sample**: 1-40 (built-in sample number)

## Built-in Samples

AMOS Professional includes 40 pre-loaded samples:
- 1-10: Drum and percussion sounds
- 11-20: Bass and low sounds
- 21-30: Melodic sounds
- 31-40: Effects and noise

## Running

1. Load AMOS Professional
2. Load `paula-sound.amos`
3. Press F1 to run
4. Press keys 1-4 to trigger different channels
5. Press SPACE to quit
6. Notice stereo separation (channels 0,2 left, 1,3 right)

## Hardware Used

**Paula**: 4-channel 8-bit PCM audio chip
- Sample rate: 28.8kHz (NTSC) / 28.37kHz (PAL)
- Resolution: 8-bit signed samples
- Independent volume control per channel
- DMA-driven playback (no CPU overhead)

## Extensions

Try:
- Play multiple channels simultaneously
- Add volume control with Vol command
- Create drum patterns with timed Sam Play
- Experiment with different built-in samples
- Load external sample banks with Sam Bank
- Add pitch control with Sam Raw
