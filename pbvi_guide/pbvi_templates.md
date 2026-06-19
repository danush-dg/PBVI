---
name: pbvi-templates
version: v3.12
description: >
  PBVI artifact templates — load this file when generating any PBVI artifact.
  Contains: Session Log, Verification Record, ENH-NNN_SCOPE.md, Enhancement Brief,
  Sprint Manifest, Sprint Log, ENH-NNN_SPRINT_CONSTRAINTS.md, PHASE4_GATE_RECORD.md,
  HARNESS.sh, DRIFT-NNN_BRIEF.md, ONBOARDING_LOG.md, UI_SURFACE.md, SEED_DATA.md.
  The ENH-NNN_BCE_IMPACT.md template is maintained exclusively in bce_core.md — not
  in this file. Load alongside pbvi_core.md or pbvi_sprint.md as needed.
  PBVI-009 (brownfield onboarding): Template 11 — ONBOARDING_LOG.md added.
  PBVI-010: Template 5 Collision Surface Map extended with detection mode. Template 1
  Pre-Build Validation block. Template 2B Step 0 Pre-Build Validation.
  PBVI-011 (UI as First-Class Citizen): Template 12 — UI_SURFACE.md and Template 13 —
  SEED_DATA.md added. Template 8 extended with Section F — UI Surface Review
  (Phase 4 Step 1c). Template 2 extended with UI Tests column in Test Cases table.
OWNER: DataGrokr LLC
COPYRIGHT: "© 2025 DataGrokr LLC. All rights reserved."
LICENSE: >-
  Proprietary — for use by licensed DataGrokr clients only.
  Unauthorized reproduction, modification, or transfer is prohibited.
CONTACT: naveen@datagrokr.com
---

# PBVI Templates — v3.12

## Changelog

| Version | Date | Summary |
|---|---|---|
| v3.12 | May 2026 | PBVI-011 — UI as a First-Class Citizen. Template 12 added: UI_SURFACE.md — functional UI surface specification (Amendment Log; Global Elements; Screen Inventory; per-screen specs with Data Displayed, Actions, States; type-specific sections for List/Form/Dashboard/Modal screens; Async Behaviour). Template 13 added: SEED_DATA.md — seed entity declaration with coverage matrix and seed script reference (conditional on data baseline = Seeded). Template 8 (PHASE4_GATE_RECORD.md) extended with Section F — UI Surface Review: four-check table (Screen coverage, Role-conditional testability, Global elements coverage, Auth architecture consistency) for Phase 4 Step 1c. Template 2 (VERIFICATION_RECORD.md) extended: UI Tests column added to Test Cases table — values WRITTEN — N assertions \| TODO(N) — reason \| N/A. |
| v3.11 | April 2026 | PBVI-010 — Template 5 (SPRINT-NNN_MANIFEST.md) Collision Surface Map block extended: Detection mode field (GRAPH \| PROSE); Surface ID and Surface name fields for graph-derived findings; hop distance and edge types fields (graph mode only); Confidence vocabulary expanded (GRAPH-DEFINITE \| PROSE-DEFINITE \| PROSE-PROBABLE \| PROSE-NOT-DETECTABLE). Template 1 (SESSION_LOG.md) Pre-Build Validation block added after session header, before Tasks table. Template 2B (Session Execution Prompt) Step 0 — Pre-Build Validation added after PLANNING ARTIFACTS section, before SCOPE BOUNDARY. |
| v3.10 | April 2026 | PBVI-009 — Template 11 added: ONBOARDING_LOG.md — brownfield onboarding attestation record. Five sections: BCE completeness check (with remediation verdict variants), ARCHITECTURE.md interpretation (with ARCH-DIV-NNN interpretive divergence log), INVARIANTS.md derivation (with adjudication record and five-GLOBAL ceiling check), Claude.md generation, sprint-ready close-out. Frozen on Section 5 sign-off. PROJECT_MANIFEST.md template extended with ONBOARDING_SOURCE, ONBOARDING_DATE, ONBOARDING_LOG fields. |
| v3.9 | April 2026 | PBVI-008 — Invariant Failure Mode Gate template. Template 8 (PHASE4_GATE_RECORD.md) extended with Section E — Invariant Failure Mode Review: per-invariant table with category, authorship, and three-part failure mode confirmation (violation / detection / blast radius); ownership result column (PASS / GATE FAIL); gate failure record; engineer sign-off. |
| v3.8 | April 2026 | PBVI-007 — Live Invariant Harness. Template 9 added: HARNESS.sh — live invariant assertion harness assembled at Phase 8 (greenfield) or sprint close-out (enhancement), one section per invariant with assertion command, expected outcome, severity, and invariant statement. Template 10 added: DRIFT-NNN_BRIEF.md — invariant drift brief, CC-generated from HARNESS.sh output and BCE artifacts, Sprint Lead sign-off required. Template 5 (Sprint Manifest) extended: Invariant Drift Items section added; Sprint Lead sign-off checklist updated. Template 6 (Sprint Log) extended: Invariant Drift Items table, Sprint CC Initiation section, Sprint Close-Out updated with HARNESS.sh and REGRESSION_SUITE.sh update steps and post-close-out harness run. |
| v3.7 | April 2026 | PBVI-006 — Template 8 added: PHASE4_GATE_RECORD.md — canonical template for the Design Gate record with four sections: evaluation criteria, requirements traceability, adversarial stress test findings, and risk register with RESOLVE/ACCEPT dispositions, overall verdict, and engineer sign-off block. |
| v3.6 | April 2026 | FW-001 — Version compatibility check added to Template 2B REPOSITORY CONTEXT section. After branch confirmation, the agent reads PROJECT_MANIFEST.md METHODOLOGY_VERSION, compares against the loaded skill frontmatter version, and outputs a named warning block if they differ — then continues without stopping the session. |
| v3.5 | April 2026 | CQ-001 — Template 2B challenge agent evaluation criteria made explicit: structural complexity check added as a named finding category — conditional nesting depth and single-purpose compliance per new or modified function against the core definition in Claude.md. Verdict: CLEAN or FINDINGS. Engineer dispositions per existing ACCEPT-with-rationale or TEST mechanism. |
| v3.4 | April 2026 | Template 2B made self-contained: TASK-LEVEL VERIFICATION (14 steps), GIT HYGIENE, FAILURE HANDLING, CHALLENGE FINDINGS HANDLING, SCOPE VIOLATION HANDLING, HUMAN GATES, SCOPE AND INVARIANT RULES, and closing paragraph embedded inline. Stale skill cross-references in STOP CONDITIONS removed. EXECUTION MODE language aligned with unified prompt. Template 1 execution mode label updated from CC Challenge to Challenge Agent. |
| v3.3 | April 2026 | Wave 5 agentic build changes: Template 2B — Session Execution Prompt added. Ten sections: execution mode, agent identity, repository context, what has already been built, planning artifacts, scope boundary, task prompt immutability, session tasks, artifact paths, stop conditions and output formats (PBVI-T-001, PBVI-T-002). |
| v3.2 | April 2026 | Wave 4 agentic build changes: Verification Record Template 2 — CC Challenge Output section replaced with Challenge Agent Output section. Structure updated: verdict field, four evidence tables, finding dispositions table. Verification Verdict checklist updated — CC challenge reviewed replaced with challenge agent verdict and findings disposition checkboxes; pre-commit declaration checkbox added (PBVI-M-009). |
| v2.9 | April 2026 | Initial release — templates extracted from PBVI skill to standalone file. Contains: Session Log, Verification Record, ENH-NNN_SCOPE.md, Enhancement Brief, Sprint Manifest, Sprint Log, ENH-NNN_SPRINT_CONSTRAINTS.md. ENH-NNN_BCE_IMPACT.md maintained exclusively in BCE skill. |
| v3.1 | April 2026 | Session Log: SIGNED OFF machine-readable marker added to Session Completion; Resumed Sessions table extended with Resolved at and Root cause fields (PLANNING GAP / ENVIRONMENTAL / SCOPE CREEP); Out of Scope Observations section added between Deviations and Claude.md Changes. ENH-NNN_SCOPE.md: Phase 3 Gate — Tier Reconfirmation section added as Section 7; Engineer Sign-Off renumbered to Section 8. |
| v3.0 | April 2026 | Invariant scope split — Template 2 Code Review references TASK-SCOPED invariants from task prompt and GLOBAL from Claude.md. Template 3 Section 4 adds GLOBAL/TASK-SCOPED classification table. Section 5 clarifies TASK-SCOPED additions do not trigger Claude.md version bump. Section 6 Tier 3 criteria updated to match. |

---

## How to Use This File

Load this file as a project file alongside the PBVI skill. When the skill instructs
"generate using the template from PBVI_TEMPLATES", use the corresponding template here.

**ENH-NNN_BCE_IMPACT.md is NOT in this file.** It is maintained exclusively in the
BCE skill. Load the BCE skill as a project file to access it.

**Template integrity rules apply to all templates here:**
- Fields marked LEAVE BLANK must never be pre-populated
- Fields marked pre-populate from EXECUTION_PLAN.md are populated at template creation
- Prediction statements are left blank in Manual mode; omitted entirely in Autonomous mode
- Human sign-off fields are never pre-filled

---

## Template 1 — Session Log (SESSION_LOG.md)

**When to generate:** At the start of every build session, before the first task begins.
**Pre-populate:** Task Id and Task Name from EXECUTION_PLAN.md. Leave Status and Commit blank.
**Leave blank:** All status fields, commit hashes, sign-off, decision log, deviations.

