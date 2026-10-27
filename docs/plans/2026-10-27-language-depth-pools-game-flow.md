# AMOS, Blitz and Ace pools and game flow

This implements the authorised language-depth tranche after the original website stack, final live checks and positive issue reconciliation complete. Produce source and website PRs for review only. Do not merge them. The existing object-pool and pools-and-states plans supply the behaviour; do not add separate checkpoint or clock features.

## Scope and workspaces

Use clean task workspaces on actual merged source/site main. Preserve the existing publisher workspaces until final publication verification finishes. Before any source edit, copy this plan into each repository's `docs/plans/` and consult its current rules and decisions. Recheck the six target paths against current main. They were positively inspected and absent at source734324e8 and website11d2acac; that does not establish absence from every lesson or a later revision.

Implement two topics, `object-pool` and `game-flow`, under each of:

- `commodore-amiga/patterns/amos/framework/`
- `commodore-amiga/patterns/blitz/framework/`
- `jupiter-ace/patterns/forth/framework/`

Website counterparts are the six matching `src/content/patterns/<machine>/<language>/framework/<topic>.mdx` paths. Use the existing catalogue/schema. Do not change lessons, dependencies, the publisher, or runtime architecture.

## 1. AMOS: qualify one topic before the next

For each topic, maintain `routines.amos`, `caller.amos`, `custom.amos`, `wrong.amos`, `repaired.amos`, `boundaries.amos`, `build.py`, `Makefile`, `README.md` and `verification/`. ASCII source is imported into AMOS Professional; do not describe an ASCII file as a saved tokenised AMOS program. Keep the small usable caller separate from generated diagnostics. Reuse existing import phases and transport with a fresh source-bound fixture.

Keep allocation in the caller and use native integer arrays/scalars. Account for inclusive DIM bounds. Component init clears its own occupancy/state only; it must not erase caller payload or initialise hardware. Give routines reserved names and state the non-reentrant ownership and normal GOSUB effects.

## 2. Blitz: independent typed implementation

Use the same topic file roles with `.bb2` sources, explicit long types and typed READ/DATA. Reuse original Ted ASCII insertion and native compile/run phases, with fresh program/media identities. Validate actual compiled execution and resource use; a generated ASCII file is insufficient. Keep window, bank, input and cleanup responsibilities in the caller. Do not inherit AMOS array layout or observer sizes.

## 3. Ace: small definitions with measured headroom

For each topic maintain `routines.fth`, `caller.fth`, `customise.fth`, `boundaries.fth`, `mistakes/`, `README.md` and `verification/`, following existing Ace source-entry conventions. State every word's stack effect, preserve values below arguments, balance the return stack on every return, and separate byte storage from two-byte cells. The original Ace manual forbids EXIT inside DO/LOOP; LEAVE takes effect at the following LOOP. Use a bounded BEGIN loop for early pool-search completion or finish the DO loop before returning; do not import an unsupported UNLOOP/EXIT idiom. Caller-created storage must remain valid while selected. No RAM injection or substitute firmware.

Measure HERE before/after each component and caller, dictionary/data-stack/CPU-stack positions during execution, and the remaining separation on the unexpanded machine. If a proposed combined observer does not fit, reduce the diagnostic workload per independent boot; do not silently increase RAM or weaken checks. Do not transfer any previous map/deadline byte count to these definitions.

## Contracts and independent cases

Pool: retain the lowest-free-slot policy, explicit full result, prevalidated release, rejected double/out-of-range release, stable indices while occupied and caller-owned payload. Qualify capacities four and eight plus the single-slot boundary. Exhaust occupancy masks for the qualified capacity, inspect every flag/payload/guard after each operation, fill to exhaustion, release/reacquire and run the optional lifetime pass without spawning inside it. Explain that released indices can become stale and that generations are outside scope. A wrong caller omits release; reacquisition then fails. The repaired caller restores the normal release path. Validate capacity/allocation contracts in the native language before computing an address; document unsupported domains explicitly.

