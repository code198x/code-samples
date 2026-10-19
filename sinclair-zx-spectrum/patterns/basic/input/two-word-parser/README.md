# A two-word parser for Spectrum BASIC

Build a small adventure whose vocabulary you can change without rewriting its parser.
`make` joins `demo.bas`, `parser.bas` and `vocabulary.bas`, checks their listed form
with Build198x and produces `build/demo.tap`. Put Build198x on PATH or pass
`BUILD198X=/path/to/build 198 x`. Load the tape on a 48K Spectrum; it runs from line 10.
Use unquoted commands. Try GET LIGHT, GO NORTH, GO NORTH, TAKE KEY, GO NORTH.
The first attempt at the door fails; carrying the key opens it, and it stays open.
The parser recognises ROCK although the demonstration contains no rock object.

## Include, initialise, call

The reusable file is `parser.bas`; the vocabulary is a separate DATA file.
Merge both into your program, keeping line numbers unique:

```basic
  10 GO SUB 6000
  20 IF s<>0 THEN PRINT "Vocabulary error": STOP
  30 INPUT "> "; LINE a$
  40 GO SUB 5000
  50 IF s=0 THEN PRINT "Verb ";v;" noun ";n
  60 GO TO 30
```

6000 initialises the dictionary and returns s=0 or 10. It sets pr=0 before doing
anything and pr=1 only after validation. A subsequent parse after a failed init
returns 9. Calling 5000 in a cold BASIC environment before defining its variables
is an interpreter error: call 6000 first, even when reusing a saved game.
Initialisation consumes DATA from 7000; callers using their own READ statements
must RESTORE their own DATA before reading it.

5000 accepts a$ without changing it. Return values are s(status), v(canonical verb
ID) and n(canonical noun-concept ID, or 0 when absent). Both IDs are 0 on every
parse failure, even after a successful previous command. w$ and o$ hold normalised
word 1/word 2 for messages; on an early rejection they can be empty. They are not
word-index or source-span records. Copy anything you need before the next call.

## Grammar and errors

Only ASCII letters, digits and ordinary spaces are accepted. Lowercase folds to
uppercase. Repeated/leading/trailing spaces are ignored. A line has at most 63
characters and two tokens. Aliases are exact, with 1–12 characters; GETTER does not
match GET and LAM does not match LAMP. Numbers are vocabulary words, not numeric
arguments. Tabs, punctuation, quoted phrases and non-ASCII characters are rejected.
This grammar is a deliberate bounded starting point, not a claim about every
Spectrum character or every adventure parser.

The checks run in this order: initialisation, total length, all character values,
word count, verb lookup, verb argument policy, noun lookup. Thus a three-word line
returns 4 even if its first word is unknown. A LOOK with a second word returns 8,
not an unknown-noun error. Do not depend on an incidental branch order instead.

| s | Meaning |
|---|---|
|0|Recognised command; use v/n to dispatch|
|1|Empty or spaces only; ignore without consuming a turn|
|2|More than 63 characters|
|3|Unsupported character|
|4|More than two words|
|5|Unknown verb alias|
|6|Unknown noun alias|
|7|This verb requires a noun|
|8|This verb takes no noun|
|9|Initialisation failed/not ready|
|10|Invalid vocabulary, returned by 6000|

Do not advance time merely because parsing succeeded. LOOK might be free while
WAIT spends a turn. A known command can still fail the game's rules. The caller
owns turn policy, room state, inventory, visibility, object ambiguity and prose.

## Vocabulary data

7010 gives the number of verb aliases and noun aliases (not distinct IDs). There
are 1–32 verb aliases and 0–32 noun aliases. Each verb record is a string, ID and noun
policy:0 none,1 required,2 optional. Each noun record is a string and ID. IDs are
integers 1–255, in separate namespaces; aliases of one verb ID must share its
argument policy. Within a table the same spelling cannot occur twice.

For example `"GET",3,1` and `"TAKE",3,1` both dispatch action 3. `"LIGHT",1`
and `"LAMP",1` name the same noun concept. Add OPEN 17 and BOX 23 by editing counts
and adding records; wire action 17 into your game separately. Keep the existing IDs
if saved world data depends on them. The parser has no fixed set of English verbs.

Validation catches bad counts, spelling, IDs, policies and conflicting aliases.
It does not trap BASIC's own READ errors: missing records, wrong DATA types or a
missing DATA block can stop the interpreter. Those are authoring errors. The
supplied build/runtime checks should accompany vocabulary changes.

## Ownership and cost

Reserve 5000–5360,6000–6220,6500–6560 and 7000–7090, or renumber consistently,
including GO TO/GO SUB/RESTORE references. Do not simply paste colliding lines.
The parser is not reentrant and has no local-variable namespace. It owns numeric
scalars pr,s,v,n,ll,tc,wc,iv,ni,f,kk,jj,ok,nv,nn,i,p,b,q; strings w$,o$,t$; string
arrays d$ and e$; numeric arrays u,r,m,z,h. a$ is the caller's input. Numeric and
array variables with the same letter are distinct in Sinclair BASIC, but do not
reuse their state halfway through a parser call. The demo deliberately uses j
for its object loops. Sinclair FOR control variables must be single letters.

The two dictionaries use 12-character fixed rows, stored token lengths and numeric
ID/policy arrays. Lengths prevent padded strings or short prefixes becoming false
matches. The noun arrays allocate one spare row so an empty noun vocabulary is
legal. Initialisation compares earlier entries to detect duplicates; its cost
grows faster than a single lookup. Parsing scans the whole input before looking
up anything, then creates bounded temporary strings. BASIC string allocation and
variable lookup are real costs. This is a command component, not a per-frame
routine. Reuse the initialised tables until the vocabulary changes.

Build198x reports the stored full demonstration's byte count when building. That
is not parser working memory. No cycle count, constant response time or total
free-memory promise is made. The assembly companion uses a different storage
representation rather than pretending the interpreter's arrays are free.

## Game integration

The supplied original caller has three rooms and two physical objects. c(j) maps
an object index to a noun concept; l(j) is its room, or 0 when carried. Resolving a
noun considers both location and concept. If two visible/carried objects match,
it refuses to pick arbitrarily. An explicit ambiguity variation is checked; the
two-word demo cannot yet answer an adjective-based clarification.

GO understands direction concepts; TAKE/DROP resolve physical objects; the door
rule checks possession of a key and retains its unlocked state. These are game
rules, not parser features. The caller clears the display after each submitted
line, keeping the reply visible until the next submission instead of building up
a BASIC scroll prompt. LOOK refreshes the description. INPUT uses LINE after the
prompt so the player types text without quotation marks.

## Verification

From the samples root, run `python scripts/verify-adventure-parser.py --help` and
`python scripts/verify-adventure-callers.py --help`. Supply Emu198x, Build198x and
your own 48K ROM with their named arguments. The first compares actual ROM-loaded
BASIC results with independent rules, stale-output cases, invalid configurations,
custom and boundary dictionaries. A broken extra-word check must fail. The second
types into the unmodified adventure, verifies displayed text, checks a deliberately
ambiguous caller variation, and exercises the assembly editor. Firmware is never
included in evidence. Named-configuration execution is not hardware certification.
