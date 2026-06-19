# PBVI Practitioner Guide — Greenfield Edition

*For engineers starting a new project under PBVI governance.*

---

This guide explains what you will actually do when building a new system with PBVI. It covers the concepts you need to understand, walks through a complete greenfield build from requirements brief to BCE close-out, and tells you the rules that matter most. It is not a replacement for the skill files — those contain the detailed prompts and procedures. This guide helps you understand the process well enough to use those procedures confidently.

Start here. Then load the skill files when you need to execute.

---

## 1. What PBVI Is and Why This Team Uses It

Read the PBVI methodology document for the full philosophy. The short version:

AI-assisted development creates a specific failure mode: code exists before understanding does. You have a working implementation and no reliable mental model of what it actually does, whether it holds the properties the system requires, or what it will do when something breaks. PBVI restores the understanding that AI speed removes.

It does this through three disciplines:

**Plan before you build.** Five planning phases produce four documents before a single line of code is written. Each document is a commitment — about what the system does, what must always be true about it, and how it will be built. These commitments are what make AI-assisted build reliable rather than speculative.

**Predict before you verify.** Before running any verification command, you write down what you expect to happen. This forces you to engage your understanding before the result arrives. If the result surprises you, that surprise is information — it means your model of the system was wrong and you need to resolve that before moving on.

**Human gates at the points that matter.** The AI plans and builds. The engineer decides. At every gate — phase completion, invariant sign-off, design gate, system sign-off — the human explicitly confirms. Not the AI.

What this means for you day-to-day: you will spend time writing things down that you might otherwise skip. This is not overhead — it is the work.

---

## 2. The Concepts You Will Work With

### The Eight Phases

PBVI has eight phases. The first five are planning; the last three are execution and verification. You always run them in order.

| Phase | Name | Tool | What you produce |
|---|---|---|---|
| 1 | Discovery and Architecture | CD | ARCHITECTURE.md |
| 2 | Invariant Definition | CD | INVARIANTS.md |
| 3 | Execution Planning | CD | EXECUTION_PLAN.md |
| 4 | Design Gate | CD | PHASE4_GATE_RECORD.md |
| 5 | Claude.md Creation | CD | Claude.md (FROZEN) |
| 6 | Build | CC | Code + VERIFICATION_RECORD.md per task + SESSION_LOG.md |
| 7 | Session Integration Check | CC | SESSION_LOG.md signed off |
| 8 | System Sign-Off | CC | VERIFICATION_CHECKLIST.md + BCE artifacts |

**CD** = Claude Desktop (or Claude.ai) — the planning AI. Used for Phases 1–5.
**CC** = Claude Code — the build AI. Used for Phases 6–8.

The distinction matters. Planning happens where your thinking happens — in a conversational, context-rich AI session. Build happens in the repository. The two tools have different purposes and different access to context. Do not use CC for planning or CD for building.

### The Loop

PBVI phases build sequentially, but the process is not strictly linear. Two things trigger a return to an earlier phase:

**Build-time failure:** a verification failure during Phase 6 that invalidates a planning assumption. Return to the phase that produced the broken assumption, update it, and re-verify from that point.

**Planning-time gap:** a later planning phase surfaces decisions or constraints not covered by an earlier one. Return to the earlier phase and update it before proceeding.

A loop triggered and resolved is not a failure. It is the mechanism that keeps planning honest.

### Invariants

Invariants are conditions that must always be true about the system. Not targets — constraints. A target is something you aim for. An invariant is something that must never be violated. The difference is operational: a system that passes all its tests while violating an invariant is a broken system.

There are two kinds:

**GLOBAL invariants** apply to every task in the system regardless of what is being built. They live in Claude.md Section 2. Maximum five. These are the most important constraints — genuinely cross-cutting, high harm if violated, not immediately detectable through normal use.

**TASK-SCOPED invariants** apply only when specific components or features are touched. They are embedded inline in the task prompts in EXECUTION_PLAN.md. They do not appear in Claude.md.

### Claude.md

Claude.md is the AI's operating instructions for the project. It defines the system scope, GLOBAL invariants, prohibited behaviours, and build conventions. CC reads it at the start of every session.

Think of it as the contract between the team and the AI. When something must never happen — a data type must never be coerced, an external API must never be called directly — it goes in Claude.md as a GLOBAL invariant, and CC enforces it on every task in every session.

