# Historical in-memory BibTeX/native formatter probe

Non-authoritative historical evidence; not current project memory.

- Capture time: 2026-10-06T17:35:50Z.
- Project commit: `a242eb2` (full `a242eb233322a62b3f18dbf1a3ba1278e628e361`).
- Project state: HEAD at capture time. The dependency-foundation implementation and user mirror overlay were uncommitted when archived. The probe originally ran before implementation on this same project HEAD.
- Selection: exactly the three repository-relative synthetic bibliography probe files listed below. Exclude debug worker copies, binaries, caches and the temporary mirror configuration.
- Evidence role: preserve exact synthetic inputs, native parser/formatter query and result supporting in-memory processing and proving malformed-source recovery. Native parsed/ formatted Unicode uses source notation. Future citation implementation must strictly validate source before native parsing and preserve encoding semantics. This probe is not maintained regression coverage or GUI/typesetting evidence.
- Execution: `timeout 120s emacs-twist --batch -L . --load tmp/doc-01-bibliography-probe.el` exited 0 outside the command sandbox; the first sandbox run timed out (124) without a result. No user bibliography files, databases or network were requested.
- GAW checkpoint: the commit containing this manifest; its sole additional project parent is the captured full HEAD.

| Source | Archive path relative to snapshot | Tracked status | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| `tmp/doc-01-bibliography-probe.el` | `files/tmp/doc-01-bibliography-probe.el` | untracked, ignored | 1110 | `2789be58247e751dfdf0fec9e0bec26ada2f39c88104ec96fafe91c5c0002564` |
| `tmp/doc-01-bibliography-probe.scm` | `files/tmp/doc-01-bibliography-probe.scm` | untracked, ignored | 401 | `d93e7e23d252723325289c924bbcf5cd8f43eeab1ae45888c99ca953ee7a2e65` |
| `tmp/doc-01-bibliography-probe.txt` | `files/tmp/doc-01-bibliography-probe.txt` | untracked, ignored | 1204 | `5c720c4c42d2a53a3dd5fb27034a1e5be4a29683646d1ac92ef3a53ef401d58f` |
