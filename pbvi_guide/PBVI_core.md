---
name: pbvi-core
version: v5.0
description: >
  PBVI shared spine — always load this for any PBVI work. Contains the eight-phase overview
  and loop diagnostic, repository structure, the Claude.md schema and conventions, version
  compatibility check, human accountability gates, and quick reference. For planning work
  (Phases 1–5, in CD) also load pbvi_plan.md. For build and verification work (Phases 6–8,
  in CC) also load pbvi_build.md. For templates load pbvi_templates.md. Enhancement/sprint:
  also pbvi_sprint.md. BCE: bce_core.md (+ bce_signal.md). Project genesis: pbvi_init.md.
  Brownfield onboarding: pbvi_brownfield.md.
OWNER: DataGrokr LLC
COPYRIGHT: "© 2025 DataGrokr LLC. All rights reserved."
LICENSE: >-
  Proprietary — for use by licensed DataGrokr clients only.
  Unauthorized reproduction, modification, or transfer is prohibited.
CONTACT: naveen@datagrokr.com
---

# PBVI Core Skill — v5.0

## Changelog

| Version | Date | Summary |
|---|---|---|
| v5.0 | June 2026 | Packaging event — Tier 1 cleanup + CD/CC split. No artifact migration. Tier 1: Version Migration extracted to pbvi_migrations.md; four duplicate version-compatibility blocks consolidated into one canonical section; frontmatter description and changelog tail trimmed. Split: planning Phases 1–5 → pbvi_plan.md; build Phases 6–8 → pbvi_build.md; Project Initialisation → pbvi_init.md; Brownfield Onboarding → pbvi_brownfield.md. pbvi_core.md retained as thin shared spine. Core's version field now carries the umbrella methodology version; pbvi_plan.md and pbvi_build.md carry independent content versions (v1.0). Compatibility check now compares against pbvi_core.md's version explicitly. Soft break — BREAKING_CHANGES.md entry registered; existing projects unaffected, adopt on next migration via file-swap. |
| v4.9 | May 2026 | PBVI-011 — UI as a First-Class Citizen. Comprehensive upgrade across all eight phases for projects where APPLICATION_SURFACE contains UI. New artifacts: UI_SURFACE.md (functional surface spec, dual-registered as planning and discovery artifact), SEED_DATA.md (conditional — data baseline = Seeded). New Phase 1 Interrogate output: Application Profile (surface type, auth, roles, data baseline). New Phase 1 Decide sub-phase: UI Discovery (Pass 0 global elements, Pass 1 screen inventory, Pass 2 per-screen functional spec). Phase 2 Step 0 restructured for UI projects (consistency check against UI_SURFACE.md). Phase 2 Step 1 UI checks updated to reference UI_SURFACE.md (four checks including conditional-action governance). Phase 4 Design Gate gains Step 1c UI Surface Review. Phase 3 gains per-task UI test specs (item 7) and conditional seed script task. Phase 5 Claude.md gains session-scoped UI Surface section. Phase 6 gains Playwright test writing as mandatory step for UI-touching tasks (step 3b). Phase 8 gains UI_HARNESS.sh assembly (step 9). BCE module classification extended with UI layer types (bce_core.md v2.3). APPLICATION_SURFACE field formalised in PROJECT_MANIFEST.md. Soft break — BREAKING_CHANGES.md entry registered. pbvi_templates.md v3.12. |
| v4.8 | April 2026 | CQR-001 — Conversation Quality Review introduced. Fires automatically at Phase 1–5 gate close in CD. Two-dimension rubric: Ownership and Dialogue. A/B/C/D grade with phase-specific observations and next-time coaching tips. Phase 1 weights Dialogue more heavily. Cannot be skipped. Does not apply to Phase 6–8 CC sessions. New "Conversation Quality Review" section added between Quick Reference and Where to Find Everything Else. Five gate trigger lines added — one per phase. Quick Reference rule added. |
| v4.7 | April 2026 | PBVI-010 — Phase 6 Pre-Build Validation. New named sub-step at the start of every build session — runs before the first task in autonomous and manual mode. Two checks: (A) Claude.md schema validation — five required sections present, CQ-001 complexity invariant present, METHODOLOGY_VERSION recorded, M-NNN/IC-N/IP-NNN reference resolution against ID_REGISTRY.md. HALT on any section missing, CQ-001 missing, or any stale/invalid ID; WARN on METHODOLOGY_VERSION mismatch only (FW-001); N-A graceful fallback when ID_REGISTRY.md absent (greenfield pre-Phase 8). (B) CC interpretation confirmation — CC produces three statements before first task: modules I will modify, invariants I will respect, blast radius (in scope, out of scope, integration points, entities). Engineer confirms or halts. HALT or -WRONG returns engineer to planning — no code written until CONFIRMED. New Claude.md Schema reference section added (adjacent to Phase 5). Session log gains Pre-Build Validation block. pbvi_templates.md v3.11. |
| v4.6 | April 2026 | PBVI-009 — Brownfield Onboarding Procedure. New named procedure (not a PBVI path) that derives the PBVI planning artifact set from a completed BCE artifact set. Five steps: BCE completeness check (with remediation paths for missing SYSTEM_GRAPH.json or DOMAIN_MODEL.json), ARCHITECTURE.md derivation as an interpretive document (not a BCE rehash; 1-3 page target), INVARIANTS.md dual-source derivation, Claude.md generation, sprint-ready declaration. Trigger phrases at step level only — no master invocation. Runs once per brownfield system. Produces docs/ARCHITECTURE.md, docs/INVARIANTS.md, Claude.md, PROJECT_MANIFEST.md (with ONBOARDING_SOURCE field), and discovery/ONBOARDING_LOG.md. Does NOT produce EXECUTION_PLAN.md, sessions/ content, HARNESS.sh, REGRESSION_SUITE.sh, or PHASE4_GATE_RECORD.md — these come from the first sprint. INVARIANT_AUTHORSHIP_MODE = GOVERNED (v4.5 brownfield default confirmed). ONBOARDING_LOG.md added as new BCE-adjacent attestation artifact. pbvi_templates.md v3.10. pbvi_sprint.md v1.4 (sprint entry precondition updated). |
| v4.5 | April 2026 | PBVI-008 — Greenfield Composed Sutton. Greenfield default authorship mode changed to ASSISTED. Three-category invariant model (Structural / Data / Domain): CD drafts structural and data invariants with Failure Mode Draft; engineer authors domain invariants. Failure Mode Draft (three-part: violation observable state, detection point, blast radius) embedded in INVARIANTS.md per invariant; serves as Phase 4 gate input and Phase 8 harness specification. Phase 4 Step 2 gains named Step 2b — Invariant Failure Mode Review: structured ownership test per invariant; gate failure returns invariant to Phase 2; Phase 5 does not open until all pass. INVARIANT_AUTHORSHIP_MODE field added to PROJECT_MANIFEST.md template (ASSISTED for greenfield, GOVERNED for brownfield; GOVERNED on greenfield requires written rationale). Revision rule relaxed: engineer must approve every revision, no longer author every word. pbvi_templates.md v3.9. BREAKING: Phase 2 Step 1 prompt changed — ASSISTED flow replaces engineer-draft-first for greenfield projects. |
| ≤ v4.4 | — | Full history in METHODOLOGY_CHANGELOG.md. |