Claude.md is frozen at creation. It does not change during the build. If the build reveals that Claude.md needs to change, stop — return to planning, update the relevant planning artifact, produce a new versioned Claude.md, resume from the first affected task.

### BCE Artifacts

BCE (Brownfield Context Extraction) runs at Phase 8 as Part 2A — after the system is built and signed off. It produces a structured intelligence layer describing how the system works, what must always be true about it, and where it is fragile. This layer sits beneath every future planning session on this system.

As the builder of a greenfield system, your Phase 8 BCE run benefits from Path C (PBVI Adapter Pipeline) — the fast path where CC reads your docs/ directory and produces draft artifacts automatically. Your planning documents are high-quality inputs. The resulting BCE artifacts will be substantially more complete than a stranger-led extraction.

---

## 3. Your Project From Start to Finish

*The example throughout: you have been handed a requirements brief for a freight rate management API. The system maintains carrier rate tables, validates rate submissions, and serves rate lookups to downstream services.*

### Before You Start — Scaffold the Repository

Before any planning begins, you need a repository in the correct PBVI structure.

Open a CC session with `pbvi_core.md` and `pbvi_init.md` loaded. Use the trigger phrase **"Initialise PBVI project"**. CC produces the standard directory structure, README.md, and PROJECT_MANIFEST.md.

The scaffold commit happens immediately:
```
git add .
git commit -m "chore: PBVI project initialisation — freight-rate-api"
```

METHODOLOGY_VERSION in PROJECT_MANIFEST.md is populated from pbvi_core.md's frontmatter version (PBVI) and bce_core.md's frontmatter version (BCE) at initialisation. It stays at that version until you explicitly migrate the project to a new version.

### Phase 1 — Discovery and Architecture

Phase 1 has three sub-phases — Interrogate, Explore, and Decide — and, for UI projects, a fourth sub-phase: UI Discovery. Run them in order.

**Interrogate.** Load `pbvi_core.md`, `pbvi_plan.md`, and your requirements brief in CD. Use **"Let's start Phase 1"**.

CD reads the brief and produces: a problem statement (what the system actually solves, not a restatement of requirements), constraints (stated and implied), a definition of success, failure modes, missing information, invocation boundary conditions, pipeline failure behaviour, and — added by PBVI-011 — an **Application Profile**.

The Application Profile classifies the system on four dimensions: surface type (UI+API, UI_ONLY, API_ONLY, or BACKGROUND_SERVICE), authentication mechanism, user roles with one-line access boundaries, and data baseline (Seeded, Migrated, or User-generated). The surface type determines which of the Phase 1 Decide UI sub-phase, Phase 2 Step 0 UI consistency check, Phase 4 Step 1c UI Surface Review, Phase 6 Session 1 Playwright scaffolding, and Phase 8 UI harness assembly run. The data baseline determines whether SEED_DATA.md is produced in Phase 1 Decide and whether a seed script task is scheduled in Session 1.

The Interrogate output is not a summary of the brief — it is a structured analysis of it. The missing information section is the most important output: it names what you do not yet know but need to resolve before design decisions can be made. For the freight rate system: does the caller need to know when a rate table was last updated? What happens when a rate lookup hits a carrier with no valid rates in the current period?

Resolve every missing information item before moving to Explore. Do not carry unresolved questions into architecture selection.

**Explore.** Use **"Explore architectures"**. CD proposes three candidate architectures with trade-off analysis — what each makes easy, what each makes hard, which constraints it satisfies, what you give up compared to the others. CD does not recommend. You select.

Before proceeding to Decide, run the mandatory Explore → Decide gap check: did exploration surface any design decisions not traceable to a stated or implied constraint from Interrogate? If yes, return to Interrogate, add them, and update before proceeding.

**Decide.** Select your architecture. Use **"Help me produce ARCHITECTURE.md"** and supply your decision and reasons. Every design decision must be traceable to a constraint or resolved missing information item from Interrogate. Decisions that cannot be traced do not belong in ARCHITECTURE.md.

ARCHITECTURE.md covers: problem framing, key design decisions with alternatives rejected, challenges to each decision, key risks, key assumptions, open questions, and the data model if any.

Commit ARCHITECTURE.md before Phase 2 begins.

**UI Discovery (PBVI-011 — UI projects only).** When APPLICATION_SURFACE is UI+API or UI_ONLY, ARCHITECTURE.md is not the final Phase 1 output. After ARCHITECTURE.md is signed off, run UI Discovery using **"Run UI Discovery"** (or "Produce UI_SURFACE.md").