Game flow: TITLE0, PLAY1, OVER2, PAUSED3; START1, PAUSE2, LOSS4, RESTART8. LOSS wins PAUSE; OVER/RESTART wins START. One decision per update, with no fall-through into the new state's simulation. CHANGED is an entry pulse; FRESH requests the owner's reset only on title/start or over/restart. Resume preserves session payload and input history. Invalid state or event bits preserve state and clear pulses with an explicit error result. The new native-language event domain is explicitly 0..15: reject wider or negative values before policy lookup. The old byte oracle mask `events & 240` alone is insufficient for AMOS/Blitz integers or Ace cells; include 256 and wider-bit counterexamples. Independently cover all 64 valid state/event pairs, all 252 remaining byte-valued states, upper event bits, negative and wider numeric boundaries where the language exposes them, simultaneous events, repeated/held logical events, pause/resume, loss and restart. The wrong owner resets on every entry to PLAY; the resumed session exposes the error. Custom health five versus three changes data only. This is logical-event qualification, not a new physical keyboard-reader claim.

Use existing topic-local verifier/checker/test conventions with independent host expectations. Reuse transport and pixel decoding rather than adding a general framework. Record full source/imported or compiled identity, guest-owned traversal, positive completion, complete state and guards, and actual native pixels. Corrupt code/source pins, results, completion, costs and captures to prove rejection. Keep firmware-bearing snapshots private.

## Review and publication

After each independently passing topic, commit through normal hooks and push completed work. Group the two topic commits by language into a bounded source PR and matching website PR, preserving source-first dependencies. Attach every new PR to this chat. All six routes need usable inclusion/init/calls, exact state/resource ownership, measured helper versus caller/observer costs, useful customisation, observed wrong/fixed behaviour and restrained Maths/Craft links.

Pages include maintained code through CodeFromFile and source pins. Do not imply the current publisher offers compiled downloads for ASCII/FORTH files. Run existing source checks and meaningful negative controls, complete fresh website check/build/publishing gates, and desktop/phone development and built checks for all six routes, listing/capture identities, discovery and overflow. Retain full evidence and report limits. Stop before merging the new PRs.

## Cleanup

Track each new workspace, private fixture, generated diagnostic directory and process. Before removal inspect tracked/untracked/ignored contents, verify remote retention of all unique commits, preserve evidence, stop owned processes, and use normal worktree removal. Keep unrelated edits and unknown historical workspaces intact.

## AMOS pool physical contract
Single configured pool, capacities1..8 with caller DIM PL_OP_LIVE(8); element8 is diagnostic guard outside all supported capacities. PL_OP_CAP is init input; PL_OP_SIZE is private configured count, zero before successful init. INIT clears occupancy only; invalid capacity disables context without array writes. ACQUIRE returns lowest free PL_OP_SLOT and PL_OP_OK1; full returns slot=size/OK0/error0. RELEASE validates index before subscripting, returnsOK1 on release, error2 on invalid/free slot. Invalid context error1. Payload/lifetimes remain caller-owned. Scan completes its bounded FOR loop before RETURN to avoid interpreter loop-stack leakage. Native complete mask/guard/invalid/single/custom/wrong/repaired/resource checks remain mandatory before any passing claim or PR.

## AMOS game-flow physical contract
Six native integer fields PL_GF_STATE/EVENTS/CHANGED/FRESH/ERROR/NEXT; single owner, no arrays/hardware/clocks. INIT clears context only. STEP validates state0..3 first, events0..15 next, clears pulses/error before validation, preserves invalid state/event input, ERROR1/2. NEXT holds one selected transition until final commit so no fall-through. Caller runs old-state score update first, then applies FRESH-only session reset; preserved held history computes logical byte-edge events. Wrong owner resets on every Play entry. Native byte table plus signed/wide events256/512/65535/extremes and full private state/payload observations required before qualification.

## Full native integer observability
Retain the successful768case80byte baseline before strengthening the observer. Component unchanged. New248byte records preserve full32bit integer flags and payload for all9allocated elements at INIT/acquire/release/repeat/invalid stages, plus unchanged signed invalid-slot input. This closes byte-truncation blind spots. Full190468byte observer bank is diagnostic-only, not helper RAM. Independent model and row/globalguards/pixels must agree. Falsify high flag/payload bits as well as low bytes.

