# STM fragment interactive editing

The user selected explicit STM fragments for the next Org editing increment
after the Scheme mode migration. Reuse scoped Org recognition and Org Src
editing. Only the payload is writable, and it must remain one lexically
complete compound datum. Use the existing scanner for that check. Native
STM validity and Org container interpretation remain outside write-back
validation.

Org Src owns the source markers, overlays and editing lifecycle. Check
both save and exit before they can discard the edit buffer or touch source
text. Preserve the original carrier and exact multiline payload whitespace.
Keep the handling scoped to recognized inline fragments and their edit
buffers. The existing special-block editor and ordinary Org editing retain
their own paths.

## Implementation and evidence

Org 9.8.10's local context parser can find fragments in primary and
secondary Org object containers. Local lookup skips raw native block bodies
and requires point to be inside the carrier apart from post-blank. The
source buffer must expose the full carrier. The temporary Org Src datum
sets its contents bounds to the payload, and initialization restores the
literal text after Org's dedenting. The shared Org Src Scheme resolver
selects the mode.

Org Src save clears the modified flag early and creates a write-back
buffer. Exit also creates a write-back buffer before switching buffers.
The fragment guard validates before either command runs, so a lexical
failure leaves the buffer, modified state and source overlay intact.
Cancellation bypasses validation through Org's own write-back flag.
Keep both Org Src's overlay protection and a payload comparison using its
markers, since Lisp can bypass overlay hooks. On a successful save, refresh
the expected payload so the next save or exit can detect conflicts.

The offline Nix checks passed with locked Emacs 31.1 and Org 9.8.10:
Core ERT 353/353, package byte compilation, package-lint and treefmt.
Four new regression groups cover both carriers, the edit lifecycle,
pre-write lexical checks, read-only and narrowed source, conflicting text,
mode initialization failure, native-body opacity, ordinary Org delegation,
and supported primary and secondary contexts without a worker, Babel or
Export. Agent-run validation was limited to the targeted offline checks.
The user separately reported that their tests and builds passed, including
the example build. Their commands and logs were not provided.

Status: delivered in the project snapshot associated with this checkpoint.
Equation and equation* editing remain separate from this delivery.
