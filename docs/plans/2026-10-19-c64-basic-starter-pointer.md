# Correct the C64 primer's BASIC next-line pointer (#106)

The user approved correcting the existing twelve-byte starter, preserving the
machine-code entry at $080d, regenerating affected programs and independently
checking the BASIC chain. No dependencies, new architecture or lesson rewrite.

Root cause: twenty maintained Meet the Machine sources explicitly encode
$080c as the next-line pointer, but the zero end marker begins at $080b. The
following opcode makes the word at $080c nonzero. SYS 2061 still starts the
checked border loop; successful execution did not validate the BASIC chain.
Both assemblers reproduced the source error. Independent VICE petcat emits
$080b for the same line without a separating space.

1. Reproduce the unchanged source with ACME and an independently tokenised
   `10sys2061` line. Retain a small hex fixture from petcat and its command.
2. Add `scripts/check-c64-starters.py` and `scripts/test_c64_starters.py`.
   Validate actual assembled PRGs: load address, parsed BASIC line/token/SYS
   entry, terminator, declared next line, end marker and code placement. Derive
   the boundary from the statement length instead of copying an expected
   pointer. Reject absent outputs and an empty source discovery. Tests include
   the original pointer, truncation and mismatched SYS entry.
3. Correct only the first byte of that exact starter in the twenty module
   sources. Build each with ACME and pinned published Asm198x 0.0.71; require
   identical outputs and unchanged code bytes after the starter. Integrate the
   checker/tests into the existing C64 build job after its builds.
4. Rebuild the website's staged unit-1 PRG with the same documented command its
   existing artefact script uses. The website deploy already checks out samples
   and rebuilds this artefact; do not commit ignored PRGs or unrelated website
   changes. After merge, the existing repository dispatch owns publication.
5. Run the corrected red/green programs through the existing public browser
   player's local-file path with local firmware; retain safe results
   without ROM/save bytes or local library paths in this public repository.
   Check actual pixels, not a Running label. Keep host/learner limits explicit.
6. Run focused tests, Ruff, format, builds and controls, commit/push the fix PR.
   Inspect hosted checks. Verify remote retention and clean task worktree,
   build outputs, downloaded tools and browser processes before completion.

## Verification

- Original ACME builds succeeded, while the new chain validator rejected all
  twenty originals. VICE 3.10 petcat supplied the independent regression prefix.
- Twenty corrected ACME/Asm198x 0.0.71 builds agree. Only PRG offset 2 changes;
  code after the starter, lengths and the $080d entry remain identical.
- All twenty corrected chains and all eight CLI regression tests pass.
- The website's existing older Asm198x 0.0.57 pin emits the same corrected
  unit-one PRG. No version bump, website code or committed PRG is needed.
- Corrected red/green candidate imports execute in Chrome with actual canvas
  observations, and both pictures were inspected. Safe records live in
  `commodore-64/assembly/meet-the-machine/verification/starter-repair/`.
  The site still served its old download during this local-candidate check;
  deployment and other hosts remain separate observations.
