# Source lineage

The recorded evidence under each game's `verification/` names the SHA-256 of the listing it ran on. `lineage.json` links each of those earlier hashes to the listing now on disk, and gives the proof of what changed. The audits use it through `lineage.py`, so evidence stays as it was recorded and still binds to the current listings.

There are two kinds of link:

- **`space-only`** links remove stored spaces and change nothing else. The proof is the tokeniser check in `build.py`.
- **`renamed-variable`** links rename a variable, and nothing else. `build.py` checks that each variable is renamed as a whole word, in code only (never inside a string or a REM), and that the new name was not already in use, so no two variables merge. The evidence harnesses type each program in on the ROM keyboard, which stores the old name as a variable too, so the evidence ran the same program under the other name. Each link's `rom_boot` field records a different test: a tape built from the old text stopped with a report because the tokeniser read the name as a keyword, and a tape of the new text ran. It shows the rename fixed the tape build; it does not prove that the two texts are equivalent.

`build.py` works out each link from git and the files on disk, then re-verifies it:

```sh
python3 build.py --tokeniser /path/to/tokenise_listing
```

The tokeniser is the `tokenise_listing` example of `format198x-sinclair-zx-spectrum-bas` 0.1.2. Build it in the format198x repository at the tag `format198x-sinclair-zx-spectrum-bas-v0.1.2`:

```sh
cargo build --release -p format198x-sinclair-zx-spectrum-bas --example tokenise_listing
```

Add `--write` to rewrite `lineage.json`. The file sits beside the audits it serves: every audit that reads it is under `sinclair-zx-spectrum/basic/`.

When a listing is edited and its evidence recorded again, remove that listing's links from `lineage.json` and run `build.py --write`, because the new evidence names the current hash directly.

The audits read earlier texts from git (volley's `lessons.py` does), so run them in a checkout with the full history, not a shallow clone or an archive.