## How to Invoke Prompts

Say any of these phrases to invoke the corresponding prompt. Claude will load
the relevant context and run the prompt. Gates embedded in each prompt tell
Claude where to stop and wait for your input.

| What you want to do | Say this | Tool | Phase |
|---|---|---|---|
| Interrogate the requirements brief | "Interrogate the brief" / "Run Phase 1 Interrogate" | CD | 1 |
| Generate architecture options | "Explore architectures" / "Run Phase 1 Explore" | CD | 1 |
| Produce ARCHITECTURE.md | "Produce ARCHITECTURE.md" / "Document my architecture decision" | CD | 1 |
| Map data touch points | "Map data touch points" / "Run Phase 2 Step 0" | CD | 2 |
| Draft invariants for this system (ASSISTED) | "Draft invariants for this system" / "Help me define invariants" | CD | 2 |
| Challenge my invariants (GOVERNED) | "Challenge my invariants" / "Review my invariant draft" | CD | 2 |
| Help me define domain invariants | "Help me define domain invariants" | CD | 2 |
| Check invariant sufficiency | "Run sufficiency check" / "Check invariants against architecture" | CD | 2 |
| Produce INVARIANTS.md | "Produce INVARIANTS.md" | CD | 2 |
| Produce the execution plan | "Produce the execution plan" / "Run Phase 3" | CD | 3 |
| Run the Design Gate review | "Run Design Gate" / "Run Phase 4" | CD | 4 |
| Produce Claude.md | "Produce Claude.md" / "Create the execution contract" | CD | 5 |
| Start a manual build session | "Start manual session [N]" | CC | 6 |
| Start an autonomous build session | "Run session [N] autonomously" | CC | 6 |
| Resume after a BLOCKED stop | "Resume session [N] from task [ID]" | CC | 6 |
| Resume after CHALLENGE FINDINGS | "Resume after challenge findings session [N] task [ID]" | CC | 6 |
| Session context getting too long | "Give me a handoff prompt" | CD | 6 |
| Produce session prompt files | "Produce session prompt files for this project" | CD | 5 |
| Migrate a project to PBVI structure | "Help me migrate this project" | CC | — |
| Migrate INVARIANTS.md to v3.0 (scope split) | "Migrate INVARIANTS.md to v3.0" / "Add scope classification to invariants" | CD then CC | — |
| Migrate EXECUTION_PLAN.md to v4.1 (regression) | "Migrate EXECUTION_PLAN.md to v4.1" / "Add regression classification to tasks" | CD then CC | — |
| Migrate design gate record to v4.3 | "Migrate PHASE4_RISK_DECISIONS.md to v4.3" / "Migrate design gate record to v4.3" | CC | — |
| Migrate INVARIANTS.md to v4.5 (PBVI-008) | "Migrate INVARIANTS.md to v4.5" / "Add failure mode fields to invariants" | CD then CC | — |
| Run regression suite on demand | "Run regression suite" | CC | 8 |
| Run harness check on demand | "Run harness check" | CC | 8 |
| Assemble live invariant harness | "Assemble harness" | CC | 8 |
| Run BCE completeness check (brownfield onboarding step 1) | "Run Step 1 of brownfield onboarding" · "Run BCE completeness check for brownfield onboarding" | CD | — |
| Derive ARCHITECTURE.md (brownfield onboarding step 2) | "Run Step 2 of brownfield onboarding" · "Derive ARCHITECTURE.md for brownfield onboarding" | CD | — |
| Derive INVARIANTS.md (brownfield onboarding step 3) | "Run Step 3 of brownfield onboarding" · "Derive INVARIANTS.md for brownfield onboarding" | CD | — |
| Generate Claude.md (brownfield onboarding step 4) | "Run Step 4 of brownfield onboarding" · "Generate Claude.md for brownfield onboarding" | CD | — |
| Sprint-ready declaration (brownfield onboarding step 5) | "Run Step 5 of brownfield onboarding" · "Declare system sprint-ready" | CD | — |
| Phase 6 Pre-Build Validation | Automatic at every build session start — no engineer trigger | CC | 6 |
| Run UI Discovery (PBVI-011) | "Run UI Discovery" / "Produce UI_SURFACE.md" / "Run Phase 1 UI Discovery" | CD | 1 |
| Run UI Design Gate review (PBVI-011) | "Run UI Design Gate" | CD | 4 |
| Assemble UI harness (PBVI-011) | "Assemble UI harness" | CC | 8 |
| Run UI harness (PBVI-011) | "Run UI harness" | CC | 8 |