UI Discovery is a three-pass session. **Pass 0 — Global Elements:** CD drafts the eight global elements of `UI_SURFACE.md` (Navigation, Authentication Shell, Back Navigation, Breadcrumbs, Global Error Boundary, App-level Loading, Toast/Notification System) from ARCHITECTURE.md and the brief, marking TBD where it cannot infer. **Pass 1 — Screen Inventory:** CD enumerates every screen with name, type (List/Detail/Form/Dashboard/Modal/Wizard), route, journey, roles, and auth-required flag. **Pass 2 — Per-Screen Functional Spec:** CD produces the full screen specification for each screen — Data Displayed, Actions, States, type-specific sections (form fields, list configuration, panels, modal configuration), and async behaviour. Each pass surfaces a numbered gap list; you answer before CD moves on. CD infers, you correct — this is a scan-and-correct pass, not a deep challenge session. UI will drift post-demo regardless, and `UI_SURFACE.md` is designed for fast amendment via the lightweight amendment log at the top.

If your data baseline (declared in the Application Profile) is Seeded, CD also produces `SEED_DATA.md` after `UI_SURFACE.md` is confirmed. It defines per-entity seed records, the minimum count required to enable each UI state, and a coverage matrix mapping screens to seed records.

Both artifacts must be engineer-signed-off before Phase 1 closes. CC commits them to `docs/` and registers them in PROJECT_MANIFEST.md. `UI_SURFACE.md` is **dual-registered** — under Planning Artifacts (Phase 1 origin) and Discovery Artifacts (BCE Stage 2 cross-reference).

**Gate condition:** You can state the core problem, the key design decisions, and the constraints the system must satisfy — without opening any document. For UI projects, you can also state the global navigation structure, the role boundaries, and at least one full user journey end-to-end. If you cannot, Phase 1 is not complete.

### Phase 2 — Invariant Definition

Phase 2 is the highest-cognitive-effort planning phase. It cannot be delegated to CC. On greenfield builds, the default authorship mode is ASSISTED — CD drafts structural and data invariants, you author domain invariants. This is not a shortcut; it is a precise division of what CD can and cannot infer.

**Step 0 — Map data touch points.** Before writing a single invariant, enumerate every place data enters, transforms, or exits the system. Common touch points: capture, storage (write/read/update), retrieval, transformation, transmission, rendering, authentication.

For UI projects (PBVI-011), `UI_SURFACE.md` already exists from Phase 1 — do not re-produce a journey map. Instead, run the **UI consistency check**: confirm every data touch point maps to at least one screen or global element in UI_SURFACE.md, and every screen's Data Displayed section maps to at least one touch point. Gaps return to Phase 1 UI Discovery, not to invariant drafting.

For the freight rate API: data enters via rate submission (POST), exits via rate lookup (GET), is stored in the rate table database, and transforms when carrier submissions are validated and normalised. Four touch points minimum.

**Step 1 — ASSISTED mode (greenfield default).** Use **"Draft invariants for this system"**. CD drafts structural invariants (from architecture decisions) and data invariants (from schema and entity relationships). For each invariant, CD also produces a **Failure Mode Draft** — three parts: violation observable state, detection point, and blast radius.

After drafting structural and data invariants, CD prompts you: *"What business rules exist for this system that are not visible in the architecture or data model? Those are domain invariants — I cannot draft them."* That is the focused conversation. State each domain invariant and CD challenges it.

CD applies all six challenge tests to every invariant: goal vs. constraint, enforcement scope, bundling, coverage against data touch points, harm and detectability, and complexity accumulation. Only invariants that pass all six tests go forward.

For the freight rate API: structural — rate data flows only through a single write path with no bypass. Data — a rate record must carry exactly one effective period; null or overlapping periods are invalid. Domain — a rate lookup must never return a rate that has been superseded by a later submission from the same carrier for the same lane and effective period. That last one is yours to author.

The harm and detectability test is the most important. An invariant survives it only if both conditions hold: the harm is real and significant, AND the violation is not immediately visible through normal use. If either condition fails, the invariant is reclassified as implementation guidance embedded in the relevant task prompt in EXECUTION_PLAN.md — it does not go into INVARIANTS.md.

