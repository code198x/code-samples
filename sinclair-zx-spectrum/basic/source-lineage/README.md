# Source lineage

The recorded evidence under each game's `verification/` names the SHA-256 of the listing it ran on. `lineage.json` links each of those earlier hashes to the listing now on disk, and gives the proof that the program is unchanged. The audits use it through `lineage.py`, so evidence stays as it was recorded and still binds to the current listings.

There are two kinds of link:

- **`space-only`** links remove stored spaces and change nothing else. The proof is the tokeniser check in `build.py`.
- **`renamed-variable`** links rename a variable as a whole word. The proof is a boot of both texts on the genuine 48K ROM.

`build.py` works out each link from git and the files on disk, then re-verifies it:

```sh
python3 build.py --tokeniser /path/to/tokenise_listing
```

The tokeniser is the `tokenise_listing` example of `format198x-sinclair-zx-spectrum-bas` 0.1.2. Build it in the format198x repository at the tag `format198x-sinclair-zx-spectrum-bas-v0.1.2`:

```sh
cargo build --release -p format198x-sinclair-zx-spectrum-bas --example tokenise_listing
```

Add `--write` to rewrite `lineage.json`. The file sits beside the audits it serves: every audit that reads it is under `sinclair-zx-spectrum/basic/`.
