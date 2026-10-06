# org-texmacs persistent memory

## Current state

This state records the post-v0.3.0 project and the decision to migrate durable
agent-facing project knowledge into the GAW branch. It is a current governance
and planning state, not a claim that the migration has already been completed.

## Project baseline

- Local v0.3.0 tag target:
  `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- Current main HEAD observed on 2026-10-06:
  `1a90b7bd2e0f60601cdf6003edf1ccbc79afce18`.
- The two post-release commits adjust README heading style and allow the docs
  directory; they do not introduce a new functional release milestone.
- The ordinary project worktree was clean when this GAW reconstruction began.

## Current product contract

v0.3.0 provides the explicit-source/prepared-input document pipeline, the
documented finite Org semantic subset, body/style/initial/provenance results,
and one persistent native TeXmacs document session. It does not provide general
serialization, PDF/export, preview, multi-session, or complete Org semantics.

## Adopted post-release review decision

The worker-to-document dependency remains an architecture smell, not a known
correctness defect. A behavior-preserving post-release refactor is appropriate:

- document representation validation, wire construction, provenance-aware
  encoding orchestration, and document diagnostics belong on the
  session/native-bridge side;
- worker startup, socket transport, framing, process lifecycle, and protocol
  envelope validation remain in the worker layer;
- public APIs, wire semantics, session failure behavior, and the v0.3 test
  contract must remain stable.

The refactor should precede substantial new consumer expansion, but no code
change has yet been authorized or made for it.

## Adopted GAW migration decisions

- The valid `_agents` branch and its deployed worktree will become the durable
  source for current memory and repository-scoped project skills.
- GAW branch preservation and transfer are already solved and are not an open
  risk for this plan.
- Root `AGENTS.md` remains an untracked, unconditionally loaded bootstrap
  artifact. Its important policy can be made reproducible from a project skill.
- Detailed project goals, current architecture, evidence, progress, and next
  actions belong in memory, not in a skill.
- Skills contain stable reusable procedures, triggers, routing, templates, and
  deterministic helpers. They must not become another append-only project
  history or current-status store.
- Repository skill names use the `org-texmacs-` namespace. More than one
  focused skill may live under `.agents/skills/`.
- Initial skill candidates are `org-texmacs-governance` and
  `org-texmacs-development`. Validation and release skills should be split only
  when repeated workflows justify independent discovery.
- The existing large root AGENTS/GOALS documents remain source evidence until
  migration and a recovery drill are complete; no root-file reduction has yet
  occurred.

## GAW reconstruction status

Retrospective memory now represents:

1. v0.1.0 parsing foundation;
2. v0.2.0 structured body/native session;
3. adoption of AST-first goals and strict interface constraints;
4. v0.2.1 interface hardening;
5. v0.3.0 plan convergence;
6. the node-4 architecture review;
7. the v0.3.0 release.

Historical checkpoints intentionally introduce `goals.md` only after v0.2.0,
when the project goals were actually adopted. Project skills have not been
projected backward into historical states.

## Next action

Normalize the current GAW workspace into focused goals, current project model,
evidence, and handoff memory; then create scoped namespaced repository skills.
After those sources are validated, prepare the reproducible root AGENTS
bootstrap asset. Modifying the actual root AGENTS/GOALS files remains a separate
project-worktree action requiring explicit authorization.
