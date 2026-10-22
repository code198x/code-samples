# Pattern language coverage

Snapshot: 22 October 2026. Companion to code198x/docs#117.

BASIC and assembly are separate implementations. A machine/topic with one entry
does not complete its other language routes. Keep FORTH and other existing
languages distinct too. A dash below means no dedicated entry in the topic
inventory, not that the language is impossible on the machine. An emulator probe
or a BASIC compiler needing qualification is not a finished library entry.

The published catalogue after samples #158 / website #919 contains 210 pages:
17 BASIC, 165 assembly, 27 conceptual/reference and one other cross-platform
entry. The next four entries in review add two BASIC and two assembly pages,
bringing authored coverage to 214. These are page counts, not capability
completeness or curriculum readiness.

## Loop column, with languages visible

| Machine | BASIC entry | Assembly entry |
| --- | --- | --- |
| Atom | entry present | new entry in review |
| BBC Micro | new entry in review | entry present |
| Electron | new entry in review | entry present |
| Amstrad CPC | entry present | new entry in review |
| Atari 2600 | — | entry present |
| Atari 5200 | — | entry present |
| Atari 7800 | — | entry present |
| Atari 800XL | — | — |
| ColecoVision | — | — |
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

- The first language gaps now have review implementations: Atom/CPC assembly
  character-command loops and BBC/Electron BASIC sampled-input loops. Their
  contracts distinguish delivered characters, physical new presses and pacing.
- Continue down the Loops column. The Atari console BASIC rows require a
  qualified compiler/runtime/load path before they can be marked covered.
  The next missing stock-language row is Atari XL (BASIC and assembly), followed
  by ColecoVision and the remaining language gaps. Do not hide those earlier
  console BASIC gaps when choosing a practical implementation tranche.
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
