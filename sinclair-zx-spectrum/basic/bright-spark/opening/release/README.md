# Bright Spark: local handover

A memory game for a **48K PAL ZX Spectrum**. It is published as a
download from the Code198x website's Bright Spark experiment page. Other Spectrum models and regional configurations
are not acceptance targets for this release.

## Run it

Use `spark16.tap` in a Spectrum emulator with its required firmware configured,
or a suitable tape playback route for your machine. Select a 48K PAL model.
Enter `LOAD "spark16"`, start tape playback, wait for BASIC's successful load
report, then enter `RUN`. The tape does not start the game automatically.

The title explains the game. Release keys, then press and release **s** to start.
Watch the signals and repeat their order with **1–4**. Wait for each echoed cue
to finish before pressing the next key. Each completed round adds one choice.
Complete 16 rounds to finish; a different choice ends the attempt.

At a result, press and release **r** to replay. Hold **q** to quit, including
during WATCH. A cue finishes its sound and repaint before the quit check runs.
After quitting, `RUN` starts again. Use one key at a time.

Sound is optional: permanent digits, active asterisks, status and result text
carry the information. Brightness and colour are additional cues.

## Source and package

The source checkpoint is `../unit-07/steps/step-02.bas`. The TAP is saved by
that program's 48K ROM session as `spark16`, then loaded into a fresh emulator
process. `manifest.json` identifies the source, package and verification binary
by SHA-256. Keep the source checkpoint and this note alongside the tape.

There are no external sprite, music or artwork assets: BASIC draws the panels
and produces the notes. The code is covered by the repository's root `LICENSE`;
keep its copyright and permission notice with redistributed copies. Firmware
is not part of this package.

## Completion criteria and limitations

The target is a complete small memory game: title and controls, one new choice
per round, correct success/failure counts, a 16-round ending, replay with reset
session state and a working quit path. A fresh load must reach the same game.

The beeper and drawing routine block BASIC. Input is polled between cues; brief
presses during a cue can be missed. There is no queue for typing a whole answer
ahead, and a held key can shorten `PAUSE`. The start and replay controls wait for
release. These are documented boundaries, not promises of instant response.

A full round sequence is pseudorandom; the verification seed is a test setup,
not a guarantee that differently timed sessions produce identical games.

## Release notes

The game source is unchanged. This delivery adds a reproducible local package,
source/package hashes and handover evidence. Optional pitch/duration and fault
experiments remain separate from the shipped program. Input buffering or a
background sound player would be future changes, not completion requirements.

See [verification](../verification/handover/README.md) for the named emulator,
observations and remaining evidence limits. Original-hardware testing is not
claimed.