## Signed minimum without an out-of-range positive literal
Preserve the passing AMOS game-flow proof before adding extremes. Build the signed minimum at runtime by assigning -2147483647 then Dec once; do not ask the original parser to represent positive2147483648 first. Five separate source-bound records observe MIN state and MIN events in each valid state, preserving all context/payload/guards. A separate native fixture avoids confusing prior positive records with the new source pins. Requalify the final complete inputs before commit.

## AMOS pool signed minimum
After preserving positive lifetime and caller proof, add six separate records: MIN capacity init, MIN configured extent acquire/release, and MIN release index at capacities1,4,8. Construct the selected field with Dec from -2147483647 before calling the unchanged helper. Observe complete context/arrays/guards; then rebuild one final source-bound fixture and requalify every variant before commit.

## Blitz physical implementation before code
Verified existing turn-deadline and tile-map sources use explicit long globals/arrays (`Dim NAME.l(upper)`), dot-prefixed labels, Gosub names without the dot, EndIf, completed For/Next loops, typed Data.l/Read and WbToScreen/Window ownership in the caller. The new framework/object-pool and framework/game-flow paths are positively absent in the task workspace. Use the agreed bounded contracts with six reserved PL_OP_ or PL_GF_ long fields; pool caller allocates nine long occupancy elements and owns payload/lifetimes. Return only after any search loop completes. Validate signed context/index/event domains before subscript/policy. Use original Ted compile/run phases in a fresh private fixture and independently measure native long arrays/scalars and diagnostic banks. Keep small caller window within the already used420x180 geometry; explicit row positions must fit all capacity8 outputs. Do not infer instruction, heap, stack or bank sizes from AMOS proof. No Blitz code/native pass is claimed by this preparatory inventory.

## Blitz complete-state diagnostic before its first native run
Add framework/game-flow/oracle.py and observer.bb2, plus a cases variant in build.py, before preparing fresh original Ted fixture media. A literal independent4x16table covers64valid transitions,252invalid byte states,4signed/wide states,40invalid event pairs and5constructed MIN cases:365 full48byte signed-long records. Construct MIN by subtracting1 from -2147483647 in the selected guest field. The owner creates InitBank0 with17528bytes: all records plus two final long guards. Each record preserves full context and owner score65537/health5/history3. Print count/status/address/BankSize and a native font row; require every byte, completion, pixel and source identity before qualification. This is independent from the active Blitz pool caller run; do not change that topic or its fixture while active.

Before the first Blitz game-flow fixture, include one nonzero-seeded INIT observation in addition to the365 STEP rows. Seed state3/events15, pulses/error77 and NEXT91; INIT must zero all six fields while leaving owner payload unchanged. This makes missing INIT assignments observable rather than relying on a blank compiler context. Total366records/17576bankbytes, with explicit operation field in typed DATA.

## Bound Blitz diagnostic DATA to the original compiler object buffer
The original Ted successfully compiled all five small game-flow owners, but the366row diagnostic displayed Not Enough Object Memory Available. Keep the unchanged A1200/noFast and original compiler defaults. Split only diagnostic DATA into six independent imports of at most64rows (64,64,64,64,64,46), using the existing successfully compiled64case map diagnostic as the bounded precedent. Preserve all366cases and exact order. Each native bank has its own row/global guards; compare each full packet, source identity, count/allocation and last Changed pulse, then require all six unique chunks and concatenate their record bodies against the complete independent model. Missing, duplicate or swapped chunks must fail. Preserve five positive caller records and the actual failure capture before source changes; requalify the final complete inputs. No helper or small caller policy changes, no compiler memory-setting or RAM increase.

