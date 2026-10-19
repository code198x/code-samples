# BASIC starter repair verification — 19 October 2026

All twenty primer sources were rebuilt with published Asm198x 0.0.71 and
ACME 0.97. Each pair agrees byte-for-byte. Compared with the corresponding
original build, only PRG byte offset 2 changes, from $0c to $0b. Machine code,
file length and the $080d entry are unchanged. The original twenty programs
all failed the new BASIC-chain validator; the corrected twenty all pass.

`rebuild.json` retains source/output hashes and those comparisons. The existing
website artefact script's older default Asm198x 0.0.57 pin also produces the
same corrected unit-one program. The rebuilt PRGs are ignored build outputs,
not committed files. The existing website deployment rebuilds unit one from
these maintained sources after the samples change reaches main.

The regression fixture in `scripts/fixtures/c64-sys-2061.hex` came from VICE
3.10 petcat, independently of the assembly sources. Eight standard-library
unit tests include the original bad pointer, truncated data, mismatched SYS,
missing output and empty discovery. The existing C64 CI build job runs both
the tests and the checker on its freshly built primer PRGs.

`browser.json` and the inspected red/green pictures retain a separate automated
Chrome 155.0.8059.80 / macOS ARM64 check of the repaired first program. Through
the public lesson's existing player and local-file controls, each corrected
PRG boots with local firmware and executes after RUN. Canvas pixel (8,8) is
[136,57,50,255] for red and [85,160,73,255] for green. Insertion alone leaves
the prior loop running; Restart and RUN start the replacement. Missing-firmware
guidance and close/focus recovery also pass. Firmware bytes and save files are
not retained; only firmware hashes and lengths appear in the record.

The browser's fetched lesson PRG was still the previously published program;
the repaired programs were selected locally. This is not a claim that the fix
is already deployed. The record's module hashes identify the serving player,
not a complete deployed Git/source lock. Outbound POSTs were blocked and the
fresh browser context closed; no device firmware persistence was requested.

These are dated repair observations, not automatic qualification of future
source/tool changes. Only the first program and its colour edit were executed
in this browser check. Other primer programs were assembled and structurally
validated. No disk/tape fidelity, NTSC, other host, listening, physical touch,
screen-reader, original-hardware or learner-understanding claim is added.
