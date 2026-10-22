# Extend the next Pattern Library columns

Build on reviewed source d385b67 and website aa57331 without merging them.

1. Reuse the checked map-query contract in BASIC on BBC Micro, Electron,
   C64, Spectrum and MTX. Keep their array bases and keyboard/load routes explicit.
   Files: each system's patterns/basic/rendering/tile-map/{routines,demo}.bas.
2. Extract a separately includable text-region routine for the ten existing
   BASIC map implementations and the five new ports. The output is a stream of
   text cells at the current cursor, not a positioned hardware tile backend.
   Retain the old samples unchanged; use new text-region folders for extraction.
3. Add bounded pixel/box BASIC implementations for BBC Micro, Electron, CPC and
   Spectrum, using each interpreter's graphics API and explicit coordinate units.
   Keep this separate from text-region coverage.
4. Verify source callers in released Emu198x. Compare complete decoded captures
   with independent literal outputs; exercise bounds, map stride, fractional
   indices, invalid writes, box corners and omitted/wrong drawing controls.
   Record source/observer/tool/firmware hashes, screenshots and exact limits.
5. Add CodeFromFile entries, common mistakes, customisation and Maths for Games
   connections. Check the website, build it and inspect narrow/wide routes.
6. Update the static coverage matrix and docs issue 117 from verified records.
   Push review PRs, retain dependency ordering and clean up owned resources.

Use existing dependencies and verification transport. No synthetic screen image
may substitute for an executed capture. No platform capability is inferred from
another language route. Native hardware Regions gaps remain visible.