---

## Eight-Phase Overview

| Phase | Name | PBVI Stage | Key Output | Human Gate |
|---|---|---|---|---|
| 1 | Discovery and Architecture | PLAN | ARCHITECTURE.md | Engineer owns the problem — can state it without AI assistance |
| 2 | Invariant Definition | PLAN | INVARIANTS.md + Failure Mode Draft | ASSISTED (greenfield default): CD drafts structural/data invariants, engineer authors domain invariants, engineer signs off all. GOVERNED (brownfield): engineer authors first, signs off final set. |
| 3 | Execution Planning | PLAN | EXECUTION_PLAN.md | All open questions resolved before plan is produced |
| 4 | Design Gate | PLAN | Risk Register | Structured review passed and all Critical/High findings resolved; engineer answers three gate questions without opening any document |
| 5 | Claude.md Creation | PLAN | Claude.md (FROZEN) | Phase 4 gate must pass before this phase begins |
| 6 | Build | BUILD | Code, per-session SESSION_LOG.md + VERIFICATION_RECORD.md | Scaffold commit before first CC prompt; one task = one commit |
| 7 | Session Integration Check | VERIFY | VERIFICATION_RECORD.md complete | Engineer signs off each session before PR is raised |
| 8 | System Sign-Off | INTEGRATE | VERIFICATION_CHECKLIST.md + discovery/ artifacts (greenfield) / ENH-NNN_BCE_IMPACT.md (enhancement — see pbvi_sprint.md Part 2B) | All invariants verified end-to-end; BCE adapter pipeline complete; documented sign-off required |