**Step 1b — Sufficiency check.** After revision, CD reads ARCHITECTURE.md section by section and checks the invariant set for sufficiency. Use **"Run sufficiency check"**. CD surfaces gaps only. In ASSISTED mode, gaps go to you with the same instruction: state each as a domain invariant if you own it.

**Step 2 — Produce INVARIANTS.md.** Use **"Produce INVARIANTS.md"** with the agreed set. Each invariant carries: ID, condition, category (Structural/Data/Domain), scope (GLOBAL or TASK-SCOPED), authorship, why it matters, enforcement points, and the Failure Mode (violation / detection / blast radius).

Commit INVARIANTS.md before Phase 3 begins.

**Gate condition:** Engineer signs off on the complete set — structural/data invariants confirmed, domain invariants authored and signed. Every invariant must pass all challenge tests.

### Phase 3 — Execution Planning

Phase 3 translates the architecture and invariants into a task-by-task build plan that CC can execute reliably.

**Gate condition:** ARCHITECTURE.md and INVARIANTS.md must be complete and signed off. Every open question in ARCHITECTURE.md must be resolved with a concrete decision before this phase begins.

Use **"Help me produce the execution plan"**. Before generating the plan, CD runs a requirements traceability check — cross-referencing the brief against ARCHITECTURE.md to confirm every named feature, behaviour, or deliverable either has a corresponding design decision or an explicit deferral.

EXECUTION_PLAN.md is structured in sessions. Each session delivers a running, verifiable system state. Each task within a session produces a discrete, independently verifiable output.

For the freight rate API: Session 1 might scaffold the project, set up the database schema, and verify connection. Session 2 might build the rate submission endpoint and its validation logic. Each task has: description, CC prompt, test cases (happy path and failure cases), verification command (exact shell command — not "run the tests"), TASK-SCOPED invariant text embedded inline, a regression classification, and — for tasks that build or modify a screen in UI_SURFACE.md — a **UI test spec (item 7, PBVI-011)**.

The UI test spec names the Playwright assertions CC must write while completing the task: which screen, which test strategy (Seeded — run against seed state; User-generated — drive UI to create state), and what assertions to implement. AI generates these from UI_SURFACE.md at plan time; the engineer confirms at sign-off. Test files land at `ui_tests/[screen-slug].spec.ts` and are committed in the same commit as the implementation. The assertions are not optional — a UI task is not complete until they are written and passing (or marked `todo()` with a reason).

For UI projects with data baseline = Seeded, Session 1 also includes a **seed script task** as its second task (after scaffolding): produce `scripts/seed.[ts|sql|js]` implementing every entity and record in SEED_DATA.md, idempotent. This is not optional and is not deferred — UI testing, development, and demo readiness all depend on seed data existing.

The regression classification matters. It is a three-value hierarchy: NOT-REGRESSION-RELEVANT, REGRESSION-RELEVANT, or HARNESS-CANDIDATE. Tasks marked REGRESSION-RELEVANT carry portable verification commands — runnable from repo root without session-specific setup. These are assembled into `verification/REGRESSION_SUITE.sh` at Phase 8. Tasks marked HARNESS-CANDIDATE meet stricter criteria: stateless, executable against a running system without build context, and directly tied to a named invariant. These are assembled into both REGRESSION_SUITE.sh and the live invariant harness (`verification/HARNESS.sh`) at Phase 8.

Commit EXECUTION_PLAN.md before Phase 4 begins.

### Phase 4 — Design Gate

Phase 4 is adversarial review of the plan before build begins. Its job is to find failures before they become expensive.

Use **"Run Design Gate"**. CD applies four structured checks in order: evaluation criteria review, requirements traceability, adversarial stress test, and risk register with RESOLVE/ACCEPT dispositions.

The adversarial stress test is where Phase 4 pays off. For the freight rate API, Phase 4 might surface: "Rate lookup during a carrier's rate submission window — what state does the system return if a submission is in-flight when a lookup arrives?" If the execution plan has no task for this, it is a gap that must be addressed before build begins.

Every Critical or High finding must be RESOLVED — not just noted. RESOLVE means the plan changes. ACCEPT means you have documented why the risk is acceptable. A finding you cannot RESOLVE or ACCEPT is a blocker.

