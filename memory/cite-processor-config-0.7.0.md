# v0.7.0 explicit Cite configuration: accepted candidate

## Contract and scope

User adopts one independent change against delivered N9 at22191a0. Seven paths,
all167canonical hashes, parent/message/check outputs in accompanying -inputs.json.
No exact project parent for this uncommitted runtime candidate. Human delivery
then separate freeze decision; root TODO, no version/CLOSED/tag/release mutation.

Defcustom org-texmacs-cite-export-processor is export-only, defaults texmacs-native,
nil delegates unchanged to standard Org Cite (not disable). Existing helper returns
original global alist if preference nil or explicit texmacs entry exists; otherwise
prepends a fresh (texmacs PREFERRED) entry, retaining original tail identity. No
special case for global nil or factory value. Org handles more-specific derived
entries and normal file/subtree/EXT-PLIST/options-filter precedence. Read during
standard backend options evaluation, not frozen at registration. No alias, global
mutation, new dispatch/advice or manual processor call. Unknown or non-export
processors fail through standard Org Cite.

README adds native/nil example and precedence, root updates only completed default
item, detailed notes replace old stock-value/intent inference. Native styles,
CSL/raw/math/ALT_TITLE limits retained. Processor callbacks/registration, native
reference/bibliography semantics, input/model/ownership and PDF tests unchanged.
No new AST/math/style/field/Unicode scope or new changelog version.

## Verification and fixture boundaries

Existing default helper binds preference per case and protects original alist
identity/content. Eight required combinations tested. Five new core ERT cover
matrix, original structure, derived specificity with/without explicit base entry,
standard unregistered/non-export errors, preload nil/basic and runtime repeated
nil/native/basic exports. Existing declarations/options/subtree/basic/raw tests
expanded or retained; nested HTML plus delegated inner TeXmacs restores outer
preference. Actual CSL test covers preference nil/generic CSL and native preference
with explicit backend CSL. Seven controlled protocol fixtures now explicitly
bind preference nil rather than relying on a generic fallback to override it;
all original assertions retained.

Core-only selection matrix uses public Org environment/options and processor-store
APIs, with normal INFO :back-end, without invoking optional CSL finalizers. Actual
exports/finalizers stay in CSL suite with citeproc. Initial failed gates showed
controlled fixtures needing explicit delegation, missing optional citeproc from
an overly broad selection fixture, and missing backend INFO in its first revision.
These were test harness/scope corrections, not production fallback changes or
waived assertions. Corrected focused323core/11CSL passes, then final core reruns
expanded derived case as part of full acceptance.

Final command, explicitly authorized once600s:
`timeout 600s nix flake check --no-write-lock-file --print-build-logs path:./tmp/cite-config-final`
Exit0/all12named checks.699defaultERT (323core/282native/11CSL/48document/29render/
6caption) +actualOrganize5 =704, zero unexpected. Strict byte/native compile,
package-lint/treefmt/aggregates pass. Locked x86_64-linux Emacs31.1/Org9.8.10/
TeXmacs2.1.5; no minimum-Org/other-platform claim. Isolated flake only adds the
existing pinned actual integration check/format; production flake unchanged.
No repeat manual native mathematical experiments; existing processing contract
and native visual evidence unchanged. Detailed exact output/derivation identities
are in receipt. No new raw archive needed after semantic extraction and maintained
regression/source-history evidence; do not retain whole temporary build trees.

## Delivery gate

Complete7path diff/whitespace reviewed and167canonical hashes match accepted final
snapshot. tmp/commit.md describes explicitly authorized complete worktree candidate,
not staged changes; ordinary index untouched. One coupled feature commit,
split unnecessary/low difficulty: one configuration interface with matching tests/
docs. Next human commit, verify exact receipt, then separate human freeze. No
remaining implementation under this cleanup; no new release action or issue
closure named. Single600s authorization consumed.
