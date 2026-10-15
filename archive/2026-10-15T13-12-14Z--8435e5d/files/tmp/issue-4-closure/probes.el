;;; probes.el --- Bounded native semantic audit -*- lexical-binding: t; -*-
(require 'json)
(let ((output (getenv "PROBE_OUTPUT"))
      (coding-system-for-read 'utf-8-unix)
      (coding-system-for-write 'utf-8-unix) dates records)
  (dolist (raw '("<2026-10-14>" "[2026-10-14 Wed]"
                 "<2026-10-14 Wed 15:30 +0800>" "<2026-10-14  15:30  +0800>"
                 "<2026-10-14 Wed 15:30-16:00>"
                 "<2026-10-14 Wed>--<2026-10-15 Thu>"
                 "<2026-10-14 Wed +1w>" "<2026-10-14 Wed -3d>"
                 "<%%(diary-anniversary 10 14 2000)>"))
    (with-temp-buffer
      (org-mode) (insert "#+DATE: " raw "\n")
      (let ((node (car (org-element-parse-secondary-string
                        raw (org-element-restriction 'keyword)))))
        (push (list (cons 'source raw)
                    (cons 'ast (let ((print-circle t)) (prin1-to-string node)))
                    (cons 'tree (condition-case err
                                    (prin1-to-string (org-texmacs-document-body
                                                      (org-texmacs-document-from-buffer (current-buffer))))
                                  (error (error-message-string err))))) dates))))
  (setq dates (nreverse dates))
  (with-temp-file (expand-file-name "dates.json" output)
    (insert (json-serialize (vconcat dates))))
  (org-texmacs-test--with-worker
    (dolist (case '(("code" . "BeforeCode\n\n#+begin_example -i\n  AlphaCode\n    BetaCode\n\n  GammaCode (math \"hidden\") <alpha>\n#+end_example\n\n: FixedFirst\n:   FixedSecond\n\n#+begin_src text -i\n  SourceFirst\n\n    SourceSecond\n#+end_src\n\nAfterCode\n")
                    ("lists" . "BeforeList\n\n- OuterFirst\n\n  OuterContinuation\n\n  1. NestedFirst\n  2. NestedSecond\n- OuterSecond\n\nSeparatorList\n\n1. OrderedFirst\n2. OrderedSecond\n\nAnotherSeparator\n\n- TermFirst :: DefinitionFirst\n\n  DefinitionContinuation\n- TermSecond :: DefinitionSecond\n\nAfterList\n")
                    ("tables" . "BeforeTable [[one]] [[two]]\n\n#+name: one\n#+caption[ShortOne]: LongCaptionOne\n| HeadLeft | HeadRight |\n|---+---|\n| <l> | <r> |\n| Left | Right |\n\n#+name: two\n#+caption: LongCaptionTwo\n| OtherLeft | OtherRight |\n\nAfterTable [[one][FirstTable]] [[two]]\n")
                    ("headings" . "* FirstHeading\nBodyFirst [[*SecondHeading]]\n** ChildHeading\nBodyChild\n*** ThirdHeading\nBodyThird\n**** FourthHeading\nBodyFourth\n***** FifthHeading\nBodyFifth\n****** LowHeading\nBodyLow\n* SecondHeading\nBodySecond [[*FirstHeading]] [[*FourthHeading]] [[*FifthHeading]]\n* UnnumberedHeading\n:PROPERTIES:\n:UNNUMBERED: t\n:END:\nBodyUnnumbered\n")
                    ("inline" . "PlainInline *BoldInline* /ItalicInline/ _UnderlineInline_ +StrikeInline+ =VerbatimInline= \\\\\nAfterBreak [[https://example.org][ExternalLink]]\n")
                    ("metadata" . "#+TITLE: TitleAudit\n#+AUTHOR: AuthorAudit\n#+DATE: <2026-10-14>\nBodyMetadata\n")))
      (let ((name (car case)))
        (with-temp-buffer
          (org-mode)
          (insert (if (equal name "headings") "#+OPTIONS: toc:5 H:5\n" "#+OPTIONS: toc:nil\n")
                  (cdr case))
          (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
                 (document (org-texmacs-document input))
                 (pdf (expand-file-name (concat name ".pdf") output)))
            (with-temp-file (expand-file-name (concat name "-ast.sexp") output)
              (let ((print-circle t)) (prin1 (org-texmacs-input-ast input) (current-buffer))))
            (with-temp-file (expand-file-name (concat name "-tree.sexp") output)
              (prin1 (org-texmacs-document-body document) (current-buffer)))
            (org-texmacs-document-save-pdf document pdf)
            (push (list (cons 'name name)
                        (cons 'text (org-texmacs-test--pdf-text pdf))
                        (cons 'words (vconcat (mapcar #'vconcat
                                                      (org-texmacs-test--pdf-words pdf)))))
                  records))))))
  (setq records (nreverse records))
  (with-temp-file (expand-file-name "audit.json" output)
    (insert (json-serialize (list (cons 'emacs emacs-version) (cons 'org (org-version))
                                  (cons 'cases (vconcat records))))))
  (message "Issue4 closure: %d dates and %d native cases" (length dates) (length records)))