```markdown
# SESSION_LOG.md

## Session: [Session Name]
**Date started:** 
**Engineer:** 
**Branch:** session/s[n]_<short_desc>
**Claude.md version:** 
**Execution mode:** [ ] Manual (prediction discipline, prediction before verification)
                  | [ ] Autonomous (sequential, no interruption, no prediction)
**Status:** In Progress

## Pre-Build Validation — [datetime]

### Schema Validation
**Verdict:** PASS / WARN / HALT

| Check | Status | Notes |
|---|---|---|
| Section 1: System Intent | PRESENT / MISSING | |
| Section 2: Hard Invariants | PRESENT / MISSING | |
| Section 3: Scope Boundary | PRESENT / MISSING | |
| Section 4: Fixed Stack | PRESENT / MISSING | |
| Section 5: Rules | PRESENT / MISSING | |
| METHODOLOGY_VERSION | PRESENT / MISSING / MISMATCH | |
| CQ-001 complexity invariant | PRESENT / MISSING | |
| ID references resolved | ALL VALID / [N] STALE-OR-INVALID / N-A | |

### Interpretation Confirmation
**Modules I will modify:** [list]
**Invariants I will respect:** [list with statements]
**Blast radius:**
  In scope: [list]
  Out of scope: [list]
  Integration points: [list]
  Entities: [list]

**Engineer response:** CONFIRMED | MODULES-WRONG | INVARIANTS-WRONG | BLAST-RADIUS-WRONG
**Engineer notes:** [if WRONG response, captured rationale]
**Proceed to first task:** YES / NO

---

## Tasks

| Task Id | Task Name | Status | Commit |
|---------|-----------|--------|--------|
| [n.n]   | [name]    |        |        |

Valid Status values: Completed | BLOCKED | SKIPPED
SKIPPED is set by the engineer manually outside of any execution prompt.
BLOCKED is set by CC on verification failure in Autonomous mode.

---

## Resumed Sessions (Autonomous mode only)

| Resumed at | Resumed from Task | Blocking issue resolution | Resolved at | Root cause |
|------------|-------------------|--------------------------|-------------|------------|
|            |                   |                           |             |            |

Leave this table empty if the session was not resumed.

Root cause values: PLANNING GAP | ENVIRONMENTAL | SCOPE CREEP
- PLANNING GAP: a planning assumption was wrong — loop may be required
- ENVIRONMENTAL: infrastructure or config issue — no loop required
- SCOPE CREEP: agent exceeded its scope boundary — review session output

The engineer fills Resolved at and Root cause at resolution time, not at
the point of the BLOCKED stop. These fields are never pre-filled by the agent.

---

## Decision Log

| Task | Decision made | Rationale |
|------|---------------|-----------|
|      |               |           |

---

## Deviations

| Task | Deviation observed | Action taken |
|------|--------------------|--------------|
|      |                    |              |

---

## Out of Scope Observations

[Items noticed during build that are outside this session's scope.
Each item is recorded here and deferred — not acted on by the agent.
Engineer reviews at session sign-off and determines disposition.]

| Task | Observation | Nature | Recommended action |
|------|-------------|--------|--------------------|
|      |             |        |                    |

Nature values: BUG | MISSING | FRAGILITY
Disposition at sign-off: BACKLOG | DISMISS | IMMEDIATE (requires loop)

Leave this table empty if no out-of-scope items were noticed.

---

## Claude.md Changes

| Change | Reason | New Claude.md version | Tasks re-verified |
|--------|--------|-----------------------|-------------------|
| None   |        |                       |                   |

---

## Session Completion
**Session integration check:** [ ] PASSED
**All tasks verified:** [ ] Yes
**Blocked tasks resolved:** [ ] Yes — N/A if no BLOCKED tasks occurred
**PR raised:** [ ] Yes — PR #: [branch] → main
**Status updated to:** 
**Engineer sign-off:** 
SIGNED OFF: [name] — [date]

Note: The SIGNED OFF line is machine-readable. It must appear exactly
as shown — no bold markers, no other formatting. The launcher serial
gate greps for `^SIGNED OFF:` and will fail if the line is wrapped in
markdown (`**SIGNED OFF:**`). Do not use any other phrasing for sign-off.
```

---

## Template 2 — Verification Record (VERIFICATION_RECORD.md)

**When to generate:** Per task, at the start of each task before running any commands.
**Pre-populate:** Task ID, Task Name, Scenario, Expected from EXECUTION_PLAN.md.
**Leave blank:** Result column, Prediction Statement (Manual) or omit entirely (Autonomous),
Challenge Agent Output, Code Review results, Scope Decisions, BCE Impact, all verdict
checkboxes, Finding dispositions table.

```markdown
**Session:** [Session Name]
**Date:** 
**Engineer:** 

## [Task n.n — Task Name]

### Test Cases Applied
Source: EXECUTION_PLAN.md Session [n]

| Case | Scenario | Expected | UI Tests | Result |
|------|----------|----------|----------|--------|
| TC-1 | [from execution plan] | [from execution plan] | [WRITTEN — N assertions \| TODO(N) — reason \| N/A] | |
| TC-2 | [from execution plan] | [from execution plan] | | |

> **UI Tests column (PBVI-009):** Required only for tasks with a UI test spec
> (EXECUTION_PLAN.md item 7). Values: `WRITTEN — N assertions` when Playwright
> assertions are committed alongside implementation; `TODO(N) — reason` when N
> assertions are marked `todo()` pending a future task (state which task); `N/A`
> when the task does not touch a UI surface. Engineer confirms at task sign-off.

### Prediction Statement
[LEAVE BLANK — engineer writes predictions before running verification commands]

### Challenge Agent Output
[Written by the build agent from ./tools/challenge.sh output.
Leave blank at template creation — populated during task execution.]

**Verdict:** CLEAN | FINDINGS

**Untested scenarios:**
[From challenge agent output — or write NONE if CLEAN verdict]

**Unverified assumptions:**
[From challenge agent output — or write NONE if CLEAN verdict]

**Invariant coverage gaps:**
[From challenge agent output — or write NONE if CLEAN verdict]

**Scope boundary observations:**
[From challenge agent output]

**Finding dispositions (FINDINGS verdict only):**

| Finding # | Disposition | Rationale / Test case added | Test result |
|-----------|-------------|------------------------------|-------------|
|           |             |                              |             |

Leave Finding dispositions table empty if verdict is CLEAN.

### Code Review
[Required only if this task touches an invariant. For TASK-SCOPED invariants,
the invariant text is already embedded in the task's CC prompt in EXECUTION_PLAN.md
— reference it here. For GLOBAL invariants, source from Claude.md Section 2.
List specific code review items: what to look for and where. Leave results blank.]

### Scope Decisions
[What was accepted as out of scope and why. Cannot be left blank for deliverables.]

### BCE Impact
[Required when this task touches a module with a MODULE_CONTRACTS.md entry.
If no BCE artifact is affected, write: No BCE artifact impact.]

| Artifact | Field | Change |
|---|---|---|

### Verification Verdict
[ ] All planned cases passed
[ ] Challenge agent run — verdict recorded (CLEAN or FINDINGS)
[ ] All FINDINGS dispositioned — ACCEPT with rationale or TEST with result
[ ] Pre-commit declaration recorded
[ ] Code review complete (if invariant-touching)
[ ] Scope decisions documented

**Status:**
```

---

## Template 2B — Session Execution Prompt