## Blitz full pool observations before implementation
Preserve all six positive small-owner sources/records/captures before extending qualification inputs. Add object-pool/oracle.py and observer.bb2, independent of the AMOS byte layout. Generate capacities1,4,8 and masks0..255 with compact native nested For loops rather than hundreds of DATA rows, preserving original Ted defaults. Each496byte record contains capacity/mask/bad-index as3longs; five96byte snapshots of all6contextlongs plus9occupancy and9payloadlongs after init/acquire/release/repeat/invalid-release; then a4byte rowmarker. Twelve distinct long header/snapshot fields must not be truncated. Include two final long guards;768records require380936bytes in a diagnostic bank, not helper storage. Native observations must establish loop-scratch semantics before trusting an independent model; do not change helper to match a guess. Wrong diagnostic omits the first release; repaired restores it. Full sentinels/invalidindex/doublefree/payload/allunusedflags/guard remain observable. Use arithmetic MOD and integer shifts via division for masks, following original compiled code conventions. Keep six small owners unchanged. After all full/boundary/lifetime/MIN inputs exist, prepare a fresh source-bound fixture and requalify all variants; initial small proof remains retained baseline. Add meaningful packet/model/pixel/identity controls, README and CI only after real compiler/runtime completion. No dependencies, memory-setting increase or newarchitecture.

## Blitz invalid domains and lifetime before final fixture
First complete768row original-compiled observer matched all380936bytes, including PL_OP_I==capacity after complete For/Next. Retain this positive source snapshot before extending inputs. Add boundary_oracle.py and boundaries.bb2:46normal boundary rows plus6separate constructed-MIN rows,116bytes each (fourinputlongs,all6contextlongs,9occupancy+9payloadlongs,guard), two final long guards. Boundarybanks5344 and704bytes are Blitzspecific; seedprivateI91 toobserveinvalidpaths preserving scratch. MINassignedfrom-2147483647andsubtract1 inguest, neverparsepositive2147483648. Add age_oracle.py/age.bb2:threepasses, full6contextlongs+fourownerresultlongs+three9longarrays+marker=152bytes perrow,464bytebankwithtwofinalguards;callerownsLife1/2/1/3/spawnafterfirstcompletepass. Preserveall9elementunused/guard/payload65537values. Fullworking/wrong/repaired observers plus6smallowners/boundaries/extremes/age require freshfinal12programfixture andallnativeimportqualification before retainedchecker/README/CI/commit. Nohelper/smallownerpolicychange ormemoryincrease.

## Ace game-flow physical words before code
Independent workspace starts on freshly fetched actual merged source734324e8, not AMOS/Blitz preview. Implement game-flow first with six16bitcellvariables GS(state),GE(events),GC(changed),GF(fresh),GX(error),GN(private next), GINIT(--),GSTEP(--). Validate unsigned GS<4/GE<16 so negative/high-bit cells reject before decision. Preserve lower stackvalues; explicitEXITonlyoutsideDO/LOOP, no newreturnstackmanipulation. UseoriginalmanualAND/OR/XOR/U< ratherthanINVERT/modernFORTHassumptions. Owner variables GP(previous-held),GV(score),GH(startinghealth),GL(currenthealth),GR(resets), plusboundedrecordedresumed/finishedonlyifnativeheadroompermits. GTICK(held--) computesfreshheld&(heldXORprevious), storesprevious, simulatesoldPlay, callsGSTEP, thenGRESETpolicyrequestsFRESH-onlyreset. GNEW(--)initssessionowner. GRESET(--flag)separatewordbeforecompilingcaller;wrongresetsFRESH orCHANGED&&PLAY;repairreloadsnormalpolicyafterreset, notlaterebinding. Custom5GH! vs3GH!. Smallcaller useslogicalevents, no physicalkeyboardreaderclaim. Provideplainmaintainedwordstackeffects/loadorder/sourceonlyASCIIbuild andgenerateddemo. BEFOREpassingclaim runactualstockROMkeyboardentry on3KiB, measureHEREpercomponent/caller/observer, RAMtop16384, data-stackemptyHERE+12, lowerstacktag77 throughallwords, CPUreturn-stackspacingthroughcalls. Nativeall64valid+252otherbytestates/negative/256/widercell/32768/65535/bothinvalid/statepriority, nonzeroseededINIT, upperbytes, heldtrace/resume/loss/restart,custom/wrongrepair. Splitdiagnosticbootsifdictionaryspaceinsufficient; neverincreaseRAMorFASTdisablechecks. ReuseexistingAcecapturecheckerfullscreen/fontpixels and transport; keepROMprivate. NoAceemulatorstartswhileBlitz25081active.

