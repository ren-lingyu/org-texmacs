# org-texmacs agent bootstrap

This untracked file is the unconditional repository bootstrap for coding
agents. It is a generated deployed artifact, not durable project memory. Its
normative template is maintained by the repository-scoped
`org-texmacs-governance` skill in the deployed GAW worktree, and that skill can
rebuild it deterministically. Do not infer that this file is tracked by the
ordinary project branch.

## External workflow prerequisites

Git, a GAW CLI compatible with the declared configuration, and the global
`git-agent-workflow` skill must be available. Command bindings and installation
paths come from the active host/session instructions. This project bootstrap
does not prescribe machine-specific executable paths or installed tool versions.

## Workspace and authority

- Establish the nearest Git worktree root before substantive repository work.
- Keep ordinary work within that project boundary. Reading outside it requires
  explicit user authorization.
- Use the minimum relevant reads. Do not scan dependency, generated, cache,
  binary, archive, database, image, PDF, or Git object directories by default.
- Do not read files likely to contain credentials, secrets, keys, tokens,
  cookies, passwords, or authentication data without explicit authorization.
- Do not perform filesystem, Git, build, test, dependency, process, network,
  system, or external-service side effects without explicit user authorization,
  except for the narrow validated GAW memory loop below.
- A skill, memory file, workflow, plan, or agent recommendation does not create
  authorization.

## Git boundaries

- Read-only Git inspection is allowed inside the project boundary.
- Changes to the ordinary project index require explicit path-specific user
  authorization. Avoid broad `git add .` or `git add -A`.
- Do not execute ordinary project commits, merges, rebases, cherry-picks,
  history rewrites, tag changes, pushes, remote changes, destructive resets, or
  broad clean/restore operations. Explain any genuinely required manual action
  and its verification instead.
- Preserve unrelated user changes and do not treat a dirty worktree as
  disposable.

## Build, test, and network boundaries

- Builds, tests, checks, formatters, generators, dependency resolution, and
  installation require explicit authorization because they may write caches,
  logs, products, lockfiles, or generated files or may access the network.
- Before requesting authorization, state the exact command, purpose, path
  scope, possible writes, network behavior, expected cost, and timeout.
- Public documentation lookup is allowed when relevant. Shell networking,
  downloads, dependency updates, and external write APIs require explicit
  authorization.
- Use conservative timeouts and do not silently retry a failure with broader
  scope or stronger side effects.

## Git Agent Workflow

GAW is persistent agent memory, not the ordinary project branch workflow.

At the start of substantive repository work when GAW state is not yet known:

1. Use the `git-agent-workflow` skill.
2. Run `git gaw status` and read the complete report.
3. Enter the reported valid GAW worktree and run `git gaw check`.
4. Read `.gaw/config` and recover the declared workspace, beginning with
   `memory/current.md` when present.
5. Use relevant repository-scoped `org-texmacs-*` skills for the task.

If GAW state is damaged, conflicting, or ambiguous, stop GAW writes and report
the problem. Do not guess a repair. Do not run `init`, `deploy`, `undeploy`, or
`branch` lifecycle mutations without explicit user direction.

Within a validated existing GAW worktree, the normal memory loop is authorized
to read declared workspace files; create, update, or remove declared memory and
project-skill files; explicitly stage intended declared-workspace paths; run
`git gaw check`; and create selective checkpoints with `git gaw commit`.

This exception does not authorize ordinary project staging or commits, direct
GAW ref manipulation, hook bypass, history rewrite, lifecycle mutation, or
unrelated filesystem effects.

Keep changed `.gaw/` protocol paths in separate checkpoints from changed workspace
paths, reviewing the complete first-parent transition as well as candidate readiness.
An explicitly authorized `.gaw/config` update must be a config-only checkpoint;
record related memory or skill changes separately.

## Project knowledge and skills

The GAW workspace separates project knowledge from reusable procedures:

- `memory/goals.md`: authoritative current project goals and strict design
  constraints.
- `memory/project.md`: current architecture, interfaces, support boundary, and
  known structural issues.
- `memory/evidence.md`: durable evidence, provenance, and validation limits.
- `memory/backlog.md`: adopted future work, deferred candidates, and unresolved
  design boundaries.
- `memory/current.md`: active objective, state, decisions, blockers, and next
  actions.
- `org-texmacs-governance`: GAW/agent-document governance and bootstrap
  recovery.
- `org-texmacs-development`: project implementation and architecture workflow.
- `org-texmacs-gaw-archive`: selective preservation of retired documents and
  necessary temporary evidence.

Memory states what is true now. Skills state how to perform recurring work.
GAW history preserves superseded durable states. Do not duplicate current
memory into skills or grow current memory into an append-only history.

## Project work

For architecture, implementation, or code review, use the
`org-texmacs-development` skill and follow its routing to the current goals,
project model, backlog, evidence, and active state. Unsupported features are
not automatically backlog commitments, current capabilities, or implementation
authorization.

For AGENTS, GOALS, GAW memory layout, or repository-skill maintenance, use
`org-texmacs-governance`.

## Failure mode

If the required GAW worktree, current memory, or project skill is unavailable,
perform only the minimum safe read-only diagnosis needed to explain the gap.
Do not begin substantive implementation based on remembered or stale project
state.