**Step 1c — UI Surface Review (PBVI-011 — UI projects only).** Use **"Run UI Design Gate"**. CD loads UI_SURFACE.md and EXECUTION_PLAN.md and runs four checks: (1) screen coverage — every screen has at least one task building it; (2) role-conditional behaviour testability — every conditional action has a named invariant or UI test path; (3) global elements coverage — Navigation, Logout, Session expiry, and Global error boundary all have tasks; (4) auth architecture consistency — UI_SURFACE.md Authentication Shell matches ARCHITECTURE.md auth. Findings land in PHASE4_GATE_RECORD.md Section F with severity (BLOCKER / WARNING / INFO) and disposition (RESOLVE / ACCEPT). BLOCKERS must be resolved before Phase 5 opens.

The gate has two human-owned steps after Step 1.

**Step 2 — Ownership confirmation (no documents open).** Three questions from memory: (1) Can I explain what this system does and why it is designed this way? (2) Do I agree with every key architectural decision? (3) Do I know what failure looks like for each invariant — specifically?

**Step 2b — Invariant Failure Mode Review.** For each invariant, work through the failure mode in sequence. For structural and data invariants, CD reads the Failure Mode Draft from INVARIANTS.md and you confirm, correct, or augment each of the three parts. Correction or augmentation is evidence of ownership. For domain invariants, you state the three-part failure mode without reference to any document.

An engineer who can confirm, correct, or augment a failure mode statement owns the invariant. An engineer who cannot engage with it does not — and that invariant returns to Phase 2 before Phase 5 opens.

This is not a quiz. The Failure Mode Draft was produced in Phase 2 specifically to convert this from a generation task to a validation task. It is cognitively tractable. The gate only fails when an engineer discovers they do not own an invariant they thought they owned — which is exactly what the gate is designed to surface.

PHASE4_GATE_RECORD.md — including Section E (Invariant Failure Mode Review) — is committed to docs/ before Phase 5 begins.

### Phase 5 — Claude.md Creation

Claude.md is produced once, frozen immediately, and never edited during the build.

Use **"Produce Claude.md"**. CD assembles it from ARCHITECTURE.md, INVARIANTS.md, EXECUTION_PLAN.md, and PHASE4_GATE_RECORD.md. Claude.md has five mandatory sections: system identity and scope, hard invariants (GLOBAL only — TASK-SCOPED invariants live in task prompts), scope boundary (exact files CC may create or modify), fixed stack, and rules.

The methodology-mandated complexity invariant is pre-declared in every Claude.md regardless of what the system does: "Each function, method, or handler must have a single stateable purpose. Conditional nesting exceeding two levels is a structural violation — refactor before proceeding. This is never negotiable." It does not consume one of your GLOBAL invariant slots.

Commit Claude.md with the frozen banner in the version header. Version: v1.0 · FROZEN · [date].

Also produce session prompt files at Phase 5 — use **"Produce session prompt files for this project"**. One file per session defined in EXECUTION_PLAN.md, committed to `sessions/`. These files are a named Phase 5 output — they are not generated at session launch time. Phase 6 cannot begin until all session prompt files are committed and registered in PROJECT_MANIFEST.md.

**Gate condition:** Phase 4 gate must pass — APPROVE or CONDITIONAL APPROVE verdict — before Phase 5 begins.

### Phases 6 and 7 — Build and Session Integration

Open a CC session for each session defined in EXECUTION_PLAN.md. CC reads the session prompt file for that session, which contains the task list, Claude.md, and the "What Has Already Been Built" paragraph from the previous session.

**For each task in manual mode:**

1. Read the task prompt in EXECUTION_PLAN.md. Understand the expected output before any code is written.
2. Write your prediction — what you expect to happen when you run verification. Write this before running CC.
3. Build the task with CC.
4. Run verification. Record the result — PASS or FAIL.
5. If PASS: proceed to the next task.
6. If FAIL: stop. Understand why before attempting a fix. Record BLOCKED in the session log if the failure cannot be resolved in the current session.

**For each task in autonomous mode:**

CC runs tasks sequentially without stopping for each prediction. The Prediction Statement section is omitted from Verification Records, but the CC Challenge Output is mandatory. Any verification failure stops the session immediately — no retry, no fix attempt. Record BLOCKED and wait for the engineer.

In both modes: one task = one commit. Do not batch multiple tasks into a single commit.

At session end, sign the Session Log. A session without a signed log is not complete.

**Build-time loops:** If a verification failure invalidates a planning assumption — a design decision in ARCHITECTURE.md was wrong, an invariant cannot be enforced as written, a task depends on an interface that doesn't match the plan — stop. Return to the phase that produced the broken assumption. Update it. Produce a new Claude.md version if an invariant or scope boundary changed. Resume from the first affected task.

