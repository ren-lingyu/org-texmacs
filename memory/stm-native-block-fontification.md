# Native STM block fontification

Extend Org buffer Scheme presentation to all native STM body kinds using
the existing body classifier and Org element bounds. Keep Org presentation
on delimiters and affiliation. Treat the whole body as opaque even when
Org's local lookup starts inside markup-shaped text in the body. Structural
blocks and paragraph recognition keep their existing rules.

Reuse Org Src fontification and existing ownership/invalidation. Preserve
source and editor state, including when an edited delimiter invalidates the
old body context. Headline, caption and table cell fontification are
separate work.

When Org's local element lookup finds a nested special block formed by
markup-shaped text inside an STM string, select the outermost native body
ancestor. This makes a fontification request from the interior use the same
opaque range as one starting at the block opener.

Offline Nix validation with locked Emacs 31.1 and Org 9.8.10 passed Core ERT
355/355, package byte compilation, package-lint and treefmt. The regressions
cover the three delimiters, quoted and compound bodies, empty bodies, list
and quote containers, preservation of Org metadata faces, local deletion
and restoration of both delimiters, removal of stale Scheme syntax and
ownership, mode and narrowing boundaries, and preservation of source and
editor state. Native, PDF and example builds were outside this check.

Status: delivered in the project snapshot associated with this checkpoint.
