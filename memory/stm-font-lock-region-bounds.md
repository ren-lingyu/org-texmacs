# STM fontification and JIT Lock bounds

## Reproduced on the pre-fix project state

A Core ERT fixture inserted the ordinary LaTeX fragment `\(  \)` as text
in an Org paragraph and requested JIT fontification for that line. A
buffer-local Font Lock extender reached a point inside a later native STM
block, so the normal native extension hooks completed the affected range.

JIT requested positions 1–21. The wrapper called the native fontifier with
positions 1–23 and had discovered only a paragraph. Native Font Lock
reported `(jit-lock-bounds 1 . 213)`. A previously fontified texmacs body
still had `fontified t` but lost its STM ownership and syntax properties.
The wrapper returned nil. The test reproduces the reported failure
mechanism using the locked setup, without depending on a snippet package.

## Repair

Keep the local extension hooks and let the native fontifier report the
final refresh range. Rediscover STM contexts in that range after Org's
pass, then return the same bounds to JIT Lock. Preserve an input-range
fallback for a native fontifier that does not report bounds.

The first repair exposed a separate locality issue. Emacs treated the
package's contiguous non-nil `font-lock-multiline` properties as one
range, so respecting the native refresh bounds caused the existing local
edit test to re-fontify all 512 fixture paragraphs. Remove the package's
blanket multiline property. Its per-context ownership and change hooks
already extend and invalidate affected STM ranges.

The fixed fixture passed with normal hooks and with the controlled
extension. It checks all three native body kinds and an inline STM
paragraph, as well as the returned bounds and the untouched tail. The
512-paragraph locality regression also passed again. Offline Nix
validation with Emacs 31.1 and Org 9.8.10 passed Core ERT 356/356, package
byte compilation, package-lint and treefmt. The downstream snippet
package and native, PDF and example builds were outside this check.

Status: delivered in the project snapshot associated with this checkpoint.