## First Ace resource failure and bounded owner reduction
OriginalROMfirstprobecompiled helper atHERE15952 (492bytes from15460) andresetpolicy15971 (+19), butERROR1 NotenoughmemoryoccurredduringGSHOW compilationbeforeGTRACE. This isactual3KiBdictionary/input-bufferlimit, nottransitionevidence. Preserveallsource/log/progress/finalscreen+privatesnapshot beforefirsttargetedfix. Keephelperand3KiBRAMunchanged. Removecompiled15ticktraceandtwoobservationvariablesGU/GDfromreusableowner; thosearetest/presentationoverhead. KeepfiveownerfieldsGP/GV/GH/GL/GR, GNEW/GTICKsamepolicy, compactGSHOWonlycurrentstate+score. Generateddemoissues15ordinaryinterpretedGTICKcommandsandGSHOWatresume/finish/restart;nativeverifiercapturesresumedscorebyquerybeforecontinuing, preservinglowerstacktag. Do notaddcompiledlargeobservertoprovokeanotherdictionaryfailure. MeasureHEREaftereachfileandbothsuccess/faultstackcontracts. Firsttargetedresourcefixonly; noRAMexpansion/FASTchecksdisable/helperpolicymutation. Ifanotherresourcefixfails, reassesssmallerscopethanrepeatedtweaks.

## Ace complete game-flow qualification before diagnostic code
CompactworkingownerfirstnativePASS (helper492/reset19/owner252dictionarybytes,HERE16223), prefix77/15-eventtraceoutputs4/2/1/2/3/6. Preservepositivecompactsource snapshotalreadyrecorded beforeextensions. Add independentliteral4x16oracle.py,366cases:64valid,252otherbytestates,7signed/widecellstates,40invalid-eventpairs,2bothinvalidpriority,1nonzeroINIT. Interpretallstoredcells modulo65536;negativeinputtextandpositivealiasareseparatesyntaxobservations, not32bitAceclaims. Defineboundaries.fth diagnostic-only OA/OB/OCpayload65535/32768/3, ODcompletioncounter, OEwaitflag;GSEED(stateevents--),GCASE(stateevents--),GICASE(stateevents--),GLOOK(--). Readall6helpercells+3ownerpayloadcellsandODfromguestmemoryaftereachrealkeyboardcall;sentinel77andemptydatastackHERE+12 mustrestore. Helpersourceunchanged. GWAIT(--):setOE1, BEGIN INKEY UNTIL,setOE0 (UNTILconsumeskeyflag;NOextraDROP). NativeOE1provescallstillrunningbeforeCPU/data-stackmeasurements, physical0keyreleasesitandOE0provesreturn. Recordobservedstackseparationatmultiplevalid/invalid/INITcases,notexhaustivepeak. MeasureHEREperhelper/diagnostic;stockRAMtop16384;splitindependentbootsifneeded,neverRAMincrease. Fourfreshsmallownersworking/custom/wrong/repairedrun15keyboardGTICKswithprefix77;resumedState1Score4vswrong0capturesandfinaloutput/health/resetsthroughmemoryqueriessubstantiateresume/cust/repair. Recordallsource/tool/ROM/config/typedprogramidentity;fullvideo/fontPNGchecksforallpublicpictures. FinalwholeinputnativeproofmustbecompletebeforeAcecommit/PR.

## Ace diagnostic wait must observe release before a new press
FirstfulltableprobecompiledhelperHERE15952/diagnostic16203 andcompletedfirststatecase, butGWAITreturnedimmediately/OE0. ActualfailurePNGshows GWAIT OK:INKEYsawtheReturnwhichinvokedtheword, soitsfirstUNTILterminated. This isdiagnostic-keypolicy, notGSTEPSemantics orRAM. Preserveallsource/log/failurePNG beforetargetedfix. Add BEGIN INKEY 0= UNTIL beforethe existingpresswait, keepingOE1whilebothloopsactive;onlyafreshphysical0afterreleasecanfinishandclearOE. NoextraDROP, noDO/EXIT, nohelper/ownerchange. AlsofixhostoracleC408dict-literalstylebeforefreshnativeproof;earlierad-hocshellranpy_compileafterRufffailureandmaskeditsstatus, sofuturecommandsuseset-e/explicitseparateresults. No priorfulltablepassingclaimwasmade. Rerunall366rowsand4ownerswithcurrentfinalsources.