**When to generate:** At the end of Phase 5, after Claude.md is committed.
One file per session in EXECUTION_PLAN.md.
**Path (greenfield):** `sessions/S[N]_execution_prompt.md`
**Path (enhancement):** `sessions/SPRINT-NNN/ENH-NNN/S[N]_execution_prompt.md`
**Leave blank:** Nothing — this is a complete reference document when generated.
**Gate:** All files committed before Phase 6 begins.
```markdown
# S[N] Execution Prompt — [Project / ENH-NNN] — [Session Title]

**Session:** S[N]
**Project / Enhancement:** [project slug or ENH-NNN]
**Branch:** session/s[N]_[short_desc]
**Produced:** Phase 5 — [date]

---

## EXECUTION MODE

[Autonomous | Manual] — declare the mode for this session.

Autonomous: Execute all tasks sequentially without pausing between tasks unless
a human gate is explicitly marked in EXECUTION_PLAN.md. Do not pause for
prediction statements — this mode does not use them.

Manual: Pause after each task for the engineer's prediction statement, challenge
finding dispositions, and commit confirmation before proceeding to the next task.

---

## AGENT IDENTITY

You are the build agent for [project / ENH-NNN], Session S[N].
You have no memory of prior sessions. All context you need is in this file
and the planning artifacts listed below.
Do not infer context from session logs or other files not listed here.

---

## REPOSITORY CONTEXT

Repo root: [absolute path]
Session branch: session/s[N]_[short_desc]

Before any task work: confirm this branch exists and you are on it.
If it does not exist: stop immediately. Output:

  LAUNCH ERROR
  ------------
  Branch session/s[N]_[short_desc] not found.
  Create branch before launching this session.

Then read PROJECT_MANIFEST.md and locate the METHODOLOGY_VERSION field.
Compare it against the version in the loaded PBVI skill's frontmatter.
If they match: proceed silently.
If they differ or the field is absent: output the following, then continue —
do not stop the session.

  METHODOLOGY VERSION WARNING
  ---------------------------
  Skill version:    [from skill frontmatter]
  Project version:  [from METHODOLOGY_VERSION field, or NOT DECLARED]

  This project was initialised under a different methodology version.
  Proceeding may produce incomplete or unexpected results.
  Consult BREAKING_CHANGES.md in the DG-Forge repo before continuing.

---

## WHAT HAS ALREADY BEEN BUILT

[S01: write exactly — "This is the first session. Repository scaffolded.
No prior session state."]

[S02 onward: one paragraph — what the prior session delivered, what
invariants were verified, what state the system is in at the start of
this session. Written during Phase 5 while the plan is fresh.]

---

## PLANNING ARTIFACTS — READ BEFORE TASK 1

Read these files in order before beginning Task 1:

1. docs/Claude.md — your execution contract. Governs everything.
2. [docs/EXECUTION_PLAN.md | enhancements/SPRINT-NNN/ENH-NNN/ENH-NNN_EXECUTION_PLAN.md]
3. [enhancements/SPRINT-NNN/ENH-NNN/ENH-NNN_SPRINT_CONSTRAINTS.md]
   (Enhancement only — omit for greenfield.)

If any listed file is missing: stop immediately. Output:

  LAUNCH ERROR
  ------------
  [filename] not found.
  Cannot begin session without complete planning artifacts.

---

## STEP 0 — PRE-BUILD VALIDATION (mandatory, no exceptions)

Run Phase 6 Pre-Build Validation before executing any task.

Step A — Claude.md schema validation
  Read Claude.md and ID_REGISTRY.md (if present).
  Run all schema checks per pbvi_core.md Phase 6 Pre-Build Validation Step A.
  Output the SCHEMA VALIDATION RESULT table.
  If verdict is HALT: record in SESSION_LOG Pre-Build Validation section.
  Output: PRE-BUILD-PAUSED (HALT — schema invalid). Stop session.

Step B — Interpretation confirmation (only if Step A is PASS or WARN)
  Read the first task in the session execution plan.
  Query SYSTEM_GRAPH.json (if present) for entry point modules in
  Claude.md Section 3 using bce_core.md Section 16 mechanics at depth 2.
  Produce three statements per pbvi_core.md Phase 6 Pre-Build Validation
  Step B: modules I will modify, invariants I will respect, blast radius.
  Write both Step A and Step B blocks to SESSION_LOG Pre-Build Validation
  section before outputting.

  [HUMAN GATE — INTERPRETATION CONFIRMATION]
  Engineer reviews and responds:
    CONFIRMED — proceed to SCOPE BOUNDARY and first task.
    MODULES-WRONG / INVARIANTS-WRONG / BLAST-RADIUS-WRONG —
    record in SESSION_LOG, output PRE-BUILD-PAUSED (WRONG). Stop session.

Re-run check: If SESSION_LOG already contains CONFIRMED from this session's
Pre-Build Validation block, skip the HUMAN GATE and proceed directly to SCOPE BOUNDARY.

---

## SCOPE BOUNDARY

You may only create or modify these files:
[list exact files — scoped to this session's tasks, not the full project scope]

---

## TASK PROMPT IMMUTABILITY

The task prompt in EXECUTION_PLAN.md is a contract, not a starting point.
Execute it exactly as written. The following are not permitted:
- Extending the task beyond its stated scope
- Adding functionality not specified in the task prompt
- Fixing adjacent issues encountered during execution
- Improving code outside the task boundary

If something outside scope is noticed: record it in Out of Scope
Observations in SESSION_LOG.md. Do not act on it.

---

## SESSION TASKS

Execute tasks [T-NN] through [T-NN] from [EXECUTION_PLAN.md path].
Use the exact task prompt as written. Do not paraphrase. Do not combine.
Do not skip.

---

## ARTIFACT PATHS FOR THIS SESSION

SESSION_LOG:          [sessions/S[N]_SESSION_LOG.md |
                       sessions/SPRINT-NNN/ENH-NNN/S[N]_SESSION_LOG.md]
VERIFICATION_RECORD:  [sessions/S[N]_VERIFICATION_RECORD.md |
                       sessions/SPRINT-NNN/ENH-NNN/S[N]_VERIFICATION_RECORD.md]

Create both at session start per template integrity rules. Do not pre-fill result fields.

---

## GIT HYGIENE

After each task completes and its verification passes:
1. Stage only the files modified by that task
2. Commit — see step 12 in TASK-LEVEL VERIFICATION for the required format
3. Do not batch multiple tasks into a single commit

Command execution — critical: Do NOT chain commands using &&. Run each
command as a separate, sequential step.

---

## TASK-LEVEL VERIFICATION (strict order — applies to both modes)

For each task:
1. Create/update the Verification Record. Pre-populate Task ID, Task Name,
   Scenario, and Expected from EXECUTION_PLAN.md.
   Manual: include the Prediction Statement section — leave blank at creation.
   Autonomous: omit the Prediction Statement section entirely — do not leave
   it blank, remove it from the record.
   Leave Result, Challenge Agent Output, BCE Impact, and Verdict checkboxes blank.
2. Run the task CC prompt from EXECUTION_PLAN.md exactly as written.
3. Manual only — STOP. Present the task output summary and wait for the engineer
   to write their prediction statement before proceeding to step 4.
   Autonomous: proceed directly to step 4.
4. Run the verification command and evaluate all test cases. Record results.
5. If verification fails: invoke FAILURE HANDLING immediately. Do not proceed
   to steps 6–14.
6. FILE BOUNDARY CHECK — run: git diff --name-only HEAD
   Compare every file against the SCOPE BOUNDARY list above.
   If any file is not on the permitted list: invoke SCOPE VIOLATION handling.
   Do not proceed to step 7.
7. PRE-COMMIT DECLARATION — output the following block and write it to the
   Verification Record before any commit:

   PRE-COMMIT DECLARATION — [Task ID]
   -----------------------------------
   Files modified:     [git diff --name-only HEAD output]
   Functions added:    [list or NONE]
   Functions modified: [list or NONE]
   Functions deleted:  [list or NONE]
   Schema changes:     [list or NONE]
   Config changes:     [list or NONE]

   Everything above is within the task prompt scope: YES / NO

   If NO on any item: invoke SCOPE VIOLATION handling. Do not proceed to step 8.

8. CHALLENGE AGENT — run: ./tools/challenge.sh S[N] [TASK_ID]
   The challenge agent receives: docs/Claude.md, this task's section from
   EXECUTION_PLAN.md, git diff for this task, this task's Verification Record
   entries, docs/INVARIANTS.md. No build session context.
   The challenge agent evaluates: untested scenarios, unverified assumptions,
   invariant coverage gaps, scope boundary observations, and structural complexity
   — conditional nesting depth and single-purpose compliance per new or modified
   function against the core definition in Claude.md. Structural complexity verdict:
   CLEAN or FINDINGS. Engineer dispositions structural complexity findings per the
   existing ACCEPT-with-rationale or TEST mechanism.
   Write full output to the Challenge Agent Output section of Verification Record.
   CLEAN → proceed to step 9.
   FINDINGS → invoke CHALLENGE FINDINGS handling. Do not proceed to step 9.

   MANDATORY PRE-COMMIT GATE: Before proceeding to step 9, confirm the Challenge
   Agent Output section of this task's Verification Record shows a CLEAN or FINDINGS
   verdict. If absent — challenge agent was not run. Do not commit. Run step 8 now.

9. BCE Impact: check discovery/ for MODULE_CONTRACTS.md entries for any module
   touched by this task. Record impact or write "No BCE artifact impact."
10. Out of Scope Observations: record anything noticed outside task scope in the
    Out of Scope Observations table in SESSION_LOG. Do not act on it.
11. Record PASS verdict — confirm all checkboxes.
12. Commit:
    Manual:
    [SESSION_NUMBER].[TASK_NUMBER] — [Task Name]: [one-line summary]

    Autonomous:
    [S][N].[TASK_N] — [Task Name]: [one-line summary]

    Scope: within Claude.md boundary — YES
    Files: [list every file created or modified]
    Invariants touched: [INV-XX list — or NONE]
    Pre-commit declaration: recorded in VERIFICATION_RECORD

13. Update session log.
14. Manual: STOP. Confirm with the engineer before proceeding to the next task.
    Autonomous: Proceed immediately to the next task.

---

## FAILURE HANDLING

If any verification command produces a failing result:
1. Do not attempt to fix the failure.
2. Record BLOCKED in the session log (Status = BLOCKED, Commit = none).
3. Write full verification output verbatim into Verification Record Result field.
4. Write failure classification: ENVIRONMENTAL | SCOPE GAP | UNKNOWN
5. Stop the session. Do not proceed to the next task under any circumstances.
6. Output:

   SESSION BLOCKED
   ---------------
   Task ID:              [task id]
   Task Name:            [task name]
   Verification command: [exact command that failed]
   Failure output:       [full output verbatim]
   Classification:       [ENVIRONMENTAL | SCOPE GAP | UNKNOWN]
   Engineer action:      Resolve the blocking issue, then use the Resume prompt
                         to continue from this task.

---

## CHALLENGE FINDINGS HANDLING

If challenge agent returns a verdict of FINDINGS:
1. Do not commit.
2. Record CHALLENGE FINDINGS in session log (Status = CHALLENGE FINDINGS,
   Commit = none).
3. Output:

   CHALLENGE FINDINGS
   ------------------
   Session:  S[N] — [project/ENH-NNN]
   Task:     [Task ID] — [Task Name]
   Findings: [N]

   [paste full challenge agent output]

   Engineer action: for each finding, respond with one of:
     ACCEPT [N] — [rationale]
       Gap acknowledged. Rationale recorded in Verification Record.
       No test required. Session continues after all findings dispositioned.
     TEST [N] — [test case description]
       Add the specified test case, run it immediately, record the result.
       If PASS: continue dispositionning remaining findings.
       If FAIL: invoke FAILURE HANDLING. Session stops.

4. Manual: wait for engineer to disposition all findings in the conversation.
   Resume from step 9 after all findings are dispositioned.
   Autonomous: stop the session.
   Resume: ./tools/resume_challenge.sh [mode] [identifier] S[N] [Task ID]

---

## SCOPE VIOLATION HANDLING

If file boundary check (step 6) or pre-commit declaration (step 7) identifies
a scope violation:
1. Do not commit.
2. Record SCOPE VIOLATION in session log (Status = SCOPE VIOLATION, Commit = none).
3. Output:

   SCOPE VIOLATION
   ---------------
   Session:    S[N] — [project/ENH-NNN]
   Task:       [Task ID] — [Task Name]
   Violation:  FILE_BOUNDARY | TASK_OVERREACH | PRE_COMMIT_MISMATCH
   Detail:     [specific file, function, or behaviour outside scope]
   Evidence:   [git diff --name-only output or declaration mismatch]

   Violation types:
   - FILE_BOUNDARY: a file outside the permitted list was modified
   - TASK_OVERREACH: a function, schema change, or config change not
     required by the task prompt was made within permitted files
   - PRE_COMMIT_MISMATCH: declaration self-certification returned NO

   Engineer action:
     ACCEPT [violation] — [rationale]: scope boundary update required.
     REVERT: git checkout -- . then ./tools/resume_session.sh [args]

4. Stop the session. Do not proceed to the next task under any circumstances.

---

## HUMAN GATES

If EXECUTION_PLAN.md marks a task or decision point as [HUMAN GATE], stop and
wait for engineer input before proceeding. Human gates override autonomous mode.

---

## SCOPE AND INVARIANT RULES

- Invariant conflict: invariant wins. Flag it; never resolve silently.
- Gap not covered by task prompt or Claude.md: do the minimum and flag the gap.
- No design decisions not covered by Claude.md or EXECUTION_PLAN.md.

---

## SESSION COMPLETE

When all tasks complete with PASS verdicts, output exactly:

  SESSION COMPLETE
  ----------------
  Session:      S[N] — [project/ENH-NNN]
  Tasks:        [N] completed, 0 blocked, 0 scope violations, 0 findings
  Branch:       session/s[N]_[short_desc]
  Final commit: [hash]
  Artifacts:    [SESSION_LOG path], [VERIFICATION_RECORD path]
  Scope clean:  YES

  Engineer action: review artifacts and sign off SESSION_LOG.

---

Begin by reading all PLANNING ARTIFACTS in order and confirming session state.
Manual: present the task list for this session and wait for the engineer to
confirm before starting the first task.
Autonomous: execute all tasks in this session sequentially.
```

