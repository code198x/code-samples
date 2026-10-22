# Pattern language coverage

Snapshot: 22 October 2026. Companion to code198x/docs#117.

BASIC and assembly are separate implementations. A machine/topic with one entry
does not complete its other language routes. Keep FORTH and other existing
languages distinct too. A dash below means no dedicated entry in the topic
inventory, not that the language is impossible on the machine. An emulator probe
or a BASIC compiler needing qualification is not a finished library entry.

The catalogue checkpoint through website #922 contains 214 pages: 19 BASIC,
167 assembly, 27 conceptual/reference and one other cross-platform entry.
The next Atari XL/ColecoVision slice adds one BASIC and two assembly entries
in review, bringing authored coverage to 217. Publication is tracked separately
from source and review status. These are page counts, not capability completeness
or curriculum readiness.

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
| Atari 800XL | new entry in review | new entry in review |
| ColecoVision | — | new entry in review |
| Amiga | — | entry present |
| C64 | — | entry present |
| PET | — | — |
| VIC-20 | — | — |
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
- Atari XL now has separate BASIC command and assembly sampled-input review
  implementations. ColecoVision assembly has a reusable BIOS-started, polled-VDP
  caller. Shared ancestry is not substituted for native execution.
- Earlier Atari console BASIC rows still need a qualified compiler/runtime/load
  path. ColecoVision BASIC remains separately unqualified too. These are visible
  gaps, not claims of impossible languages or hardware.
- The next stock-language row is Amiga BASIC-family coverage: existing AMOS and
  Blitz material offers a route to investigate, but each native runtime, loader,
  ownership contract and dialect must be named and independently qualified.
  Then continue C64 BASIC, PET and VIC-20 in row order. Preserve AMOS/Blitz
  identities rather than presenting them as identical BASIC runtimes.
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