> **Phase 8 — greenfield vs. enhancement:** The Key Output above differs by build type. Greenfield (Part 2A): building engineer produces all seven discovery/ artifacts directly. Enhancement (Part 2B): building engineer produces ENH-NNN_BCE_IMPACT.md only — discovery/ artifact updates are deferred to sprint close-out by the Sprint Lead. See the Phase 8 section below and pbvi_sprint.md Part 2B.

Phases build sequentially. The loop is not a failure state — it is the mechanism that keeps planning honest. Two things trigger a return to an earlier phase:

Build-time failure: a verification failure during Phase 6 or 7 that invalidates a planning assumption — return to the phase that produced the broken assumption.

Planning-time gap: a later planning phase surfaces decisions or constraints not covered by an earlier one — return to the earlier phase and update it before proceeding. Do not paper over the gap by continuing forward.

A loop triggered and resolved is stronger than a plan that was never challenged.

**Loop diagnostic table — use when a gap surfaces during or after build:**

| Gap type | Root cause phase | What must be updated before building anything new |
|---|---|---|
| A screen or feature is missing at build end | Phase 2 — journey map incomplete (pbvi_plan.md) | INVARIANTS.md: add UI completeness invariant; EXECUTION_PLAN.md: add missing tasks |
| CC makes a decision not covered in Claude.md | Phase 5 — Scope Boundary too loose (pbvi_plan.md) | Claude.md: tighten scope or add invariant; re-verify affected tasks |
| Verification command fails due to wrong interface | Phase 3 — task CC prompt underspecified (pbvi_plan.md) | EXECUTION_PLAN.md: rewrite CC prompt for affected task; produce new Claude.md version if invariant touched |
| A task invalidates a prior task's output | Phase 3 — session decomposition error (pbvi_plan.md) | EXECUTION_PLAN.md: re-sequence affected tasks; re-verify from first affected task |
| An invariant cannot be enforced as written | Phase 2 — invariant is a goal not a constraint (pbvi_plan.md) | INVARIANTS.md: reframe or remove; EXECUTION_PLAN.md: update the embedded invariant text in the affected task prompts |
| Open question resolved during build changes design | Phase 1 — Interrogate incomplete (pbvi_plan.md) | ARCHITECTURE.md: document the decision; INVARIANTS.md: add any new constraints; produce new Claude.md version |

---

## Version Compatibility Check

Run this at the start of every planning phase gate (Phases 2–5). Build-session
version checking is handled separately by Phase 6 Pre-Build Validation.

Read PROJECT_MANIFEST.md and locate the METHODOLOGY_VERSION field.
Compare it against the version in pbvi_core.md's frontmatter.
If they match: proceed silently.
If they differ or the field is absent: output the following, then continue —
do not stop.

  METHODOLOGY VERSION WARNING
  ---------------------------
  Skill version:    [from skill frontmatter]
  Project version:  [from METHODOLOGY_VERSION field, or NOT DECLARED]

  This project was initialised under a different methodology version.
  Proceeding may produce incomplete or unexpected results.
  Consult BREAKING_CHANGES.md in the DG-Forge repo to identify which migrations apply.
  Then use the migration trigger phrases in pbvi_migrations.md.

---

## Standard Repository Structure