---

## Template 3 — ENH-NNN_SCOPE.md

**When to generate:** At scoping gate before build begins. Engineer declares Sign-Off Tier here.
**Leave blank:** Engineer Sign-Off section.

```markdown
# ENH-NNN_SCOPE.md — [Enhancement Name]
**Enhancement:** ENH-NNN
**Engineer:** [name]
**Type:** A | B
**Status:** IN SCOPING | SCOPED | IN EXECUTION | COMPLETE

## 1. Enhancement Summary
[One paragraph — what this enhancement does and why]

## 2. Scope
**In scope:**
[Explicit list of what will change]

**Out of scope:**
[Explicit list of what will not change — not "TBD", must be stated]

## 3. BCE Impact Assessment
[Planning declaration only — states expected impact for scoping purposes.
Do not update discovery/ artifacts here. In a sprint context, all discovery/
updates are deferred to sprint close-out via Sprint Lead BCE refresh.]
[List affected artifacts — or state "No BCE artifact impact expected" if none]

## 4. Invariants Touched
[List each invariant from INVARIANTS.md that this enhancement touches, enforces, or adds.
For each, state its scope tag and action:]

| INV-ID | Scope | Action | Notes |
|---|---|---|---|
| INV-XX | GLOBAL \| TASK-SCOPED | TOUCHES \| ENFORCES \| ADDS | |

Adding a GLOBAL invariant requires a Claude.md Section 2 amendment (see Section 5).
Adding a TASK-SCOPED invariant requires embedding in EXECUTION_PLAN.md task prompts — no Claude.md amendment.
State "No invariant impact" if none — not blank.

## 5. Claude.md Impact
**Version bump required:** YES | NO
**Reason:** [if YES — what changes and why]

A version bump is required when: a new GLOBAL invariant is added, the scope boundary
changes, or a new prohibited behaviour is defined. Adding only TASK-SCOPED invariants
does not require a Claude.md version bump.

## 6. Sign-Off Tier

**Tier:** [ 1 | 2 | 3 ]

Decision criteria:
- Tier 1: Type A, single session, no invariant additions, no schema changes,
  no Claude.md version bump
- Tier 2: Type A multi-session OR invariant enforcement point changes
  (not new invariants — changes to how existing invariants are enforced or documented)
- Tier 3: Type B (new invariants, schema changes, or Claude.md version bump).
  New GLOBAL invariants require a Claude.md Section 2 amendment. New TASK-SCOPED
  invariants do not — but the enhancement is still Tier 3 and requires a full
  invariant sweep.

**Part 1 sign-off artifact:**
- Tier 1: Session Log engineer sign-off + all Verification Record verdicts PASS
- Tier 2: ENH-NNN_VERIFICATION_CHECKLIST.md — changed invariants only
- Tier 3: ENH-NNN_VERIFICATION_CHECKLIST.md — full invariant sweep for touched INVs

BCE Close-Out (Part 2B) triggers on Part 1 sign-off regardless of tier.

**Tier change rule:** If the tier changes during build, update this field and
re-declare before the session continues. Do not proceed with a stale tier declaration.

## 7. Phase 3 Gate — Tier Reconfirmation

**Trigger:** Engineer runs this check before beginning Phase 3 (execution planning).
**Tool:** CD — as part of the Phase 3 gate conversation.

Before proceeding to Phase 3, confirm the following in CD:

[ ] The Sign-Off Tier declared in Section 6 remains appropriate given
    what Phases 1 and 2 surfaced.

If the Tier is unchanged: check the box and proceed to Phase 3.

If the Tier has changed: update Section 6 of this document with the
new Tier, the updated decision criteria, and the updated Part 1
sign-off artifact before proceeding. Record the reason for the
change below.

**Tier change record (leave blank if unchanged):**
Previous Tier: [  ]
New Tier: [  ]
Reason: [what surfaced in Phases 1–2 that changed the assessment]
Date updated: [date]

**Reconfirmation sign-off:** [name] — [date]

## 8. Engineer Sign-Off (Scoping Gate)
I confirm the scope, BCE impact, invariant assessment, and Sign-Off Tier above are
accurate to my current understanding before build begins.

**Signature:** [engineer name]
**Date:** [YYYY-MM-DD]
```

---

## Template 4 — Enhancement Brief (ENH-NNN_BRIEF.md)

**When to generate:** When an enhancement is created in the backlog. Brief matures over time.
**Review gate:** Brief review gate (Prompt 1) must pass and engineer must sign off
before brief can be included in Sprint Manifest analysis.
**Leave blank:** AI Review and Sign-Off status until gate passes.

```markdown
# ENH-NNN_BRIEF.md

**Enhancement ID:** ENH-NNN
**Title:** [Short title]
**Author:** [Engineer name]
**Date:** [Date authored]
**Status:** [ ] Draft | [ ] AI Review Complete | [ ] Signed Off

---

## Enhancement Intent
[One paragraph — plain language, what this enhancement does and why.
Not a technical specification. Legible to any engineer on the team.]

---

## Known Touch Points
[Modules, schema tables, API routes this enhancement is expected to touch.
Terminology must resolve against BCE artifact entries where possible.]

| Touch Point | BCE Artifact | Entry |
|---|---|---|
| [e.g. token ledger table] | TOPOLOGY.md | [e.g. schema/token_ledger] |

---

## Known Constraints
[Label each constraint MANDATORY or OPTIONAL.]

| Constraint | Type | Notes |
|---|---|---|
| [e.g. must not modify existing auth flow] | MANDATORY | [reason] |
| [e.g. prefer existing middleware pattern] | OPTIONAL | [can be revisited in Phase 1] |

---

## Out of Scope
[Explicit statement of what this enhancement will not touch. Not "TBD."]

---

## Engineer Sign-Off
[ ] I confirm this brief is accurate to my current understanding.
    Phase 1 may surface new information not reflected here.

**Signed:** [Engineer name]
**Date:** [Date]
```

---

## Template 5 — Sprint Manifest (SPRINT-NNN_MANIFEST.md)

**When to generate:** Sprint Lead produces this from adjudicated collision surface analysis.
Produced in CD using Prompt 2 then Prompt 3. Committed before any Phase 1 begins.
**Leave blank:** Sprint Lead sign-off until adjudication is complete.

