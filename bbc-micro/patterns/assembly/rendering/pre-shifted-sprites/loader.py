"""Pack the original MODE4 caller below its reserved machine-code address."""

from pathlib import Path


def lines(data: bytes) -> list[str]:
    result = [
        "10 MODE 4",
        "20 HIMEM=&4000",
        "30 P%=&4000",
        f"40 FOR I%=1 TO {(len(data) + 63) // 64}",
        "50 READ A$",
        "60 FOR J%=1 TO LEN(A$) STEP 2",
        '70 ?P%=EVAL("&"+MID$(A$,J%,2)):P%=P%+1',
        "80 NEXT J%:NEXT I%",
        "90 CALL &4000",
    ]
    for i in range(0, len(data), 64):
        result.append(
            f'{100 + i // 64 * 10} DATA "' + data[i : i + 64].hex().upper() + '"'
        )
    return result


if __name__ == "__main__":
    root = Path(__file__).resolve().parent
    (root / "build/loader.bas").write_text(
        "\n".join(lines((root / "build/demo.bin").read_bytes())) + "\n"
    )
