# PDF-link investigation diagnostics

Initial source-audit attempt could not access the Nix daemon socket in the
sandbox. Same user-authorized command succeeded with daemon permission. This
was not a failed native PDF test or an automatic approval-review rejection.

First temporary probes.el lacked a closing parenthesis and lexical-binding
cookie; Emacs stopped at end-of-file before matrix execution. Second revision
ran two package exports, then the independent native subprocess returned
PDF-LINK-ERROR/unbound-variable with-buffer because its module was missing.
The script now imports (utils library cursor), as the worker does. Both failed
revisions were rejected as acceptance; initial logs remain temporary only.

Corrected baseline completed all12PDFs; all0annotations. Its source fixture and
settings are retained in probes-baseline.el, outputs in probe-results/annotations.json.
Adding update-forced to only independent native controls restored2annotations
in all8controls while package/reload4remained0. Their output is retained in
forced-native-results/annotations.json. Final candidate worker and corrected
independent .tm reload restored2annotations in all12cases. Poppler also identifies
external URI Annotation and internal .html#page href; pypdf reads resolved
annotation objects, rectangles and destination table. No byte/pixel comparison.

Pypdf warns about duplicate native named-destination dictionary keys in baseline
and forced outputs. This does not prevent pypdf/Poppler inspection or explain
absent annotations: they remain absent in baseline and appear with forced layout.
No cleanup of native dictionaries or unrelated native PDF rewrite was attempted.

The source-audit result extracts selected unmodified text from the locked
TeXmacs2.1.5source archive, not a patched instrumented native executable. Public
master source supplied a hypothesis; its guessed v2.1.5/path URLs failed. The
controlled installed-native execution establishes the sequencing effect.

New maintained regression tests fail against the old worker for the intended
assertions: ExternalLink has no URI, and update-forced failure injection is
never reached. Their baseline harness expects exactly2failures and exits0 only
then. That target's successful build is intentional red-test acceptance, not
a claim that the old implementation passes the new tests.
