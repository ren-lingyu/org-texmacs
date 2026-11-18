# Native STM block editing

Use the existing native-body classifier to select `texmacs`, `equation`
and `equation*` for Org Src editing and Org-side Scheme indentation.
Edit the body range and leave the original delimiters, parameters and
affiliation in the source. STM string roots and empty bodies remain
editable. Model and Export own STM validity.

Check for the current block's closing line before invoking Org Src save
or exit. Org Src save can clear the modified flag and allocate a write-back
buffer before running a callback. Preflighting the closing line preserves
source text and editing state on rejection. The guard uses Org's write-back
flag so cancellation still works. Fragment validation stays distinct.

The parameterized Core ERT fixtures exercise all three native kinds:
case-insensitive delimiters, unchanged affiliation and parameters, compound
and string roots, empty bodies, repeated entry, suspension of writes with
a closing line, cancellation, and Scheme indentation inside valid Org
list and quote containers. The tests also check that raw native bodies do
not open the inline fragment editor and that structural blocks delegate.

Offline Nix validation with locked Emacs 31.1 and Org 9.8.10 passed Core
ERT 353/353, package byte compilation, package-lint and treefmt. The user
separately reported passing tests and builds, including examples. Their
commands and logs were not provided.

Status: delivered in the project snapshot associated with this checkpoint.