```markdown
# SPRINT-NNN_MANIFEST.md

**Sprint ID:** SPRINT-NNN
**Timebox:** [Start date] → [End date]
**Sprint Lead:** [Name]
**Status:** [ ] Draft | [ ] Committed

---

## Enhancement List

| ENH ID | Title | Classification | Depends On |
|---|---|---|---|
| ENH-NNN | [title] | FOUNDATION / DEPENDENT / INDEPENDENT | ENH-NNN or blank |

---

## Invariant Drift Items

[Populated from Sprint CC Initiation harness check. Leave empty if HARNESS.sh is absent
or all drift items were DEFERRED or DISMISSED.]

| DRIFT ID | Invariant ID | Severity | Brief |
|---|---|---|---|
| DRIFT-NNN | INV-NNN | CRITICAL / WARNING | [ ] DRIFT-NNN_BRIEF.md signed off |

DRIFT items are always addressed before any ENH work begins.
DEFERRED and DISMISSED items remain in enhancements/backlog/ and are not listed here.

---

## Dependency Graph

[Written description of all Foundation → Dependent relationships.
Independent enhancements listed separately.
Multiple Foundation tracks listed as parallel chains.
Any chain deeper than one level must be resolved before commit.]

**Chain depth validation:**
[ ] PASS — no chains deeper than one level
[ ] VIOLATION — [detail which chain and resolution required]

---

## Collision Surface Map

[One block per enhancement pair with any identified collision.
Pairs with no collision are not listed.]

### ENH-NNN × ENH-NNN

**Detection mode:** GRAPH | PROSE
**Surface ID:** [M-NNN | IC-N | IP-NNN | E-NNN | N-A for prose-only findings]
**Surface name:** [readable name from ID_REGISTRY.md, or BCE artifact entry for prose-only]
**Hop distance from each entry (graph mode only):**
  ENH-NNN entry [M-NNN]: [N hops]
  ENH-NNN entry [M-NNN]: [N hops]
**Edge types involved (graph mode only):** [list]
**Collision type:** BUILD-TIME | CLOSE-OUT
**Confidence:** GRAPH-DEFINITE | PROSE-DEFINITE | PROSE-PROBABLE | PROSE-NOT-DETECTABLE
**ENH-NNN intent:** [what this enhancement intends to do with this surface]
**ENH-NNN intent:** [what this enhancement intends to do with this surface]
**Conflict nature:** [why these intents conflict or may conflict]
**Ownership:** [ENH-NNN owns this surface | Close-out reconciliation — no build-time owner]
**Sprint Lead adjudication:** [Confirmed / Downgraded / Ruled out]
**Notes:** [Sprint Lead adjudication rationale]

---

## Watchpoints

[Not-detectable surfaces assigned to specific engineers for Phase 1 confirmation.
Each watchpoint is a mandatory Phase 1 confirmation task — not optional monitoring.]

| ID | Enhancement | Surface | What Phase 1 Must Confirm | Assigned To |
|---|---|---|---|---|
| WP-001 | ENH-NNN | [BCE artifact entry] | [specific question] | [engineer] |

---

## Close-Out Reconciliation Items

[Enhancements sharing a BCE artifact section — Sprint Lead reconciles at close-out.]

| ENH IDs | BCE Artifact | Section | Nature of Overlap |
|---|---|---|---|
| ENH-NNN × ENH-NNN | [artifact] | [section] | [description] |

---

## Sprint Scope Validation

**Chain depth:** [ ] PASS | [ ] VIOLATION — [details]
**Foundation loop risk:**
[ ] Low — all Foundation enhancements are shallow and well-scoped
[ ] Flagged — [which Foundation, why, Sprint Lead risk determination]

---

## Sprint Lead Sign-Off

[ ] All Enhancement Briefs signed off — brief review gate passed for each
[ ] All DRIFT-NNN_BRIEF.md signed off — Sprint Lead acknowledgement recorded in sprint log
[ ] All briefs included in analysis — unsigned briefs and unsigned drift briefs identified and excluded
[ ] DRIFT items included in collision surface analysis
[ ] Collision surface analysis complete — all enhancement pairs reviewed
[ ] All DEFINITE and PROBABLE build-time collisions have ownership assignments
[ ] Chain depth rule satisfied — no chains deeper than one level
[ ] Watchpoints assigned to responsible engineers
[ ] Close-out reconciliation items recorded
[ ] ENH-NNN_SPRINT_CONSTRAINTS.md produced and reviewed for each building engineer
[ ] PROJECT_MANIFEST.md updated — all sprint and enhancement artifacts registered

**Signed:** [Sprint Lead name]
**Date:** [Date]
```

---

## Template 6 — Sprint Log (SPRINT-NNN_LOG.md)

**When to generate:** At sprint initiation. Sprint Lead maintains throughout sprint.
**Pre-populate:** Enhancement list from Sprint Manifest.
**Leave blank:** All event log entries, sync points, integration check results, close-out until they occur.

```markdown
# SPRINT-NNN_LOG.md

**Sprint ID:** SPRINT-NNN
**Timebox:** [Start date] → [End date]
**Sprint Lead:** [Name]
**Status:** OPEN | INTEGRATION CHECK | CLOSED

## Enhancements

| ENH ID | Title | Classification | Depends On | Engineer |
|---|---|---|---|---|
| ENH-NNN | [title] | FOUNDATION / DEPENDENT / INDEPENDENT | ENH-NNN or blank | [name] |

---

## Invariant Drift Items

[Populated at Sprint CC Initiation from harness check. Leave empty if none SPRINT-MANDATORY.]

| DRIFT ID | Invariant ID | Severity | Disposition | Engineer |
|---|---|---|---|---|
| DRIFT-NNN | INV-NNN | CRITICAL / WARNING | SPRINT-MANDATORY | [name] |

---

## Sprint CC Initiation

**Date:** [date]
**Trigger:** "Initiate sprint SPRINT-NNN" in CC
**Harness check:** [ ] PASS | [ ] FAILURES FOUND | [ ] N/A — HARNESS.sh not present

| Total assertions | Passed | Failed | CRITICAL failures | WARNING failures |
|---|---|---|---|---|
|  |  |  |  |  |

**DRIFT item dispositions:**

| DRIFT ID | Invariant ID | Severity | Disposition | Override rationale (CRITICAL DEFERRED only) |
|---|---|---|---|---|
| DRIFT-NNN | INV-NNN | CRITICAL / WARNING | SPRINT-MANDATORY / DEFERRED / DISMISSED |  |

**Sprint scope confirmed:** [ ] Yes — [N] ENH items + [N] DRIFT items
**Sprint Lead sign-off on dispositions:** [name] — [date]

---

## Pre-Sprint Record

**Sprint Manifest committed:** [ ] Yes — Date: [date]
**PROJECT_MANIFEST.md updated:** [ ] Yes
**ENH-NNN_SPRINT_CONSTRAINTS.md distributed:** [ ] Yes

| ENH ID | SPRINT_CONSTRAINTS.md distributed | Engineer confirmed receipt |
|---|---|---|
| ENH-NNN | [ ] Yes | [ ] Yes |

---

## Sync Points

### Sync Point 1 — Foundation Claude.md Committed

[One entry per Foundation track.]

**Foundation ENH ID:** ENH-NNN
**Date committed:** [date]
**Claude.md version:** [version]
**Dependents cleared for Phase 3:** [ENH-NNN list or N/A]
**Sprint Lead confirmation:** [ ] Recorded

---

## Event Log

[Running record of sprint events. Add entries as they occur. Leave empty if none.]

### Event [N] — [STALL | RECLASSIFICATION | FOUNDATION AMENDMENT | LOOP]

**Date:** [date]
**Enhancement(s) affected:** ENH-NNN
**Description:** [What happened]
**Sprint Lead assessment:** [Determination and rationale]
**Dependents suspended:** [ENH-NNN list or NONE]
**Dependents cleared:** [Date cleared or PENDING]
**Action taken:** [What was done]

---

## Sprint Integration Check

**Trigger:** All Phase 8 Part 1 sign-offs complete
**Date:** [date]
**Sprint Lead:** [name]

**All Phase 8 Part 1 sign-offs confirmed:**

| ENH ID | Sign-Off Tier | Sign-Off Artifact | Confirmed |
|---|---|---|---|
| ENH-NNN | Tier 1 / 2 / 3 | [artifact] | [ ] Yes |

### Interaction Invariant Identification

**Combined change surface reviewed in CD:** [ ] Yes | [ ] Not required (single-enhancement sprint)

| Interaction Invariant | Enhancement Combination | Accepted |
|---|---|---|
| [invariant description] | ENH-NNN + ENH-NNN | [ ] Yes |

### Invariant Verification

Run in CC against fully assembled, running stack.

| Invariant | Source | ENH Scope Doc | Result |
|---|---|---|---|
| [invariant] | DECLARED / INTERACTION | ENH-NNN_SCOPE.md | PASS / FAIL |

### Failures

[Leave empty if all invariants PASS.]

| Failing Invariant | Affected Enhancement(s) | Loop Re-Entry Phase | Resolution Owner |
|---|---|---|---|

### Outcome

[ ] All invariants PASS — sprint close-out may begin
[ ] FAIL — loop re-entered, sprint boundary extended, close-out blocked

**Sprint Lead sign-off:**
**Date:**

---

## Sprint Close-Out

**Trigger:** Sprint Integration Check passed and signed off

**Steps completed:**

[ ] All enhancements merged to sprint branch
[ ] All ENH-NNN_BCE_IMPACT.md logs signed off — confirmed before BCE refresh begins
[ ] BCE refresh complete in CC — [N] artifacts updated
[ ] Conflicts resolved — [N] conflicts identified, all resolved with Sprint Lead judgment
[ ] ANNOTATION_CHECKLIST.md updated
[ ] Single sprint close-out commit to discovery/ — commit hash: [hash]
[ ] CD project files updated — all seven BCE artifacts uploaded
[ ] HARNESS.sh updated — HARNESS-CANDIDATE commands from all sprint ENH items merged
[ ] REGRESSION_SUITE.sh updated — REGRESSION-RELEVANT portable commands from all sprint ENH items merged
[ ] Post-close-out harness run complete
    Result: [ ] PASS — all assertions hold | [ ] CRITICAL FAIL — close-out blocked | [ ] WARNING FAIL only
    WARNING FAIL: [ ] New DRIFT item(s) created for next sprint — [DRIFT-NNN list or N/A]
[ ] REGISTRY.md updated — all enhancements COMPLETE, sprint status CLOSED

**Close-out date:** [date]
**Sprint Lead sign-off:** [name]
```

