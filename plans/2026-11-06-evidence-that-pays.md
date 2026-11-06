# Make pattern evidence re-record only when behaviour can change

**Status:** Agreed 2026-11-06. Steps run in the order below.

Pattern evidence costs more than it returns. Over two months, more than half
the re-recording work changed nothing a learner could notice. This plan keeps
the checks that found real bugs and drops the pinning that only forces
re-records.

## What the history shows

Every commit from 9 September to 6 November that modified an existing
verification record: 57 commits, 129 pattern re-records, counted by
[`2026-11-06-evidence-that-pays-rerecords.py`](2026-11-06-evidence-that-pays-rerecords.py)
(`python3 <script> <code-samples> <out.json>`). The 19 changed forced
re-records were classified by reading each commit.

| Re-records | Count | Changed an observation or capture |
|---|---|---|
| Forced only by script or tool changes | 55 | 19: deliberate measurement changes (11) and program changes the record didn't pin (8). **The other 36 changed nothing but digests and versions.** |
| With a source change | 74 | 40. **34 changed nothing**: the source text moved and the program's behaviour didn't. |

So **70 of 129 re-records (54%) recorded no new information.** No re-record
forced by an unrelated script or tool change ever changed an observation.

What did find bugs, on 5 November alone:

- **Comparing against the reference assembler** found 17 sources ACME 0.97 or
  PasmoNext 0.1.3 rejects. It also found 12 more `object-pool` sources, a
  silent `halt:` miscompile and Asm198x writing the wrong bytes for
  `NR = $0070` / `lda NR`.
- **Running checks on a newer emulator** found two real PET fixture bugs: a
  guard in mirrored screen RAM, and a character set that was never selected.
  These came from the checks *failing* on Emu198x 0.48.3. A digest pin didn't
  find them.

## The cost today

- 3,465 record files. 1,805 pin their sources' text and 1,668 pin scripts
  under `scripts/`, often scripts that don't make that record. The BBC Micro
  `object-pool` records pin `check-amiga-command-loops.py` and three
  `deadlines` scripts. One edit to a shared script invalidates every record
  that pins it.
- Tool pins in 31 `toolchain.json` files plus 62 hard-coded emulator
  versions in scripts (`"0.44.2"` in both the object-pool recorder and its
  checker).
- 165 recorders, each with its own arguments and tool layout (`--native`,
  `--tools` with numbered folders, `--firmware`), so mapping one changed file
  to the commands that re-record it is manual.
- 154 evidence jobs run on every pull request: none has a path filter.

## The rules after this change

1. **A record pins what decides its result:** the program's bytes, the tool
   identities (Asm198x and Emu198x release and binary digest), the firmware
   digests, and the observations and captures. It records the code-samples
   commit it was made at, for provenance. It stops pinning the text of its
   sources and of scripts.
2. **A record is stale when its program's bytes change.** The checker
   rebuilds each program with the pinned assembler and compares bytes with
   the record. A rename, a comment or a two-digit `$70` that leaves the bytes
   alone needs no re-record. A change that moves any byte fails until it is
   re-recorded. That is the same guarantee as today, measured on the thing
   learners run.
3. **One tool pin for the family.** A single `toolchain.json` at the root of
   code-samples names the Asm198x release and each Emu198x machine binary,
   with archive and binary digests and the producer lock, read by every
   recorder and checker. Machine choices that are not versions, such as the
   PET `commodore-pet-2001n-32k` and the 5200 `ca018087` board, stay with the
   pattern that needs them. No script names a version.
4. **Re-running against new tools is a job, not a re-record.** One command,
   `scripts/replay-evidence`, runs every recorder in check mode against the
   pinned or the latest tools and reports any observation that differs,
   without writing records. Most machines need private firmware, so it runs
   locally, where the firmware is. It can't run on GitHub's hosted runners.
   **Moving the pin runs it:** `scripts/update-toolchain.py` replays every
   pattern against the new tools and refuses to write the new pin while any
   observation differs and isn't re-recorded in the same change. The tools
   can't move without the replay having passed.
5. **CI runs what a change touches.** Each evidence job gets a `paths` filter
   for its recorder, checker, sources and records, and the root toolchain
   pin.

The reference-assembler verdicts (asm198x/asm198x#972) are unchanged and
become the guard against assembler drift. Every Asm198x pull request replays
the pattern library against each machine's reference assembler.

The altered-evidence controls, which tamper with a record and expect the
checker to reject it, stay as they are. They test the checkers and never
force a re-record, so they cost little.

## Steps

Each step is one pull request. Every record's observations stay as they are,
so the history above stays comparable. The byte check goes first: until it
lands, the edits the toolchain pin makes to every recorder and checker would
make the 1,668 records that pin those scripts stale.

1. **Byte check instead of text pins.** Teach the shared checker helpers to
   rebuild a record's program and compare bytes, and stop comparing `sources`
   and script digests. Leave the fields in existing records as provenance
   until each family next re-records. *Check:* reverting today's two-digit
   `ptr=$70` fix still passes, because the bytes match, while changing an
   operand fails.
2. **Root toolchain pin.** Add `toolchain.json`, generated from the release
   locks by a committed `scripts/update-toolchain.py`, with
   `scripts/fetch-toolchain.py` to download and verify. Point every recorder
   and checker at it, delete the 31 family files and the 62 hard-coded
   versions. *Check:* every checker still passes, and grepping `scripts/` for
   a version literal finds none. The script refuses to move the pin until
   step 3's replay exists and passes, so step 3 lands before the next pin
   move.
3. **`scripts/replay-evidence`.** Read each family's recorder from an index
   (recorder, arguments, machines), run in check mode, and print any
   differing observation. *Check:* it reports today's PET failure against
   the old fixtures on Emu198x 0.48.3, and reports nothing on `main`.
4. **Path filters** on the 154 evidence jobs, generated from the same index.
   *Check:* a pull request touching one pattern runs that family's job and
   no other.
5. **Update the record.** Add the rules above to
   [`pattern-library.md`](https://github.com/code198x/docs/blob/main/specifications/pattern-library.md)
   in docs, where pattern evidence belongs, and point `website.md`'s *Code
   and artefacts* at it.

## Decisions for Steve

- **Agree the rules** in *The rules after this change*, especially rule 2:
  bytes, not source text, decide staleness.
- **Where the replay runs:** *agreed 2026-11-06* — locally, enforced by the
  pin-update script (rule 4). A nightly self-hosted run would also catch
  drift between releases, but it needs a runner kept up and the firmware on
  it. Revisit only if the gated pin move proves too slow to catch
  something.
- **The Game Boy `--tiny` change:** *settled 2026-11-06.* It landed under
  the current rules (code198x/code-samples#426): 13 records re-recorded for
  eight ROMs that were byte-identical before and after. Step 2 would have
  needed none of them.