**BLOCKED stops:** If a session hits BLOCKED, record it, output the SESSION BLOCKED summary, and stop. Do not attempt a fix and re-run in the same session. Resolve the blocking issue outside the session, then use **"Resume session [N] from task [ID]"** to continue.

### Phase 8 — System Sign-Off and BCE Close-Out

Phase 8 has two parts. Part 1 is system sign-off — human verification that the system holds its invariants end-to-end. Part 2A is BCE close-out — the adapter pipeline that produces the system intelligence layer.

**Part 1 — System Sign-Off**

Read every VERIFICATION_RECORD.md produced during the build. Confirm every task is PASS. Run end-to-end verification against the running system. Produce VERIFICATION_CHECKLIST.md — the formal record of sign-off.

Three verification artifacts are assembled at this point. First, the regression suite: collect portable verification commands from all REGRESSION-RELEVANT and HARNESS-CANDIDATE tasks, consolidate into `verification/REGRESSION_SUITE.sh`, commit. Second, the live invariant harness: collect HARNESS-CANDIDATE commands, assemble into `verification/HARNESS.sh` (one section per invariant with severity and expected outcome), commit alongside the regression suite. Trigger phrase: "Assemble harness" in CC. For UI projects (PBVI-011), a third artifact: the **UI harness** — assemble `verification/UI_HARNESS.sh` from accumulated Playwright tests in `ui_tests/`. Trigger phrase: "Assemble UI harness" in CC. UI_HARNESS.sh does not run at session end (Playwright requires browser runtime); it runs at Phase 8 completion and on-demand only. A passing UI harness is a Phase 8 completion requirement for UI projects. None of these steps is optional.

**Part 2A — BCE Adapter Pipeline**

After Part 1 sign-off, run BCE as Path C (PBVI Adapter Pipeline). Load `bce_core.md` in CC.

The adapter pipeline reads your docs/ directory — ARCHITECTURE.md, INVARIANTS.md, EXECUTION_PLAN.md, Claude.md, and manifests — and produces draft BCE artifacts marked `STAGE-1-DRAFT: DOCS-DERIVED`. Your planning documents are the intake source. No manual intake step is needed.

Use **"Run BCE Stage 1"**. CC produces INTAKE_SUMMARY.md (first output), partial TOPOLOGY.md, MODULE_CONTRACTS.md skeletons, INVARIANT_CATALOGUE.md candidates, and a partial RISK_REGISTER.md.

At the Stage 1 human gate: review INTAKE_SUMMARY.md. Also produce SOURCE_INVENTORY.md at this point — if Teams history, product brochures, or other non-code sources exist outside docs/, record them in SOURCE_INVENTORY.md in `discovery/signal/`. If no external sources exist, record all adapter slots as NOT PRESENT.

Use **"Run BCE Stage 2"**. CC reads source code seeded with Stage 1 drafts. Where Stage 2 disagrees with Stage 1, it flags `STAGE-2-DIVERGENCE` markers. Every STAGE-2-DIVERGENCE must be resolved by you before Stage 3. This is where design intent meets implementation reality — the divergences are the most valuable findings of the pipeline.

Use **"Run BCE Stage 3"** in CD. Stage 3 opens with a schema validation check (Check 0) — it verifies that all relationship fields across the five artifacts use M-NNN and IP-NNN ID references. On a Path C extraction these will be assigned automatically during Stage 2. Stage 3 then performs cross-artifact review and produces ANNOTATION_CHECKLIST.md — the BCE backlog. Read every P1 item. Sign off or resolve.

After all P1 items are resolved, run **"Build system graph"** in CC to produce `discovery/SYSTEM_GRAPH.json` — the machine-readable knowledge graph that powers planning subgraph queries on future enhancements.

After that, resolve remaining annotation items using **"Resolve P1 annotation items"**. Each resolution produces a Human Annotation Record (HAR) — the traceable source document for the annotation.

Upload all discovery/ artifacts to the CD project for this system. These artifacts are the foundation for all future planning on this system.

---

## 4. The Artifacts You Will Produce