---

## Template 7 — ENH-NNN_SPRINT_CONSTRAINTS.md

**When to generate:** Sprint Lead produces this for each building engineer after manifest adjudication.
Generated in CD using Prompt 3. Sprint Lead reviews before distributing.
**Leave blank:** Nothing — this is a complete reference document when generated.

```markdown
# ENH-NNN_SPRINT_CONSTRAINTS.md

**Enhancement ID:** ENH-NNN
**Title:** [Enhancement title]
**Sprint:** SPRINT-NNN
**Engineer:** [Name]
**Classification:** FOUNDATION | DEPENDENT | INDEPENDENT
**Produced by:** Sprint Lead from SPRINT-NNN_MANIFEST.md
**Date:** [Date]

---

## Your Classification

**Role:** [FOUNDATION | DEPENDENT | INDEPENDENT]

[One paragraph plain-language explanation of what this classification
means for this engineer in this sprint — what they can begin immediately,
what they must wait for, what they own, what they must not touch.
Must be unambiguous without opening the manifest.]

---

## Surfaces You Own

[Build-time surfaces this enhancement owns. Other enhancements will not touch these.
If no owned surfaces: state explicitly "No owned surfaces."]

| Surface | BCE Artifact Entry | Conflict Avoided |
|---|---|---|
| [e.g. AuthMiddleware] | MODULE_CONTRACTS.md → AuthMiddleware | ENH-NNN will not touch this |

---

## Surfaces You Must Not Touch

[Build-time surfaces owned by other enhancements.
Touching these without Sprint Lead escalation is a process violation.
If none: state explicitly "No restricted surfaces for this sprint."]

| Surface | BCE Artifact Entry | Owned By |
|---|---|---|
| [e.g. token_ledger schema] | TOPOLOGY.md → schema/token_ledger | ENH-NNN |

---

## Your Phase 3 Gate

[DEPENDENT enhancements only. Leave blank for FOUNDATION and INDEPENDENT
with note: "Not applicable — [FOUNDATION/INDEPENDENT] classification."]

**You may not begin Phase 3 until:**
[ ] Foundation ENH-NNN Claude.md committed and frozen — Sync Point 1 recorded
[List all Foundation enhancements this enhancement depends on.]

**Planning inputs available at Phase 3:**
- Frozen `discovery/` BCE artifacts
- Foundation ENH-NNN Claude.md
- Foundation ENH-NNN draft BCE impact log [advisory — subject to amendment per GAP4 protocol]

---

## Your Watchpoints

[Phase 1 confirmation tasks assigned from the Sprint Manifest.
Mandatory — not optional monitoring. Escalate to Sprint Lead immediately if confirmed.]

| ID | Surface | What You Must Confirm in Phase 1 | Escalate If |
|---|---|---|---|
| WP-001 | [surface] | [specific question] | [collision confirmed] |

---

## BCE Constraints

**Do not update `discovery/` artifacts during your enhancement build or close-out.**

Your per-enhancement BCE deliverable is `ENH-NNN_BCE_IMPACT.md` only — produced at
Phase 8 Part 2B close-out. Updating `discovery/` for a single enhancement mid-sprint
is a process violation. Record BCE knowledge in Verification Record BCE Impact sections
and in `ENH-NNN_BCE_IMPACT.md`. The Sprint Lead reconciles all impact logs and updates
`discovery/` once at sprint close-out.

---

## Escalation Rules

1. Any Phase 1 discovery that surfaces a new collision not in the Sprint Manifest →
   stop planning, escalate to Sprint Lead immediately before continuing
2. Any watchpoint confirmed as a collision →
   stop planning, escalate to Sprint Lead immediately
3. Any build divergence requiring amendment to your BCE impact log →
   notify Sprint Lead unconditionally — do not self-assess downstream impact

---

## Sprint Lead Contact

**Sprint Lead:** [Name]
**SPRINT-NNN_MANIFEST.md:** `enhancements/SPRINT-NNN/SPRINT-NNN_MANIFEST.md`
**SPRINT-NNN_LOG.md:** `enhancements/SPRINT-NNN/SPRINT-NNN_LOG.md`
```

---

## Template 8 — Design Gate Record (docs/PHASE4_GATE_RECORD.md)

**When to generate:** After Phase 4 Step 1 structured plan review is complete, before
the Step 1 gate passes. The engineer fills this from the review session output.
Section E (Invariant Failure Mode Review) is filled during Phase 4 Step 2b.
Section F (UI Surface Review) is filled during Phase 4 Step 1c — present only when
APPLICATION_SURFACE contains UI; mark `N/A — not a UI project` otherwise.
**Pre-populate:** Nothing — engineer fills all sections from the Phase 4 review.
**Leave blank:** Dispositions, verdicts, ownership results, and engineer sign-off.

```markdown
# PHASE4_GATE_RECORD.md — [Project Name]
**Date:** [date]
**Engineer:** [name]
**Review session:** [CD session reference or date]

---

## Section A — Evaluation Criteria

| # | Criterion | Source |
|---|---|---|
| 1 | | Invariant: [INV-N] / Universal |
| 2 | | |
| 3 | | |
| ... | | |

---

## Section B — Requirements Traceability

| Requirement | Architecture Component | Task | Coverage Rating |
|---|---|---|---|
| | | | FULLY MET / PARTIALLY MET / NOT ADDRESSED / CONTRADICTED |

---

## Section C — Adversarial Stress Test Findings

| Attack Vector | Finding | Severity | Recommendation |
|---|---|---|---|
| DATA | | | |
| INFRASTRUCTURE | | | |
| EXECUTION | | | |
| SECURITY | | | |
| ARCHITECTURE vs PLAN GAP | | | |

---

## Section D — Risk Register with Dispositions

| # | Finding | Severity | Requirement or Invariant Affected | Return to Phase | Recommendation | Disposition | Rationale |
|---|---|---|---|---|---|---|---|
| | | | | | | RESOLVE / ACCEPT | |

**Overall verdict:** APPROVE / CONDITIONAL APPROVE / REVISE AND RESUBMIT
**Top 3 blockers:** [list or "none"]
**Confidence level:** [0–100%]

---

---

## Section E — Invariant Failure Mode Review

**When to fill:** During Phase 4 Step 2b. Work through each invariant in sequence.
For structural and data invariants: CD reads the Failure Mode from INVARIANTS.md;
engineer confirms, corrects, or augments each part.
For domain invariants: engineer states the failure mode from memory; CD challenges.

| INV-ID | Category | Authorship | Violation (confirmed/corrected) | Detection (confirmed/corrected) | Blast Radius (confirmed/corrected) | Ownership result |
|---|---|---|---|---|---|---|
| INV-01 | Structural / Data / Domain | CD-drafted / Engineer | | | | PASS / GATE FAIL |
| INV-02 | | | | | | |

**Gate failure record:**
*(List any invariants that fail the ownership test and must return to Phase 2
before Phase 5 opens. If none, write "None — all invariants passed.")*

---

## Section F — UI Surface Review

**When to fill:** During Phase 4 Step 1c. Present only when APPLICATION_SURFACE
contains UI (UI+API or UI_ONLY). For API_ONLY or BACKGROUND_SERVICE projects,
write `N/A — not a UI project` and skip the table.

CD loads UI_SURFACE.md and EXECUTION_PLAN.md and runs four checks; engineer
records findings, severity, recommendation, and disposition.

| Check | Finding | Severity | Recommendation | Disposition |
|---|---|---|---|---|
| Screen coverage — every UI_SURFACE.md screen has at least one EXECUTION_PLAN.md task | | BLOCKER / WARNING / INFO | | RESOLVE / ACCEPT |
| Role-conditional testability — every conditional action has a named invariant or UI test path | | BLOCKER / WARNING / INFO | | RESOLVE / ACCEPT |
| Global elements coverage — Navigation, Logout, Session expiry, Global error boundary all have tasks | | BLOCKER / WARNING / INFO | | RESOLVE / ACCEPT |
| Auth architecture consistency — UI_SURFACE.md Authentication Shell matches ARCHITECTURE.md auth approach | | BLOCKER / WARNING / INFO | | RESOLVE / ACCEPT |

**Step 1c verdict:** PASS — no blockers / CONDITIONAL — warnings noted / BLOCKED — blockers present

*(BLOCKERS must be resolved before Phase 5 opens.)*

---

## Engineer Sign-Off

**Step 1 gate:** PASS / FAIL
**Step 1c UI Surface Review:** PASS / CONDITIONAL / BLOCKED / N-A (if BLOCKED — resolve blockers before Phase 5)
**All RESOLVE findings addressed:** YES / NO
**Verdict confirmed:** APPROVE / CONDITIONAL APPROVE
**Step 2 ownership confirmation:** COMPLETE
**Step 2b invariant failure mode review:** PASS / GATE FAIL (if GATE FAIL — return to Phase 2 before Phase 5)
**Signed:** [name] — [date]
```

