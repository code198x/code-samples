# Remaining machine probes

Continue the 30-machine target after nine qualified configurations. Keep input-driven loops distinct from timer/frame tests.

1. Read each remaining native launcher/profile and retained boot/input tests. Build the 21 native binaries under `/tmp/pattern-fleet-native`; builds establish no program evidence.
2. Reuse existing firmware keyboard/loader paths for small input-driven callers. Store sources and integration contracts under each machine's `patterns/<language>/framework/` directory. Derive reserved memory and firmware entry points from the named machine's documentation, not its CPU.
3. Qualify one state transition per accepted command and unchanged rule state without a command; verify output and repeatability. Add separate timing only where the caller needs it. Use altered programs to prove guards fail.
4. Qualify console cartridges separately, keeping display generation/servicing distinct from game progression. Reuse existing authored guest fixtures where their contracts fit. Any execution failure remains a failed attempt with its cause/unknown stated; never upgrade a build to qualified.
5. Extend `docs/probe-coverage.{json,md}` and `scripts/check-probe-coverage.py` only when records support the change. Recheck source identities and registry joins; preserve the nine existing records.
6. Push self-contained verified changes to the existing sample PR; update guidance/site only for qualified implementations. Preserve evidence under the chat outputs and clean this worktree/build before finishing.

## Atom input regression found during qualification

- Symptom: ordinary spaced BASIC stores `$09` at each typed space and fails with `ERROR 94`; removing spaces runs. Reproduced with base and full models. Program memory confirms the input substitution, not a missing-RAM theory.
- Reference: Atomulator `src/8255.c`, row 9 column 0 is Space; current Emu198x maps `AtomKey::Space` to row 0 column 0.
- Fix in `Emu198x/emu198x`: change only `crates/machine-acorn-atom/src/input.rs` and add `tests/keyboard_space.rs` in that crate. First run the ROM-backed input preservation regression on unchanged code and observe it fail; then correct the mapping, rerun and check Clippy/format plus the actual command caller.
- Lane: engineering-frontier validation. No chip, CPU, clock, dependency or public API changes. Preserve emulator fix on its own branch/PR and qualify the Atom caller against its exact fixed binary.
