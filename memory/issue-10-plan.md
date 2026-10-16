# Issue10 inline footnote STM guidance review

User selected #10 after verified local Issue11 delivery and supplied implementation
guidance. Current action is read-only code review and proposed plan, not business
implementation or build authorization. Existing user flake mirror remains dirty;
ordinary index empty. Local reviewed source is the committed Issue11 delivery.

Goal: anonymous/named inline footnote fragments through same configured discovery,
owned preparation and native lowering; AST-first/opaque STM/source ownership and
provenance. No public config/protocol/STM parser/general secondary-object support.
Prior locked investigation reproduced zero inline-note islands/literal STM versus
one separate-note island/native math; see release-0.5.0-investigation.md and its
existing archive. No new runtime evidence in this review.

Static findings: fragment scanner scans paragraph bounds but admits candidates
only when org-element-context is paragraph; footnote-reference contents excluded.
Document preparation splits direct paragraph strings only and whitespace() just
recurses inline objects. Pure inline island handler admits paragraph only.
Named recovery synthesizes coordinate-less paragraph from inline definition
contents; current preparation intentionally does not split these paragraphs.
Scoped preparation collects spans by paragraph coordinates after dependency
recovery, so changing admission alone cannot repair missing restored coordinates.
Existing named first-use/repeated/forward resolution and reachability request
filtering should be reused, not replaced. Existing ERT footnote-stm-exclusion must
be migrated to positive support, with literal-object exclusion tested separately.

Proposed nodes:
1. Isolated locked-flake red tests/probes of actual Org anonymous/named body bounds,
   adjacent markup/literal/link exclusions, square brackets/newlines/truncation,
   restored hidden definitions and scope filters. Scanner no worker, pure lowering
   no buffer/worker; retain source-state checks.
2. Bounded discovery inside Org-recognized inline footnote direct plain text;
   reuse equal-length masking and boundary scanning. Public map/at-point and
   document preparation must agree on spans/source order. Never widen across
   footnote delimiter or child object, and don't repair Org grammar via masking.
3. Shared string splitting/registration over paragraph and inline-note bodies,
   retaining original coordinates/identities and deterministic scoped request
   order. For restored named definitions, preserve source-body bounds or use
   prepared owned leaves; choose minimal route after red scoped probes. Modify
   context.el only if this recovery truly needs it. No live-source fallback,
   reparsing STM, duplicated requests or reused consumed island.
4. Admit footnote inline islands and compose provenance through existing native
   footnote/label/repeated-reference structure. Keep numbering/resolution policy.
5. Maintained positive/negative/discovery/ownership/scope tests, native .tm/readback/
   PDF math semantics and separate-definition/Issue11 regression; README/docstrings
   updated together. Run focused/full/real-extension/strictcompile/lint via flake
   only after separate command authorization. No system Emacs or lock update.

Two proposed contract clarifications need agreement before implementation:
- Existing public paragraph scanner stops recognition on unbalanced/unsupported
  candidate; don't silently change that global contract. In newly supported
  Org-recognized inline-note plain text, configured-root candidate which cannot
  finish within valid body/object bounds should explicitly fail, consistently
  across public discovery and document export. Unconfigured/noncandidate text
  remains Org text; if Org does not recognize a footnote, don't invent one.
- Inline note body is currently document(concat(...)), not an ordinary paragraph.
  Recommend shared Issue11 bare-body eligibility: one mapped identity plus only
  ASCII whitespace/no other Org objects promotes complete root within document;
  otherwise known direct display roots reject and ordinary math mixtures keep
  existing concat/whitespace. This also avoids hidden named inline definitions
  behaving differently after recovery into synthetic paragraphs. No automatic
  paragraph splitting or recursive inspection of authored STM. This is a proposed
  clarification, not an already adopted user decision.

No new immutable archive needed: user guidance/static conclusions are distilled
here; code remains in ordinary history and prior runtime evidence already retained.
Next: user reviews plan/clarifications, then implementation selection and separately
scoped flake test authorization. Fonts postponed; PDF links follow #10.