---

## Template 9 — HARNESS.sh

**When to generate:** At Phase 8 Part 1 sign-off (greenfield) after REGRESSION_SUITE.sh is assembled.
For enhancements: Sprint Lead assembles at sprint close-out from HARNESS-CANDIDATE commands
across all sprint ENH items — same step as REGRESSION_SUITE.sh update.
**Path:** `verification/HARNESS.sh`
**Leave blank:** Assertion sections — populated from HARNESS-CANDIDATE tasks in EXECUTION_PLAN.md.
**Trigger phrase:** "Assemble harness" in CC.

```bash
#!/usr/bin/env bash
# HARNESS.sh — Live Invariant Assertion Harness
# Assembled at Phase 8 (greenfield) or sprint close-out (enhancement).
# Run before each sprint and after sprint close-out.
# Trigger: "Run harness check" in CC
#
# Output format (machine-readable):
#   [PASS|FAIL] | INV-NNN | CRITICAL|WARNING | [command] | [output on failure]
#
# Exit codes: 0 = all pass, 1 = warnings only, 2 = critical failures

set -uo pipefail
PASS=0
FAIL=0
CRITICAL_FAIL=0
WARNING_FAIL=0

run_assertion() {
  local inv_id="$1"
  local severity="$2"
  local command="$3"

  if eval "$command" > /tmp/harness_out 2>&1; then
    echo "PASS | $inv_id | $severity | $command"
    PASS=$((PASS + 1))
  else
    local output
    output=$(cat /tmp/harness_out)
    echo "FAIL | $inv_id | $severity | $command | $output"
    FAIL=$((FAIL + 1))
    if [ "$severity" = "CRITICAL" ]; then
      CRITICAL_FAIL=$((CRITICAL_FAIL + 1))
    else
      WARNING_FAIL=$((WARNING_FAIL + 1))
    fi
  fi
}

# =============================================================================
# INV-NNN — [Full invariant statement from INVARIANTS.md]
# Severity:         CRITICAL | WARNING
# Expected outcome: [what a passing assertion produces]
# =============================================================================
# run_assertion "INV-NNN" "CRITICAL" \
#   "[exact portable assertion command — runnable from repo root against running system]"

# [One block per HARNESS-CANDIDATE invariant. Do not include invariants without
#  a HARNESS-CANDIDATE command — those are REGRESSION-RELEVANT only.]

# =============================================================================
# HARNESS SUMMARY
# =============================================================================
TOTAL=$((PASS + FAIL))
echo ""
echo "HARNESS SUMMARY"
echo "Total: $TOTAL  Passed: $PASS  Failed: $FAIL  (CRITICAL: $CRITICAL_FAIL  WARNING: $WARNING_FAIL)"

if [ "$CRITICAL_FAIL" -gt 0 ]; then
  exit 2
elif [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
```

---

## Template 10 — DRIFT-NNN_BRIEF.md

**When to generate:** Automatically by CC during Sprint CC Initiation, one brief per
HARNESS.sh failure. CC populates all fields from HARNESS.sh output, INVARIANTS.md,
and BCE artifacts. Sprint Lead reviews, amends if needed, and signs off.
**Path:** `enhancements/backlog/INVARIANT-DRIFT-NNN/DRIFT-NNN_BRIEF.md`
**Leave blank:** Sprint disposition and Sprint Lead sign-off until acknowledgement gate.

```markdown
# DRIFT-NNN_BRIEF.md — [Invariant ID] Drift

**DRIFT ID:** DRIFT-NNN
**Invariant ID:** INV-NNN
**Detected:** [date]
**Sprint detected in:** SPRINT-NNN
**Status:** [ ] Pending Acknowledgement | [ ] SPRINT-MANDATORY | [ ] DEFERRED | [ ] DISMISSED

---

## Invariant Statement

[CC populates from INVARIANTS.md — full condition text as authored by the engineer]

---

## Harness Failure

**Severity:** CRITICAL | WARNING
**Assertion command:** [CC populates — exact command from HARNESS.sh that failed]
**Expected outcome:** [CC populates — expected outcome from HARNESS.sh]
**Actual output:**
[CC populates — verbatim HARNESS.sh output for this assertion]

---

## System Impact Analysis

**Proposed fix:**
[CC populates — what needs to change to restore the invariant, based on codebase
analysis and invariant statement. Sprint Lead amends if incorrect or incomplete.]

**Affected modules:**
[CC populates from BCE artifacts — TOPOLOGY.md and MODULE_CONTRACTS.md entries
for all components the invariant touches.]

**Consequences if unaddressed:**
[CC populates from INVARIANTS.md rationale and RISK_REGISTER.md — what degrades,
breaks, or becomes unreliable if this drift persists. Sprint Lead amends if
operational or business context is missing from the artifacts.]

---

## Sprint Disposition

[ ] SPRINT-MANDATORY — addressed before any ENH work in this sprint
    CRITICAL items are SPRINT-MANDATORY by default.

[ ] DEFERRED — target sprint: SPRINT-NNN
    Rationale: [Sprint Lead — why this can wait. Mandatory field.]
    Valid only for WARNING severity. CRITICAL requires explicit override below.

[ ] DISMISSED — assertion is stale; harness update task created
    Reason: [Sprint Lead — what changed that made this assertion outdated]
    Sprint task created: [description recorded in SPRINT-NNN_LOG.md]

**CRITICAL override (complete only if CRITICAL is being DEFERRED):**
Override rationale: [Sprint Lead — mandatory. Absence means the item cannot be deferred.]
Sprint Lead: [name] — [date]

---

## Sprint Lead Sign-Off

[ ] Harness failure output reviewed
[ ] System impact assessment reviewed — amended where operational context was missing
[ ] Disposition decision recorded
[ ] If SPRINT-MANDATORY: brief submitted for inclusion in sprint manifest analysis

**Signed:** [Sprint Lead name]
**Date:** [date]
```

---

## Template 11 — ONBOARDING_LOG.md

**When to generate:** During PBVI-009 brownfield onboarding. CD creates and appends to this file at each step gate; engineer signs off each section. Frozen when Section 5 is signed.
**Path:** `discovery/ONBOARDING_LOG.md`
**Leave blank:** Completion timestamps and sign-off fields until each gate is reached.

```markdown
# ONBOARDING_LOG.md
# Brownfield Onboarding Attestation Record

**System:** [system name]
**Onboarding ID:** PBVI-009
**Started:** [datetime]
**Completed:** [datetime]
**Engineer of record:** [name]

---

## Section 1 — BCE Completeness Check

**Verdict:** READY | READY-WITH-CAVEATS | BLOCKED-PENDING-BCE | BLOCKED-PENDING-SESSION-F | BLOCKED-PENDING-GRAPH-CONSTRUCTION

| Check | Status | Notes |
|---|---|---|
| Six living BCE-C artifacts present | PASS / FAIL | |
| INTAKE_SUMMARY Stage 3 sign-off | PASS / FAIL | |
| SYSTEM_GRAPH.json present | PASS / FAIL / REMEDIATED | |
| DOMAIN_MODEL.json present or absent-by-design | PASS / DEFERRED / REMEDIATED | |
| ID_REGISTRY.md present | PASS / FAIL | |
| ANNOTATION_CHECKLIST.md P1 items reviewed | PASS / WARN | |
| BCE-S signal artifacts (if applicable) | PASS / WARN / N-A | |
| BCE artifact freshness (≤3 months) | PASS / WARN | |

**Caveats and deferrals recorded:**
[list of items proceeding with caveats, including DOMAIN_MODEL.json deferrals]

**Engineer sign-off:** [name], [datetime]

---

## Section 2 — ARCHITECTURE.md Interpretation

**Source artifacts read:** [list]
**Output:** docs/ARCHITECTURE.md v1.0
**Length:** [N pages — confirm 1–3 page interpretive target met]

### Divergence Log — Interpretive Corrections

| ID | Inferred statement | Engineer correction | Resolution |
|---|---|---|---|
| ARCH-DIV-001 | | | |
| ARCH-DIV-002 | | | |

[Note: factual additions belong in BCE artifacts, not here. Entries here
target interpretive disagreements only.]

**Engineer sign-off on ARCHITECTURE.md:** [name], [datetime]

---

## Section 3 — INVARIANTS.md Derivation

**Source artifacts read:** [list]
**Output:** docs/INVARIANTS.md v1.0

### Adjudication Record

| Candidate ID | Statement | Source | Proposed Scope | Decision | Final Scope | Notes |
|---|---|---|---|---|---|---|
| ICAND-001 | | CATALOGUE / ARCHITECTURE / BUSINESS / INTERSECTION | GLOBAL / TASK-SCOPED | ACCEPT / ACCEPT-MOD / RECLASSIFY / REJECT / DEFER | | |

### Five-GLOBAL Ceiling Check

GLOBAL invariants in final INVARIANTS.md: [count]
[Confirm ≤ 5; if not, ceiling violation — re-do.]

### Deferred Invariants

| Candidate ID | Statement | Reason for deferral | Re-evaluation trigger |
|---|---|---|---|

**Engineer sign-off on INVARIANTS.md:** [name], [datetime]

---

## Section 4 — Claude.md Generation

**Inputs:** ARCHITECTURE.md v1.0 + INVARIANTS.md v1.0
**Output:** Claude.md v1.0 (frozen)

**Verification:**
- All GLOBAL invariants from INVARIANTS.md present in Section 2: PASS / FAIL
- CQ-001 complexity invariant present: PASS / FAIL
- METHODOLOGY_VERSION recorded: PASS / FAIL

**Engineer sign-off on Claude.md:** [name], [datetime]

---

## Section 5 — Sprint-Ready Close-Out

**PROJECT_MANIFEST.md initialised:** [datetime]
**enhancements/REGISTRY.md initialised:** [datetime]
**Standard repository structure verified:** [datetime]

**System status:** SPRINT-READY
**Next action:** First enhancement brief enters enhancements/backlog/

**Final engineer sign-off:** [name], [datetime]

---

## Append-only after onboarding

This file is FROZEN once Section 5 is signed. Subsequent changes to ARCHITECTURE.md,
INVARIANTS.md, or Claude.md are governed by the sprint path (Claude.md amendment
prompt, BCE refresh procedure). They do NOT modify this file.
```

