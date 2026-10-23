# MSX deadline continuation

Two independent source/publication layers above Ace: assembly (docs#194), then BASIC (#195).

- `msx/patterns/assembly/framework/turn-deadline/*`: reuse shared Z80 countdown, BIOS JIFFY/CHSNS/CHGET/LDIRVM, keep USR register/stack and reserved RAM contracts explicit. Generated READ/POKE loader; native full payload equality before USR, six cases, twelve arithmetic and three policy fixtures, interpreter arithmetic after exit and a completion-marked VDP observer.
- `msx/patterns/basic/framework/turn-deadline/*`: reuse maintained Dragon 16-bit BASIC helper, independent TIME/INKEY$ wrapper and native tokenised-program/variable allocation. Six cases and wrong-equality oracle. Preserve untimed play.
- Add retained checkers/falsification tests and CI jobs per route. Extend generic Z80 evidence parsing without changing existing Dragon/Ace semantics; run all route gates.
- Add code-first MDX entries, pinned source/evidence, actual native captures, customisation, common failure, Maths and comparison links. Verify full site check/build, exact listings and images, internal routes and desktop/phone overflow, then native GitHub stack links #184/#974. Source-first CI dependency remains enforced. No merges.
