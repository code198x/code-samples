#!/usr/bin/env python3
"""Type a ZX Spectrum BASIC listing in through the keyboard, key by key.

`capture.py` installs a program with `load_basic_program`, which pokes it
straight into memory. That is the right thing when the program is the
subject. This module exists for the case where the *typing* is the subject:
the machine sits at its own K prompt and the listing appears the way it did
in 1982, one keypress per keyword.

That is not a matter of sending characters. A 48K Spectrum gives a whole
keyword from a single key, but only in the right cursor mode, so `PRINT` is
one press of `P` at a statement start, `AT` is Symbol Shift and `I`, and
`INK` is Extend followed by Symbol Shift and `X`. Send the letters of
"PRINT" instead and you get `PRINT` followed by `RINT`.

So this reads an ordinary `.bas` listing, finds the keywords, and emits the
chord each one actually needs. Text inside quotes is left alone, because a
string containing the word "TO" is not a keyword.

    from typewriter import script_for
    steps = script_for(open('welcome.bas').read())

The result is a list of Emu198x `--script` steps, ready to concatenate with
whatever boot and capture steps the caller needs.
"""

import re

# One keypress at a statement start, where the cursor is in K mode. A colon
# returns the cursor to K mode, so these work mid-line after one too.
K_MODE = {
    'PRINT': 'P', 'FOR': 'F', 'NEXT': 'N', 'BORDER': 'B', 'PLOT': 'Q',
    'DRAW': 'W', 'LET': 'L', 'CLS': 'V', 'GO TO': 'G', 'RUN': 'R',
    'PAUSE': 'M', 'REM': 'E', 'INPUT': 'I', 'POKE': 'O', 'IF': 'U',
    'NEW': 'A', 'SAVE': 'S', 'DIM': 'D', 'GO SUB': 'H', 'LOAD': 'J',
    'LIST': 'K', 'COPY': 'Z', 'CLEAR': 'X', 'CONT': 'C', 'RETURN': 'Y',
    'RANDOMIZE': 'T',
}

# Symbol Shift plus a key, anywhere in a line.
SS_CHORD = {
    'AT': 'I', 'TO': 'F', 'STEP': 'D', 'THEN': 'G', 'NOT': 'S',
    'AND': 'Y', 'OR': 'U',
}

# Extend, then the bare key: the green word printed above it.
EXT_PLAIN = {
    'INT': 'R', 'RND': 'T', 'SIN': 'Q', 'COS': 'W', 'TAN': 'E',
    'ABS': 'G', 'SQR': 'H', 'LEN': 'K', 'PEEK': 'O', 'CODE': 'I',
    'PI': 'M', 'VAL': 'J', 'SGN': 'F', 'EXP': 'X', 'LN': 'Z',
    'STR$': 'Y', 'CHR$': 'U', 'INKEY$': 'N',
}

# Extend, then Symbol Shift plus a key: the red word on the key.
EXT_CHORD = {
    'INK': 'X', 'PAPER': 'C', 'FLASH': 'V', 'BRIGHT': 'B',
    'OVER': 'N', 'INVERSE': 'M',
}

# Longest first, so GO SUB is not read as GO, and INKEY$ not as INK.
_KEYWORDS = sorted(
    set(K_MODE) | set(SS_CHORD) | set(EXT_PLAIN) | set(EXT_CHORD),
    key=len, reverse=True,
)
_PATTERN = re.compile('|'.join(re.escape(k) for k in _KEYWORDS))

DEFAULT_HOLD = 3
DEFAULT_SETTLE = 25


def _chord_steps(word, hold):
    """The keypresses one keyword actually needs."""
    if word in K_MODE:
        return [{"action": "press_key", "key": K_MODE[word], "hold_frames": hold}]
    if word in SS_CHORD:
        return [{"action": "press_keys", "keys": ["SymbolShift", SS_CHORD[word]],
                 "hold_frames": hold + 1}]
    if word in EXT_PLAIN:
        return [{"action": "press_key", "key": "Extend", "hold_frames": hold + 1},
                {"action": "run_frames", "frames": 8},
                {"action": "press_key", "key": EXT_PLAIN[word], "hold_frames": hold}]
    return [{"action": "press_key", "key": "Extend", "hold_frames": hold + 1},
            {"action": "run_frames", "frames": 8},
            {"action": "press_keys", "keys": ["SymbolShift", EXT_CHORD[word]],
             "hold_frames": hold + 1}]


def steps_for_line(line, hold=DEFAULT_HOLD, settle=DEFAULT_SETTLE):
    """One listing line -> steps. The trailing newline presses ENTER."""
    steps, buf, i, in_string = [], '', 0, False

    def flush(settle_frames=8):
        nonlocal buf
        if buf:
            steps.append({"action": "type_string", "text": buf,
                          "hold_frames": hold, "settle_frames": settle_frames})
            buf = ''

    while i < len(line):
        ch = line[i]
        if ch == '"':
            in_string = not in_string
            buf += ch
            i += 1
            continue
        if in_string:
            buf += ch
            i += 1
            continue
        m = _PATTERN.match(line, i)
        if m:
            # The ROM prints its own spacing around a keyword token, so a
            # space typed next to one comes out doubled in the listing.
            buf = buf.rstrip(' ')
            flush()
            steps += _chord_steps(m.group(0), hold)
            steps.append({"action": "run_frames", "frames": 8})
            i = m.end()
            while i < len(line) and line[i] == ' ':
                i += 1
            continue
        buf += ch
        i += 1

    flush(settle_frames=settle)
    return steps


def script_for(listing, hold=DEFAULT_HOLD, settle=DEFAULT_SETTLE):
    """A whole listing -> steps. Blank lines and # comments are skipped."""
    steps = []
    for raw in listing.splitlines():
        if not raw.strip() or raw.lstrip().startswith('#'):
            continue
        steps += steps_for_line(raw + '\n', hold=hold, settle=settle)
    return steps
