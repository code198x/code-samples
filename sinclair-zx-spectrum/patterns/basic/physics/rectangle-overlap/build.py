import os
import subprocess
from pathlib import Path

F = Path(__file__).parent
B = F / "build"
B.mkdir(exist_ok=True)
for name in ("demo", "custom", "wrong", "repaired"):
    caller = (F / "caller.bas").read_text()
    if name != "demo":
        caller = caller.replace(
            "LET bl=6: LET by=4: LET br=11: LET bb=7",
            "LET bl=8: LET by=2: LET br=13: LET bb=6",
        )
    helper = (F / "overlap.bas").read_text()
    if name == "wrong":
        helper = helper.replace(
            "al>=br OR bl>=ar OR ay>=bb OR by>=ab", "al>br OR bl>ar OR ay>bb OR by>ab"
        )
    text = "".join(
        f"{int(n):4d} {body}\n"
        for n, body in (
            line.split(maxsplit=1) for line in (caller + helper).splitlines()
        )
    )
    (B / (name + ".bas")).write_text(text)
    subprocess.run(
        [
            os.environ.get("BUILD198X", "build198x"),
            "basic",
            str(B / (name + ".bas")),
            "--machine",
            "sinclair-zx-spectrum",
            "-o",
            str(B / (name + ".tap")),
        ],
        check=True,
    )
