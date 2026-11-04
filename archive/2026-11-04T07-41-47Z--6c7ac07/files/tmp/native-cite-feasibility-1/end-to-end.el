;;; end-to-end.el --- gate III, only after I/II independently passed -*- lexical-binding: t; -*-
(load (getenv "NATIVE_ADAPTER") nil t)
(ert-deftest native-cite-real-end-to-end ()
 (org-texmacs-test--with-worker
  (x-with-processors
   (let ((x-mode 'real) (org-cite-export-processors '((t texmacs-native))) rows bodies
         (file (f-out "references.bib")))
    (with-temp-file file
     (insert "@book{one,title={An $\\alpha_i$ result},author={Alpha, Ada},year={2026},publisher={Press}}\n"
             "@book{two,title={A $\\frac{a}{b}$ result},author={Zulu, Zoe},year={2025},publisher={Press}}\n"))
    (dolist (style '("plain" "alpha"))
     (let* ((source (concat (format "#+bibliography: %s\n#+cite_export: texmacs-native %s\n" file style)
                           "First [cite:@one] followed. Repeat /[cite:@one]/.\n\nMultiple [cite:@two; @one].\n\n#+print_bibliography:\nAfter bibliography.\n"))
            (result (x-run source nil 'text)) (input (plist-get result :input))
            (doc (plist-get result :document)) (body (org-texmacs-document-body doc)))
      (should (memq 'math (flatten-tree body))) (should (memq 'frac (flatten-tree body))) (should (memq 'rsub (flatten-tree body)))
      (push body bodies)
      (with-temp-file (f-out (concat "end-to-end-" style ".org")) (insert source))
      (push (list :style style :source source :text-output (plist-get result :text) :body (f-str body)
                  :bibliography (f-str (org-texmacs-input-bibliography input))
                  :requests (plist-get result :requests) :identity (plist-get result :identity)
                  :pdf-text (f-render doc (concat "end-to-end-" style))) rows)))
    (should-not (equal (car bodies) (cadr bodies)))
    (f-write "end-to-end.json" (nreverse rows))))))
