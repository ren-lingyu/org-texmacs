# Historical native footnote environment probe

Non-authoritative historical evidence; do not use this snapshot as current memory.

- Capture time: 2026-10-06T16:59:25Z.
- Project commit: `77a2888` (full HEAD `77a28881807d1bf8dba508b1f8a07f392083dfca`).
- Project state: HEAD at capture time. Named-footnote implementation was uncommitted; the temporary mirror overlay was also local and uncommitted.
- Selection: exactly the three repository-relative `tmp/doc-01-footnote-probe` files listed below. No directories, binary artifacts, or mirror configuration selected.
- Evidence role: runner, Scheme query and exact result reproduce the diagnosed limitation that a fresh headless native session returned `(uninit)` for footnote macro environment queries. This is not evidence of absent macros or correct rendered numbering; maintained native body tests independently establish tree acceptance and encoding.
- GAW checkpoint: the commit containing this manifest, with the captured full project HEAD as its sole additional project parent.

| Source | Archive path relative to snapshot | Tracked status | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| `tmp/doc-01-footnote-probe.el` | `files/tmp/doc-01-footnote-probe.el` | untracked, ignored | 759 | `063fa20aeb358f1c93c6bd99c997f4aac4ad5975371a209fd20e4a6034cc96ac` |
| `tmp/doc-01-footnote-probe.scm` | `files/tmp/doc-01-footnote-probe.scm` | untracked, ignored | 478 | `ac68127264a03444f4c4c69cb8d7ffd15e649b7c6b1e5a731ff54a91cd83d333` |
| `tmp/doc-01-footnote-probe.txt` | `files/tmp/doc-01-footnote-probe.txt` | untracked, ignored | 201 | `3695ed430f9ba86943b6a5f443651deba9bb3b7723f27aa79231c3b2387f6ca0` |
