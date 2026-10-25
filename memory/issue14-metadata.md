# Issue14 metadata experiments

Issue: https://github.com/ren-lingyu/org-texmacs/issues/14. User authorizes isolated
flake experiments, without a special framework. Font problems explicitly remain
outside project backlog. No production implementation or remote writes selected.

tmp/issue14-metadata-probe contains23tracked source/package/flake/lock inputs.
Root hashes unchanged, copied inputs byte-equal except copied flake replaces
default checks with a diagnostic runCommand. Command: timeout 120s nix flake
check -L --no-write-lock-file
path:/home/lingyu/Projects/org-texmacs/tmp/issue14-metadata-probe.
Network/store/cache/log/products disclosed, root source/lock/index untouched.
Four invocations: first failed because probe disabled author while asserting it;
second disproved probe's assumption that unknown metadata is silently ignored;
third passed52assertions/6PDFs; fourth covered two additional boundaries and
passed72assertions/10PDFs, exit0. Pinned x86_64-linux, Emacs31.1/Org9.8.10/
TeXmacs2.1.5. No complete maintained-suite rerun or .tm disk reload test.

Findings:
- TITLE/AUTHOR/DATE work. Title probe confirms file overrides external, subtree
  overrides file/external. SUBTITLE/DESCRIPTION/KEYWORDS/LANGUAGE file keywords
  explicitly fail Unsupported or unprepared block/keyword; external keys also
  rejected. Existing explicit article style/french initial retained on source
  without LANGUAGE. New-field precedence/conflicts are not implemented/tested.
- packages/header/title-base.ts defines doc-subtitle and abstract-keywords.
  Native session setting/readback, serialization and PDF text in generic/article
  confirm doc-data(doc-subtitle "SubtitleSentinel") works with/without main title.
- Direct document(abstract-keywords "KeywordOneSentinel" "KeywordTwoSentinel")
  renders keywords without Abstract heading in both styles. Wrapping that same
  node in abstract-data adds Abstract even without abstract content. Do not
  fabricate an empty abstract for KEYWORDS. Org keyword splitting semantics and
  a policy for genuine abstract integration remain design work.
- Initial language english/american/british/chinese/taiwanese/zh-CN/
  unknown-sentinel all survive native sessions/serialization. Persistence is not
  validity. progs/kernel/texmacs/tm-modes.scm supported-languages lists english,
  british, chinese, taiwanese; in-american is language=english. Do not pass ISO/
  BCP identifiers straight through or use american as a native language name.
  Full language mapping/case/region/unknown-value policy remains unimplemented.
- Limited header/HTML converter search found no suitable DESCRIPTION target;
  description hits include description lists. Not proof of native absence; do
  not equate description with abstract/doc-note or invent doc-description.

These are baseline/candidate native semantics, not new Org support acceptance.
Next: design all seven field mappings and precedence, including explicit nil,
style/initial conflict and subtree behavior, within existing owned snapshot /
pure lowering. Context allowlists, external validation, INFO ownership and
lowering all matter. Implementation remains unselected. No font policy/fix work.
Distilled shapes/results/native locators suffice; no independent raw/PDF archive
needed. Temporary scripts/report are convenience, not durable dependencies.
