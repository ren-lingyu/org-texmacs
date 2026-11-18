# STM fragment architecture revision after Node 1

This adopted decision partially supersedes the original v0.8.0 interface
freeze. stm-fragment-core-plan.md owns execution and acceptance. Node 1 was
delivered under that earlier plan. This revision restores the v0.6.0 model
boundary by clarifying project intent after delivery, with no change to the
results of Node 1 or E0–E7. The decision is distilled here for recovery; the
conversation has no separate original-byte evidence requirement.

The Org-TeXmacs AST is the complete mathematical document. It is one logical
tree implemented by the existing model: a native Org AST for document
structure and Org semantics, an identity-keyed mapping to parsed STM trees,
and explicit syntax/source context. AST-first means inspecting, copying,
transforming and consuming that Model directly. It does not prescribe the
shape of temporary source recognition data or require a third canonical AST.
The proposed public Extended Org AST roundtrip added an extra document
representation and conversion lifecycle without an independent consumer
requirement. General AST transformations are Model → Model.

Keep each non-block island at its nonrecursive stm-fragment object. The object
already carries Org position, parentage and post-blank and can participate in
secondary and caption structure. Parsed trees are the sole mathematical
authority; every recognized island in a complete Model has a parsed tree.
Recognition can temporarily attach STM text. Ownership must strip :stm-source
and :value from the copied model object and preserve necessary Org structure.
Native blocks retain their existing Org node keys and semantics. Node identity,
rather than carrier spelling, connects position to contents. String keys,
including direct constructor inputs, are intentionally retired with no legacy
mode or placeholder characters. Ordinary Org text strings remain valid.

E4's string anchor demonstrated reuse of existing ownership and identity
remapping. Its U+FFFC representation is superseded. E6 showed that whitespace
hidden in an opaque anchor can disappear during lowering. The prototype's
separate text node was a repair for that representation. Review object
:post-blank and existing post-blanks support before choosing a lowering
mechanism. A count alone does not preserve the distinction between tabs and
spaces if exact source whitespace is required.

Atomic STM string roots have no support guarantee and no special prohibition.
Add no dedicated acceptance or rejection path, test contract, or required
diagnostic for them. E4/E5 outcomes remain historical observations. Ordinary
string leaves of compound STM remain supported under the existing tree
semantics and encoding rules. Model validity and consumer expressibility are
separate concerns.

Node 1 delivered scoped recognition, registration, interpreter, state
protection and syntax capture, including the public org-texmacs-ast-parse-buffer
with its temporary unparsed recognition result. Reuse those mechanisms. Audit
callers, README and tests before deciding whether to internalize, rename or
replace that entry or adjust its public role, and review how the source-phase
:value is used. No replacement name is frozen. The planned public ast-to-model,
model-to-ast and standalone ast-serialize requirements are superseded. The
existing Model constructor, copy, replacement, inspection and serialization
form the public basis. A private helper or a future projection needs an actual
consumer. Syntax captured at recognition moves to Model context during
construction; public roundtrip propagation is no longer required.

The adopted Org source syntax, native STM parser and block semantics, standard
Org preparation and final filtered AST authority, Cite, bare/span retirement,
one-way :fragment-tags input normalization, Org 9.8.10 / Emacs 31.1 minima and
nonblocking OTP scheduling remain in scope as described by the core plan.
E0–E7 preserve evidence under their original terminology and phase boundaries.