## Reduce the wait protocol to one case before another full run
Release-gatedGWAITcorrectlyheldOE1andreturnedOE0, butthephysical0exitkeyreachedtheROMlineeditorafterthewaitreturned. SubsequentNUMBERprinted0(theactualfailurePNG), leavinglower77present, soempty-stackguardfailed. This isextradiagnosticinput/typeahead, notGSTEPSemantics orwordstackconsumption. Preserveallsecondprotocolfailureinputs/image/log. Stopfull-sweepretries:validateonefirststatecasepluswaitinaseparatescopedprobe. Useoriginaltooltype_stringnewline(knownsupportedReturn)asthenewpressratherthanadigit, so anypost-returneditorinputisanemptylineandcannotpush0. KeepOE1/OE0/tag77/emptyHERE+12checksstrict. Nohelper/FTHwaitlogicchange. Theonecaseprobeisnot366caseproof;retainitscaptureseparatelythenrununalteredfull366guardandfourownersonlyifitpasses. Ifonecaseprotocolstillfails, rollbacktheoptionalinteractivewaitfromthetablesweepandqualifyresourceobservationsseparately, preservingthelastpositivecompactowner.

## Bind native Ace dictionary bytes as well as typed source
All366statecasesandfour15-sampleownerspassedwithsource/ROM/keyboard/capturebindings. Preserveallpositivesource/nativeproofbeforeclosingtheexactcompiled-load-identitygap: record everybyteofour newlycompiled dictionary fromHEREbeforetoHEREafter, beforecallsandaftercalls. Permitonlythetwobytepayloadateachpositivelyqueriedcontext/ownervariableaddress tochange;requireuniquein-rangeaddressesandidenticalremainingcode/header/stringbytes,withrawimagesandhashesretained. NoROMbytes,RAMinjectionorentry-PCchanges. Storeentered-sourcehashperorderedfilerecipe. This addsproof,nothelper/policy:allFTHandoraclesunchanged. Requalifyallfivefreshbootgroupsafterverifierchange;retainedcheckerandnegativecontrols challengecodebyte/identity/address changesaswellasoutputs/stack/pixels. Do notrebindoldsourcehashestoproofwithoutfreshnativeexecution.