| Artifact | What it is | When | Owned by |
|---|---|---|---|
| `docs/ARCHITECTURE.md` | Architecture decisions, rationale, alternatives rejected | Phase 1 | Engineer |
| `docs/INVARIANTS.md` | System invariants with Failure Mode Drafts — three-category authorship (structural/data: CD-drafted; domain: engineer-authored), all invariants engineer-signed-off | Phase 2 | Engineer |
| `docs/EXECUTION_PLAN.md` | Task execution plan — frozen after Phase 4 gate | Phase 3 | Engineer |
| `docs/PHASE4_GATE_RECORD.md` | Design Gate record — findings and dispositions | Phase 4 | Engineer |
| `docs/Claude.md` | AI execution contract — frozen at creation | Phase 5 | Engineer |
| `sessions/S[N]_execution_prompt.md` | Per-session CC execution prompt files | Phase 5 | Engineer |
| `sessions/SESSION_NNN_LOG.md` | Record of one build session | Phase 6–7 | Engineer signs |
| `VERIFICATION_RECORD_T-NNN.md` | Per-task prediction and result | Phase 6–7 | Part of sign-off evidence |
| `verification/VERIFICATION_CHECKLIST.md` | System sign-off record | Phase 8 Part 1 | Engineer signs |
| `verification/REGRESSION_SUITE.sh` | Portable regression commands | Phase 8 Part 1 | Engineer |
| `verification/HARNESS.sh` | Live invariant assertion harness | Phase 8 Part 1 | CC assembles, Engineer commits |
| `discovery/` (7 BCE artifacts) | System intelligence layer | Phase 8 Part 2A | Engineer |

---

## 5. Rules You Must Not Break

**Do not start Phase 6 without a frozen Claude.md.** Claude.md is the build contract. Building without it means CC has no authoritative operating instructions. Every build session without a frozen Claude.md is ungoverned.

**Do not edit Claude.md during the build.** If the build reveals that Claude.md needs to change, stop. Return to planning. Produce a new versioned Claude.md. Resume from the first affected task. Inline edits during build create a divergence between what was planned and what was built.

**Domain invariants are engineer-authored. Always.** The authorship rule for domain invariants is not a formality. The engineer who writes a domain invariant owns the causal understanding behind it — why that constraint prevents a specific failure. Domain invariants require knowledge that is not in any document. For structural and data invariants, CD drafts from ARCHITECTURE.md and the schema — these are inferences from what you already decided. That division is deliberate. If you approved a domain invariant that CD drafted, you may have a correct-looking statement without the understanding behind it. That understanding is what makes the invariant defensible under challenge and survivable in the Phase 4 Failure Mode Review.

**Do not proceed with unresolved open questions.** Open questions in ARCHITECTURE.md that have not been resolved before Phase 3 become unexamined assumptions in the execution plan. Those assumptions surface as verification failures during the build — at which point they are expensive.

**Do not skip the Design Gate.** Phase 4 adversarial review is where the plan is challenged before it is expensive to change. A design gate that finds nothing is either a sign of an excellent plan or a sign of an insufficiently adversarial review. Both possibilities are worth examining.

**Do not commit multiple tasks in one commit.** One task = one commit. This discipline makes the build history a readable record of what was built and when. It makes reverting a failed task possible without losing adjacent work.

**Do not declare a gate passed.** The engineer signs off — not the AI. If CC produces output saying "all invariants PASS" or "sign-off complete", that is a draft. Your signature is the sign-off.

**Do not skip BCE Part 2A.** Phase 8 is not complete until the BCE adapter pipeline runs and ANNOTATION_CHECKLIST.md is produced. A built system with no context package is an orphan — the next engineer who touches it starts from scratch.

---

## 6. Where to Find Detailed Procedures

| What you need | Where to find it |
|---|---|
| Full PBVI methodology | `pbvi_methodology_v4_3.md` |
| Phase prompts, session execution, invariant challenge | `pbvi_core.md` + `pbvi_plan.md` + `pbvi_build.md` (v5.0 / v1.0) |
| Templates — SCOPE.md, Session Log, Verification Record, Claude.md | `pbvi_templates.md` |
| BCE extraction — Stage 1/2/3 prompts, annotation amendment | `bce_core.md` (v2.0) |
| BCE-S pipeline — Documents/Teams/Git adapters | `bce_signal.md` (v1.0) |
| Enhancement and sprint workflow | `pbvi_sprint.md` |
| Trigger phrases and step tables | `pbvi_how_to_guide.md` |

---

*See also: PBVI Enhancement Guide · BCE Practitioner Guide · BCE Consumer Guide*