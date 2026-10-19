# Game loop on 48K PAL Spectrum

Load build/demo.tap through the ROM or open build/demo.sna. Hold Space. The border/background or digit changes as updates advance. Holding the action adds deliberately excessive CPU work; release it to restore normal updates. Reset to leave. This is a complete caller for a reusable frame wait, not a finished game or a universal renderer.

## Build and include

Run `make` with Asm198x available. Amiga also needs Build198x. Keep the relative include layout: the core callers reuse the maintained joystick reader or the input reader from the verified input/sound prototype. Include frame.inc once, perform the startup shown by demo.asm, then call wait_frame once before input/update/draw. Read the register, clock and resource contracts in frame.inc and the complete caller before adapting them.

## Cost and limits

37 code bytes plus two state bytes for clock initialisation/wait. ROM code and caller are excluded. These assembled sizes use Asm198x 0.0.64. Code bytes are not runtime cost. Waiting deliberately occupies elapsed time; CPU work, ROM service, contention, display/DMA and interrupt load change the remaining budget. No fixed cycle count or full-game performance claim is made.

Polling waits discard missed boundaries; they do not count lost frames. Spectrum/NES interrupt-byte clocks need fewer than 256 frames between samples and return a delta without automatically replaying updates. The included fixed-step caller is deliberately simple. A new consumer or IRQ writer must agree on ownership.

## Reproduce execution

From the repository root, run `python3 scripts/verify-game-loops.py --help`. Select `--only spectrum` and provide the existing emulator, firmware and Build198x paths. Firmware is not distributed. The recipe builds the caller, executes normal/slow/recovery windows using native machine time and real controller/key input, and requires the same normal-rate check to reject an unpaced negative control.

The retained verification/results.json records exact identities, startup route and observations. It is evidence for that configuration, not an assertion of original-hardware or whole-emulator conformance. Screenshots/generated programs stay under ignored build directories.