## Ace object-pool physical contract before code
Implement independent pool next;gameflowfce37329alreadyqualified/pushed. Seven2bytecellsPB(base),PC(initcapacity),PS(privateextent),PK(slot),PF(ok),PX(error),PI(scan):14numericpayloadbytesplusdictionaryheaders/code measurednatively. PINIT(basecap--ok)disablesPS0first, accepts1..8, validatesdictionaryRAMbase>=15441/base<HERE and HERE-base>=extent BEFOREC!addressing, clearsconfiguredoccupancyonly. Thisrangecheckcannotidentifytheactualallocatedobject:callerpassesitsownnine-byteCREATEbufferandkeepsitalive;arbitrarycodepointers/undersizedobjectsremainunsupported. Invalidinitreturns0/PX1/PS0withnoarraywrites. PCHK(--)validatesprivateextentandselectedpointerwithoutsubscripts;PGET(--slotok)returns lowestfree/PF1/PX0 orfullslotPS/PF0/PX0,invalidcontextPX1. SearchusesboundedBEGIN/WHILE/REPEAT soearlyEXITisoutsideDO;PIisfoundindexorsizeonfull. PREL(slot--ok)validatescontextandunsignedslot<PSbeforeaddressing, rejectsfree/double/outsidewithPX2, preservespayload. PINITclearDOhaspositiveextentandcompletesbeforeReturn/EXIT. No >R/R>data juggling orFASTcheckdisable.
CallerCREATE SLOTScontains8occupancybytes77andguard99;PAYLOADnine16bitcells60. SeparateNEWOBJ(--slotok)initialisesonlysuccessfullyacquiredpayloadslot, leavingfullsentinelunsubscripted. PNEW(--ok)selectsSLOTS/PC;PSHOW(--)printsSlot/OK. Settings8PC!,custom4,single1. GenerateddemoPNEWshowflag,9literalNEWOBJcalls(nohugecompiledtrace),release0thenreacquire;wrongreplacesonly0PRELDROPwith0DROP,repairrestoresbytesinnewboot. Smallfirstnativecompile/resource/runprobeonstock3KiB BEFOREfullmasks/boundaries/lifetime:checkall7contextcells,all9flagbytes/9payloadcells,actualresultstack[77,slot,ok],normalreturn/emptyHERE+12,HEREpermodule/CPUstack/pixels andactualguard. Allhelpers/objectdata/sourcekeywordentry/ROMhashbound;failiforiginaldictionarydoesnotfit,reducecallerobserverratherthanincreaseRAM. Futureallmask/invalidpointer/extent/index/doublefree/single/custom/wrongrepair/lifetime/fullcodeidentitychecksneedboundedindependentboots. No combinedpool+gameflowstock-RAMclaim.
Smallpayloadallocationuses8cells60plusaninth65535guardsoafull-slot8writecannotbehiddenbyre-storing60. Laterqualifiedcustom/singleownerdiagnosticsseedunusedpayloadcellsdistinctlybeforefullrequests.

First original-ROM import passed: helper656 dictionary bytes, storage53,
caller110; total819 plus the external19-byte NUMBER observer. HERE16279,
stock top16384. Nine acquisitions, release and reuse preserved prefix77,
both storage guards, all context and payload; retained full native pixels.
This is a first probe, not full qualification.

Before full qualification, add oracle.py and scripts/verify-ace-object-pool.py.
Use one fresh helper boot for all274 occupancy masks at capacities1,4,8
(2+16+256), alternating nonzero occupied-byte spellings1/128/255. Observe
every byte/cell, lowest free result, release and double release with an
independent list model. Keyboard-seed all data; never inject memory. Test
invalid capacities/private extents, unsigned/signed index spellings and
dictionary pointer bounds before array access; changing PC after init must
not alter PS. Keep all dictionary bytes before/after, permitting changes
only at the seven variable payloads and two actual CREATE buffers. Five
separate working/custom/single/wrong/repaired owner boots use unique payload
seeds and exhaust, then release0/reuse; the single-slot boot also ages
through300 acquire/release cycles;
wrong omits only the release. Require prefix77/actual result stacks, empty
return stack position, captured CPU/data separation samples, exact source,
ordered entered recipe, firmware/emulator hashes and native screen pixels.
Bound the native run at1800 seconds, save each completed group and retain
partial evidence on failure. No helper mutation during an active run.

Before publication also execute all five generated caller programs, line for
line through the original ROM in separate fresh boots, after the serial
qualification runner exits. The diagnostic owners intentionally exercise
selected operations; they do not substitute for running the complete
generated demo (nine requests at every capacity and its final printed
payload/guards). Add scripts/verify-ace-object-pool-callers.py and separate
callers-GROUP.json/PNG evidence. Bind exact builder output, typed load/demo
lines and full RAM/stack after each demo line, plus full final native pixels.
No mutation of the active native verifier or its frozen input set.

Publish four Ace figures only after native qualification: working/wrong
pool complete-caller captures and working/wrong game-flow resumed captures.
Add scripts/export-ace-depth-images.py and test_ace_depth_images.py using the
existing publication-manifest convention. Ace captures are already320x288:
copy the PNG bytes unchanged, check every decoded pixel and source/native
identity, and refuse to overwrite different retained output. No rendering,
cropping or invented pixels. Store published-working/wrong.png plus
published-images.json within each topic verification folder. Add retained
export checks to the pool evidence job; challenge manifests and decoded
pixels. Then pin website copies to the reviewed source commit.