All DataGrokr PBVI projects use a closed-contract folder structure. Every directory has a
defined purpose and a contract governing what may live inside it.

### Directory Inventory

| Directory / File | Purpose |
|---|---|
| `README.md` | Repo root — navigation and orientation for any engineer who clones |
| `PROJECT_MANIFEST.md` | Repo root — file registry for the entire project |
| `brief/` | Client inputs and requirements briefs — never modified after receipt |
| `docs/` | PBVI trunk artifacts (ARCHITECTURE.md, INVARIANTS.md, EXECUTION_PLAN.md, Claude.md) |
| `docs/prompts/` | CC execution prompts — methodology artifacts under version control |
| `sessions/` | Working evidence — SESSION_LOG.md and VERIFICATION_RECORD.md (engineer-facing) |
| `verification/` | Formal sign-off checklists — VERIFICATION_CHECKLIST.md per phase/enhancement (stakeholder-facing) |
| `discovery/` | BCE SIL artifacts + discovery/components/ for component files |
| `enhancements/` | REGISTRY.md + ENH-NNN subdirectory per enhancement |
| `tools/` | Agentic build automation scripts — challenge.sh, resume_challenge.sh, resume_session.sh, monitor.sh, launch.sh (optional automation wrapper). Methodology artifacts under version control. No source code, no planning artifacts. |

### The Three Structural Rules

All three rules are enforced in Claude.md and all CC prompts.

**Rule 1:** All file references use full paths from repo root — never bare filenames.

**Rule 2:** All files inside any enhancement package carry their ENH-NNN prefix — no exceptions.

**Rule 3:** Any file not in the mandatory set for its directory and not registered in
PROJECT_MANIFEST.md must not be read by CC as authoritative input. CC flags unregistered
files and reports them to the engineer before proceeding.

Rule 3 is the enforcement mechanism that makes PROJECT_MANIFEST.md meaningful rather than
advisory. Organic artifacts present in a repo that do not fit any directory contract are
untrusted until the engineer registers or removes them.

### Project Profiles

A closed-contract profile taxonomy determines which non-standard files are permitted in docs/
beyond the mandatory PBVI set. Profile declared in PROJECT_MANIFEST.md at project initialisation.

| Profile | Permitted additional files in docs/ |
|---|---|
| DATA_ACCELERATOR | POPULATION_MANIFEST.md, DATA_QUALITY_MANIFEST.md |
| WEB_APPLICATION | UI_SPEC.md, ROUTE_MAP.md |
| API_SERVICE | API_CONTRACT.md, RATE_LIMIT_POLICY.md |
| CLI_TOOL | COMMAND_SPEC.md |

Makes the directory standard extensible without making it open-ended.

### Directory Creation

All directories are created at project initialisation in a single scaffolding step — no
lifecycle-triggered creation. The semantic signal of "has this phase run" is carried by
PROJECT_MANIFEST.md status column (PRESENT/PENDING), not by directory existence.
Empty directories use .gitkeep files.

The tools/ directory is created at initialisation and pre-populated with the
five standard agentic build scripts from the DG-Forge repository. Scripts are
committed alongside the project and versioned with it. Never edit scripts
directly in a project — update the DG-Forge source and propagate.

---

## Claude.md Conventions

### Location and Root Stub Pattern

Claude.md is a mandatory artifact in `docs/` — not at repo root.

A one-line root stub is required at repo root as a CC tool-compatibility shim:
```
See docs/Claude.md
```

The stub must be registered in PROJECT_MANIFEST.md with the note:
"Tool-compatibility shim — not authoritative content."
The stub is not a content document. CC must not treat it as authoritative.

### Changelog Blocks on Versioned Docs

ARCHITECTURE.md, INVARIANTS.md, DATA_QUALITY_MANIFEST.md, and Claude.md all carry
a standardised changelog table immediately below the title line:

```markdown
## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | [date] | [engineer] | Greenfield — Initial |
```

For Claude.md already at a later version: populate the table to reflect actual history.
Earlier versions not recoverable from artifacts noted as:
"Pre-DataGrokr migration; history in git log."

### Frozen Banner on EXECUTION_PLAN.md

After Phase 8 sign-off, EXECUTION_PLAN.md receives a frozen banner immediately
after the title line:

```markdown
> **FROZEN** — This document is sealed as of [date] (Phase 8 sign-off,
> S9 complete). No modifications are permitted. All future enhancement
> planning uses `enhancements/ENH-NNN_EXECUTION_PLAN.md`.
```

---

## Claude.md Schema

A valid Claude.md contains exactly five sections in this order:

### Section 1 — System Intent
Two to three sentences. What the system does, what it does not do,
what success looks like.

### Section 2 — Hard Invariants
Numbered list. Every GLOBAL invariant from INVARIANTS.md, full text
verbatim, with IC-N reference. Every entry in this format:
  IC-N: [full invariant statement]
  This is never negotiable.

The CQ-001 complexity invariant is mandatory in this section
regardless of authoring mode. Verbatim text:
  "Each function, method, or handler must have a single stateable
   purpose. Conditional nesting exceeding two levels is a structural
   violation — refactor before proceeding. This is never negotiable."

Maximum five GLOBAL invariants in this section, plus the CQ-001
complexity invariant. The CQ-001 invariant does not consume an
engineer slot.

### Section 3 — Scope Boundary
Exact files the AI is permitted to create or modify in this session.
M-NNN references where graph artifacts are present. File paths where
graph artifacts are absent (greenfield pre-Phase 8). Out-of-scope
files explicitly listed.

### Section 4 — Fixed Stack
Exact technologies, versions, dependencies, environment variable
names. Anything not listed, the AI selects.

### Section 5 — Rules
The three structural rules verbatim per pbvi_core.md.

### Frontmatter
Claude.md must carry a frontmatter block with:
  - version: v1.0 (or later, per amendments)
  - METHODOLOGY_VERSION: [PBVI version used to author this Claude.md]
  - source: [PBVI-009 brownfield onboarding | PBVI Phase 5 greenfield |
             Sprint Claude.md amendment]
  - frozen: true (after generation)

---

## Human Accountability Gates

| Gate | Trigger | What Must Happen Before Proceeding |
|---|---|---|
| Architecture selection | End of Phase 1 Explore | Engineer chooses architecture — not Claude |
| Session start | Before any task in a new session | Branch created, previous session integration check passed |
| Task commit | After each task | Verification command passed, prediction + result recorded |
| Session completion | End of session | All tasks committed, integration check passed, PR raised, sign-off given |
| Phase transition | Moving to next session | Previous session PR merged to main |

Claude may not declare a gate passed. Only the engineer signs off.

---

## Quick Reference

**Prediction rule:** Write predictions → run commands → record results. Never in any other order.

**Template rule:** Blank = cognitive work for the engineer. Pre-populated = factual copy from the plan.

**Git rule:** One branch per session. One commit per task. PR to main only after integration check.

**Invariant rule:** If a task prompt conflicts with an invariant, the invariant wins. Flag the conflict; never resolve it silently.

**Scope rule:** If something is not in the task prompt, do the minimum and flag the gap. Never fill gaps with judgment.

**Loop rule:** The loop is triggered by two things — a build failure, or a later phase exposing a gap in an earlier one. Both are valid triggers. Both require returning to the earlier phase. Forward progress built on an unresolved gap is not progress.

**Rule 3 rule:** Unregistered files are untrusted. CC flags them and reports to the engineer before proceeding. Engineer decides: register or remove.

**Failure rule (Autonomous mode):** Any verification failure stops the session immediately. No retry. No fix attempt. Record BLOCKED, output SESSION BLOCKED summary, wait for engineer.

**Resume rule:** After a BLOCKED stop, use the Autonomous Mode Resume prompt — not the full session prompt. Engineer supplies SESSION_NUMBER, RESUME_TASK_ID, and BLOCKING_ISSUE_RESOLUTION explicitly.

**Scope violation rule (Autonomous mode):** Any file boundary violation or pre-commit declaration failure stops the session immediately. No commit. No fix attempt. Record SCOPE VIOLATION, output SCOPE VIOLATION summary, wait for engineer disposition (ACCEPT or REVERT). Scope violations are signal — not noise to auto-resolve.