---

## Template 12 — UI Surface (docs/UI_SURFACE.md)

**When to generate:** Phase 1 Decide — UI Discovery session (PBVI-011). CD drafts the
artifact from ARCHITECTURE.md and the requirements brief; engineer corrects and signs off.
**Path:** `docs/UI_SURFACE.md`
**Applies to:** All projects where APPLICATION_SURFACE contains UI (UI+API or UI_ONLY).
**Dual registration:** Register in PROJECT_MANIFEST.md under both Planning Artifacts
(Phase 1 origin) and Discovery Artifacts (BCE Stage 2/3 reference).
**Amendment discipline:** Lightweight — date, screen/section, change, reason. No
challenge session required. Engineer amends manually as part of enhancement scoping.
**Leave blank:** None at template creation — the artifact is produced fully, with
TBD markers for any field CD could not infer.

```markdown
# UI_SURFACE.md — [PROJECT_NAME]
## Version: v1.0 · [date]

## Amendment Log
| Date | Screen/Section | Change | Reason |
|---|---|---|---|
| [date] | — | Initial draft | Phase 1 UI Discovery |

---

## Global Elements

### Navigation
- Type: [Sidebar | Top nav | Both | None]
- Present on: [All authenticated screens | All screens | Named screens only: list]
- Items: [list — inferred from screen inventory]
- Role-conditional items: [item → hidden for role X | NONE]

### Authentication Shell
- Logout: [location — e.g. nav item / avatar dropdown / dedicated button]
- Session expiry behaviour: [redirect to /login | modal prompt with countdown | silent refresh]
- Post-login redirect: [screen name and route]
- Post-logout redirect: [screen name and route]

### Back Navigation
- Mechanism: [browser back | explicit Back button | breadcrumb | combination]
- Screens with explicit back controls: [list with target screen for each]

### Breadcrumbs
- Present: [Y | N]
- Screens: [list — if present]
- Depth: [maximum levels shown]

### Global Error Boundary
- Behaviour: [full-page error screen | inline banner | toast notification]
- User action available: [Retry | Reload | Contact support | None]

### App-level Loading
- Behaviour: [splash screen with logo | skeleton layout | full-page spinner]
- Applies to: [initial app load only | every route transition | both]

### Toast / Notification System
- Present: [Y | N]
- Position: [top-right | bottom-center | other]
- Used for: [success confirmations | error alerts | both | other]

---

## Screen Inventory

| Screen | Type | Route | Journey | Roles | Auth Required |
|---|---|---|---|---|---|
| [Screen Name] | [List\|Detail\|Form\|Dashboard\|Modal\|Wizard] | [/path or TBD] | [journey name] | [All\|role list] | [Y\|N] |

---

## Screen Specifications

[One section per screen — generated from the inventory above]

## [Screen Name]
**Type:** [List | Detail | Form | Dashboard | Modal | Wizard]
**Route:** [path or TBD]
**Journey:** [journey name]
**Roles:** [All authenticated | comma-separated role list]
**Trigger:** [what navigates to or opens this screen — screen name + action, or "Direct navigation"]
**Auth required:** [Y | N]

### Data Displayed

| Section | Entity / Field | Source | Notes |
|---|---|---|---|
| [Main / Related / Panel name] | [Entity.field or entity[]] | [table / API endpoint / computed] | [format, units, or derivation note] |

### Actions

| Label | Scope | Trigger | Condition | Outcome |
|---|---|---|---|---|
| [Button/link label] | [Row\|Bulk\|Screen\|Global] | [Button\|Link\|Icon\|Form submit] | [Always\|condition expression or NONE] | [Navigation to X \| API call → result \| State change] |

### States

| State | Trigger | What Renders |
|---|---|---|
| Empty (no data) | No records exist | [description] |
| Empty (filtered) | Filter returns zero results | [description — distinct from above if applicable] |
| Loading | Data fetch in progress | [skeleton layout / spinner / specific description] |
| Error | API failure or network error | [error message surface, retry available Y/N] |
| Populated | Data loaded successfully | [normal operating state — brief description] |
| [Role variant] | User is [role X] | [what differs — hidden actions, read-only fields, etc.] |
| [Record-state variant] | Record status = [X] | [what differs — conditional actions, status badge, etc.] |

### Async Behaviour
- Pattern: [Load-once | Polling (interval: Xs) | WebSocket | Real-time | N/A]
- Scope: [Whole screen | Named panel only]

---
[List screens only — omit section if type ≠ List]

### List Configuration
| Column | Field | Sortable | Filterable | Default Sort |
|---|---|---|---|---|
| [Display name] | [Entity.field] | [Y\|N] | [Y\|N] | [ASC\|DESC\|N/A] |

- Pagination: [Paginated — page size N | Infinite scroll | None]
- Search: [Y — fields: list | N]
- Bulk selection: [Y | N]

---
[Form screens only — omit section if type ≠ Form]

### Form Fields
| Field | Type | Required | Conditional On | Validation Message |
|---|---|---|---|---|
| [Label] | [Text\|Textarea\|Number\|Email\|Password\|Date\|Dropdown\|Multi-select\|Checkbox\|Radio\|File] | [Y\|N] | [Field = value, or NONE] | [User-facing message on invalid input] |

- Save behaviour: [Stay on page | Navigate to [screen] | Show confirmation modal [modal name]]
- Cancel behaviour: [Navigate to [screen] | Discard with confirmation prompt]

---
[Dashboard screens only — omit section if type ≠ Dashboard]

### Panels
| Panel Name | Data Source | Empty State | Refresh | Drill-down Target |
|---|---|---|---|---|
| [Name] | [Entity / API endpoint] | [description] | [Load-once\|Polling Xs\|Manual] | [Screen name or NONE] |

---
[Modal screens only — omit section if type ≠ Modal]

### Modal Configuration
- Opens from: [Screen name — action label]
- Type: [Confirmation | Mini-form | Detail preview | Info]
- Confirm action: [what happens on confirm — API call, navigation, state change]
- Cancel action: [dismiss only | discard with prompt]
- Parent screen behaviour on close: [Refresh | No change | Navigate away]
```

---

## Template 13 — Seed Data (docs/SEED_DATA.md)

**When to generate:** Phase 1 Decide — UI Discovery session, after UI_SURFACE.md is
confirmed. Conditional on data baseline = Seeded (declared in the Phase 1 Interrogate
Application Profile). For Migrated or User-generated baselines, this artifact is not
produced.
**Path:** `docs/SEED_DATA.md`
**Applies to:** Projects where APPLICATION_SURFACE contains UI AND data baseline = Seeded.
**Drives:** The Session 1 seed script task (Phase 3) and Playwright test strategy
(tests run against seed state rather than driving creation through the UI).
**Leave blank:** None at template creation — CD produces the artifact fully and marks
TBD for any entity where representative values cannot be inferred.

```markdown
# SEED_DATA.md — [PROJECT_NAME]
## Version: v1.0 · [date]

## Data Baseline Declaration
Data baseline: Seeded
Rationale: [one line — why seed data is required for this project]

## Seed Entities

### [Entity Name]
Purpose: [why this entity needs seed records — what UI state it enables]
Minimum records: [N]
Record count rationale: [what UI states require this many records — e.g. "3 records to show pagination"]

| Field | Seed Value(s) | Notes |
|---|---|---|
| [field name] | [value or value list] | [format note or constraint] |

Representative records:
\```json
[
  { "field": "value", ... },
  { "field": "value", ... }
]
\```

[Repeat for each first-class entity in the data model]

## Seed Coverage Matrix

| Screen | Required State | Entity | Records Needed | Covered By |
|---|---|---|---|---|
| [Screen name] | [e.g. "populated list", "conditional action visible"] | [Entity] | [N] | [seed record ref] |

## Seed Script
- Path: `scripts/seed.[ts|sql|js]` (generated by CC — Session 1 task)
- Runner: [npm run seed | psql < seed.sql | other]
- Idempotent: Y — safe to run multiple times without duplication
```