# SID note trigger

The maintained source for the SID Note Trigger pattern. Target: PAL C64,
loaded at $0801 and started with `RUN`. `make` builds `demo.prg`, which
sets the master volume, plays middle C on voice 1 for half a second,
clears the gate and waits for the release to finish.

The contract is in `sid-note.inc`. The caller sets `SID_VOICE` to the
voice's first register ($D400, $D407 or $D40E) before including it. The
routines write only those seven registers and never read the SID, whose
$D400-$D418 registers are write-only. Master volume and filter routing
($D415-$D418) and the other voices belong to the caller. Each routine
changes A and the flags and keeps X and Y. Nothing arbitrates with an
interrupt handler that writes the same voice.

`sid_note_on` clears the gate and then sets it, so a new attack starts even
when the voice was still gated. The data sheet says that attack rises from
whatever level the envelope had reached; it does not restart from zero.
Rate 0 is the fastest envelope rate, not an instant one: 2 ms attack and
6 ms decay or release at a 1 MHz clock, about 1.5% longer on a PAL C64.

Run the executable check with:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-c64 --output /tmp/sid-note
```

The emulator needs the C64 ROMs configured. The check builds three
programs from the include and boots each through the ROM with a typed
`RUN`:

- **ownership** aims the routines at a RAM copy of a voice surrounded by
  marker bytes, then checks which bytes change and that X and Y survive;
- **envelope** runs the routines on voice 3 and samples ENV3 ($D41C) to
  time the attack-0 rise, the release-9 fall from peak and a retrigger
  from a sustain level of $88;
- **demo** runs `demo.prg`, captures its audio and measures pitch, hold
  and release.

It also checks the assembler listing's byte and cycle counts for the three
routines. The retained [results](verification/evidence/results.json) give
source, program and emulator hashes and the measured values;
[baseline](verification/evidence/baseline.json) identifies the page this
replaced. Regenerate results when the routines change. The retained run
used Emu198x at commit `bfdea4bd`.

Emulator observations, not hardware facts: in Emu198x the first attack
began 32.6 ms after the gate was set, because its reSID-derived rate
counter had to wrap before the new rate matched; a repeated write of a set
gate did not start another attack; writing $D418 produced a brief click
before the note. None of these has been measured on original hardware.
Listening is a separate human check.

Hardware sources: MOS Technology, *6581 Sound Interface Device (SID)* data
sheet (register descriptions, gate behaviour, Table 2 envelope rates), in
`reference/by-topic/sid-6581/mos-6581-datasheet.txt`; Commodore, *Commodore
64 Programmer's Reference Guide* (1983), PAL system frequency 0.98525 MHz.