**Challenge rule (Autonomous mode):** After each task's verification passes and scope checks pass, the independent challenge agent runs against evidence only — no build session context. A CLEAN verdict proceeds to commit. A FINDINGS verdict stops the session. Engineer dispositions each finding: ACCEPT with rationale (no test required) or TEST with a test case (run immediately, must pass before session continues). Challenge findings are signal about coverage gaps — not automatic defects.

**Complexity rule:** A function, method, or handler is structurally compliant if it has a single stateable purpose and its conditional logic can be described in one sentence. Conditional nesting exceeding two levels is a structural violation. Flag it; never resolve it silently.

**BCE rule:** Phase 8 is not complete until Part 2 is done. Greenfield: all seven BCE artifacts committed (INTAKE_SUMMARY.md + five living + ANNOTATION_CHECKLIST.md), P1 items signed off, CD project files updated (Part 2A). Enhancement: ENH-NNN_BCE_IMPACT.md produced, gap detection CLEAN, engineer signed off (Part 2B). In a sprint context, ENH-NNN_BCE_IMPACT.md is the only BCE artifact produced per-enhancement close-out — updating discovery/ artifacts for a single enhancement mid-sprint is a process violation. All discovery/ updates are deferred to sprint close-out via Sprint Lead BCE refresh. CD project files updated at sprint close-out.

**Brownfield onboarding rule:** A brownfield system with completed BCE artifacts cannot enter the sprint path until PBVI-009 onboarding is complete. Sprint Prompt 0 enforces the Claude.md precondition. ARCHITECTURE.md is interpretive — for facts, see BCE source-of-record artifacts. Five-GLOBAL invariant ceiling is hard — no override.

**Phase 6 entry rule:** Every build session begins with Pre-Build Validation — schema validation against ID_REGISTRY.md plus CC interpretation confirmation. HALT or -WRONG returns the engineer to planning. No code is written until the engineer confirms CC's interpretation.

**Conversation Quality Review rule:** Every Phase 1–5 gate close in CD emits a Conversation Quality Review block — A/B/C/D grade plus Ownership and Dialogue observations plus next-time tips. Coaching, not gating; does not modify the gate verdict. Does not run in Phase 6–8.

**UI surface rule (PBVI-011):** UI_SURFACE.md is the functional contract for all screens. CC builds to the spec — it does not infer screen behaviour from component names or route conventions. If a screen's spec is incomplete, stop and return to Phase 1 UI Discovery before building that screen.

**UI test rule (PBVI-011):** Every task with a UI test spec (EXECUTION_PLAN.md item 7) must produce Playwright test assertions as part of task completion. Tests are committed in the same commit as the implementation. A task with a UI test spec is not complete until its tests are written and passing (or explicitly marked todo() with a reason referencing a future task).

**UI harness rule (PBVI-011):** UI_HARNESS.sh runs at Phase 8 completion and on-demand only. It does not run at session end — Playwright requires browser runtime. A passing UI harness is a Phase 8 completion requirement for UI projects.

**Seed rule (PBVI-011):** If data baseline = Seeded, the seed script task in Session 1 is not optional and is not deferred. Development, UI testing, and demo readiness all depend on seed data existing. A UI project with baseline = Seeded is not ready for Phase 6 Session 2 until the seed script passes verification.

---

## Where to Find Everything Else

| Content | Load |
|---|---|
| Enhancement framework, sprint lifecycle, sprint prompts, Phase 8 Part 2B | pbvi_sprint.md |
| Artifact templates (Session Log, Verification Record, SCOPE.md, Brief, Sprint artifacts) | pbvi_templates.md |
| BCE extraction (BCE-C), adapter pipeline, gap detection prompt, BCE impact template | bce_core.md |
| BCE-S signal extraction — adapters, Stage 1/2/3, SIGNAL_GAPS.md (Tier 3) | bce_signal.md |
| Always-on behavioural rules | dg_forge_org_skill (org setting) |
| Version migration prompts (legacy project upgrades) | pbvi_migrations.md |
| Planning prompts — Phases 1–5, Conversation Quality Review | pbvi_plan.md |
| Build prompts — Phases 6–8, session execution prompts | pbvi_build.md |
| Project initialisation scaffold (load once at genesis) | pbvi_init.md |
| Brownfield onboarding (load once per BCE-extracted system) | pbvi_brownfield.md |
