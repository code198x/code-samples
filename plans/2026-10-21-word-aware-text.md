# Word-aware text on bitmap displays

Continue docs #126 without changing the published fixed-width layout API.

1. Merge samples #149, rerun website #897 browser CI, merge its unchanged reviewed head only after every applicable check succeeds. Verify deployment and live page/image bytes.
2. Add `cross-platform/patterns/rendering/word-wrap/` and callers under Spectrum, BBC Micro, Dragon and CPC `patterns/assembly/rendering/word-wrap/`. Reuse bitmap text and its qualified backends. Keep input counted, line feeds explicit, and choose bounded greedy ASCII-space wrapping. Overlong words split at a character boundary so every accepted iteration advances. State whitespace, source ownership, atomic rejection and work costs.
3. Add independent model/cases plus `scripts/{verify,check}-word-wrap.py` and corruption tests. Exercise empty/maximal inputs, exact fits, repeated/leading/trailing spaces, LF, one-column panels, long words, last rows, unsupported codes and atomic overflow. Run all four released native emulators; compare complete bitmap memory, outputs, source/font/guards and captures. Include executable customisation and wrong/fixed examples. Keep existing retained evidence unchanged.
4. Add machine and comparison pages under `src/content/patterns/`, original verified captures, Maths links and desktop/phone built-page checks. Use CodeFromFile and existing layouts; no dependencies or schema changes.
5. Push small verified commits and create linked review PRs. Update #126 and the existing coverage matrix, distinguishing published work from review work. Inspect and remove task worktrees, tool caches and owned processes only after preserving commits and evidence.

No proportional fonts, scaling, Unicode shaping, text editor, new hardware claims or cycle-speed claims in this batch. Older-entry retrofits remain deferred.
