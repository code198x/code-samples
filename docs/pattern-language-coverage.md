# Pattern language coverage

Snapshot: 22 October 2026. Companion to code198x/docs#117.

BASIC and assembly are separate implementations. A machine/topic with one entry
does not complete its other language routes. Keep FORTH and other existing
languages distinct too. A dash below means no dedicated entry in the topic
inventory, not that the language is impossible on the machine. An emulator probe
or a BASIC compiler needing qualification is not a finished library entry.

The previously published catalogue contains 217 pages: 20 BASIC, 169 assembly,
27 conceptual/reference and one other cross-platform entry. Amiga AMOS and Blitz
add two independently qualified dialect entries: samples #161 is merged and
website #925 is awaiting its source-first browser CI rerun. This tranche adds
five more review entries (three BASIC, two assembly), for 224 authored pages.
Publication remains separate from source and review. These counts do not claim
capability completeness or curriculum readiness.

## Loop column, with languages visible

| Machine | BASIC entry | Assembly entry |
| --- | --- | --- |
| Atom | entry present | entry present |
| BBC Micro | entry present | entry present |
| Electron | entry present | entry present |
| Amstrad CPC | entry present | entry present |
| Atari 2600 | — | entry present |
| Atari 5200 | — | entry present |
| Atari 7800 | — | entry present |
| Atari 800XL | entry present | entry present |
| ColecoVision | — | entry present |
| Amiga | AMOS and Blitz entries in review, independently qualified | entry present |
| C64 | reusable command entry in review | entry present |
| PET | reusable command entry in review | reusable command entry in review |
| VIC-20 | reusable command entry in review | reusable command entry in review |
| Dragon | — | — |
| Jupiter Ace | — | — |
| Aquarius | — | — |
| MTX | — | — |
| MSX1 | — | — |
| Game Boy DMG | — | — |
| NES | — | entry present |
| Oric | — | — |
| Game Gear | — | entry present |
| Master System | — | entry present |
| SG-1000 | — | entry present |
| Spectrum | — | entry present |
| ZX80 | — | — |
| ZX81 | — | — |
| M5 | — | — |
| SVI-328 | — | — |
| Einstein | — | — |

Existing entries retain their individual evidence status. Inspect their own
sources and records; this table does not silently upgrade code to execution.

## Next gaps and applicability

- Atom/CPC assembly and BBC/Electron BASIC now have the source-first publication
  slice in #159/#922. Their delivered-character, physical-press and pacing
  contracts remain distinct.
- Atari XL now has separate published BASIC command and assembly sampled-input
  implementations. ColecoVision assembly has a reusable BIOS-started, polled-VDP
  caller. Shared ancestry is not substituted for native execution.
- Earlier Atari console BASIC rows still need a qualified compiler/runtime/load
  path. ColecoVision BASIC remains separately unqualified too. These are visible
  gaps, not claims of impossible languages or hardware.
- Amiga now has separate AMOS Professional 2.00 fresh-key and Blitz BASIC 2.10
  console-command entries in review. The latter uses Ted 1.1, not AmiBlitz/PED;
  no AmigaBASIC or other dialect coverage follows. AMOS qualification mounts its
  fixture from boot: the known hot-swap bug #1877/#1881 remains visible.
- C64 BASIC, PET BASIC/assembly and unexpanded PAL VIC-20 BASIC/assembly now
  have reusable command-loop review entries with separately executed callers.
  Existing PET/VIC probe demos and their records remain unchanged.
- Continue with Dragon and Jupiter Ace in row order, including their distinct
  BASIC/assembly/FORTH routes where applicable. An AMOS entry does not complete
  Blitz; a firmware probe does not complete a library entry.
- BASIC loops on machines with existing assembly entries remain gaps too.
  Reuse lessons and probes, but supply usable entry contracts and qualification.
- The console assembly callers do not rule out BASIC cross-compilers. A useful
  BASIC route must identify its compiler, runtime/kernel ownership, load path
  and verification before it receives a coverage claim. No new compiler or
  dependency is commissioned by this snapshot.
- Stock firmware, a cross-compiled language and an interpreted cartridge are
  different environments; name the one actually used. Preserve machine-specific
  limits instead of imposing one language or framework across every target.

Work by topic and machine, checking language gaps explicitly. Shared concepts
may link implementations; they do not replace either implementation.
