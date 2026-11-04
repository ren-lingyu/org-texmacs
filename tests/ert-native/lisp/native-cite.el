;;; native-cite.el --- Standard native bibliography regressions -*- lexical-binding: t; -*-
(require 'ox-texmacs)

(defconst org-texmacs-test--cite-bib
  (concat
   "@book{one,author={Alpha, Adelaide},title={Properties of $\\alpha_i$},year={2026},publisher={Press}}\n"
   "@book{two,author={Zulu, Zachary},title={Ratio $\\frac{a}{b}$},year={2025},publisher={Press}}\n"))

(defun org-texmacs-test--cite-source (file style &optional keys)
  "Prepare FILE using explicit native STYLE and citation KEYS."
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+bibliography: "
     file
     "\n#+cite_export: texmacs-native "
     style
     "\n"
     "First [cite:"
     (or keys "@two; @one")
     "]. Again [cite:@one].\n"
     "#+print_bibliography:\n")
    (let ((org-export-use-babel nil))
      (org-texmacs-prepare-buffer (current-buffer)))))

(ert-deftest org-texmacs-native-cite-real-styles-switch-and-own ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "references.bib" test-directory))
         plain
         alpha
         abbrv
         process)
     (with-temp-file file
       (insert org-texmacs-test--cite-bib))
     (dolist (style '("plain" "alpha" "abbrv" "tm-alpha" "plain"))
       (let* ((input (org-texmacs-test--cite-source file style))
              (body
               (org-texmacs-document-body
                (org-texmacs-document input)))
              (text (prin1-to-string body)))
         (should (memq 'with-bib (flatten-tree body)))
         (should (memq 'rsub (flatten-tree body)))
         (should (memq 'frac (flatten-tree body)))
         (should
          (= 2 (length (org-texmacs--bibliography-labels body))))
         (should (string-match-p "Properties" text))
         (should (string-match-p "Ratio" text))
         (if process
             (should (eq process org-texmacs--worker-process))
           (setq process org-texmacs--worker-process))
         (pcase style
           ("plain"
            (if plain
                (should (equal plain body))
              (setq plain body)))
           ("alpha" (setq alpha body))
           ("abbrv" (setq abbrv body))
           ("tm-alpha" (should (equal alpha body))))
         ;; Neither pure lowering nor subsequent input copies consult files.
         (let ((saved (copy-tree body)))
           (cl-letf (((symbol-function 'org-texmacs--worker-request)
                      (lambda (&rest _)
                        (ert-fail "Pure lowering parsed again")))
                     ((symbol-function
                       'org-texmacs--bibliography-format)
                      (lambda (&rest _)
                        (ert-fail "Pure lowering formatted again"))))
             (should
              (equal
               saved
               (org-texmacs-document-body
                (org-texmacs-document input))))))))
     (should-not (equal plain alpha))
     (should-not (equal plain abbrv)))))

(ert-deftest org-texmacs-native-cite-invalid-styles-reuse-worker ()
  (org-texmacs-test--with-worker
   (let* ((file (expand-file-name "references.bib" test-directory))
          process
          plain)
     (with-temp-file file
       (insert org-texmacs-test--cite-bib))
     (setq
      plain
      (org-texmacs-document-body
       (org-texmacs-document
        (org-texmacs-test--cite-source file "plain")))
      process org-texmacs--worker-process)
     (dolist (style
              '("unknown-style"
                "../plain"
                "plain/../../kernel"
                "tm-unknown"))
       (should-error
        (org-texmacs-test--cite-source file style)
        :type 'org-texmacs-document-error)
       (should (eq process org-texmacs--worker-process))
       (should (process-live-p process)))
     (should
      (equal
       plain
       (org-texmacs-document-body
        (org-texmacs-document
         (org-texmacs-test--cite-source file "plain"))))))))

(ert-deftest org-texmacs-native-cite-missing-and-ambiguous-keys ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "references.bib" test-directory))
         (second (expand-file-name "second.bib" test-directory)))
     (with-temp-file file
       (insert org-texmacs-test--cite-bib))
     (should-error
      (org-texmacs-test--cite-source file "plain" "@missing")
      :type 'org-texmacs-document-error)
     (with-temp-file second
       (insert org-texmacs-test--cite-bib))
     (should-error
      (org-texmacs-test--cite-source (concat file " " second) "plain")
      :type 'org-texmacs-document-error)
     (should
      (org-texmacs-input-p
       (org-texmacs-test--cite-source file "alpha"))))))

(ert-deftest org-texmacs-native-cite-legacy-format-wire-default ()
  (org-texmacs-test--with-worker
   (let*
       ((tree
         (org-texmacs--worker-request
          org-texmacs-test--cite-bib 'bibliography))
        request
        ;; Obtain the wire tree from the real formatter without duplicating
        ;; bibliography encoding in a test-only serializer.
        (call (symbol-function 'org-texmacs--worker-call))
        old
        new)
     (cl-letf (((symbol-function 'org-texmacs--worker-call)
                (lambda (make)
                  (setq request (funcall make 1))
                  (funcall call make))))
       (setq new
             (org-texmacs--bibliography-format
              (list
               :prefix "legacy"
               :keys '("one" "two")
               :entries tree
               :style "plain"))))
     (should (string-suffix-p " \"plain\")\n" request))
     (setq request
           (concat
            (string-remove-suffix " \"plain\")\n" request) ")\n"))
     (setq old
           (org-texmacs--worker-call
            (lambda (id)
              (replace-regexp-in-string
               "format-bibliography 1 "
               (format "format-bibliography %d " id)
               request
               t
               t))))
     (should (eq (car old) 'ok))
     (should (equal (nth 2 old) (nth 3 new))))))

(ert-deftest org-texmacs-native-cite-loader-preflight ()
  (org-texmacs-test--with-worker
   (let* ((out
           (file-name-directory
            (getenv "ORG_TEXMACS_TEST_NAMES_FILE")))
          (result (expand-file-name "loader.sexp" out))
          (script (expand-file-name "run.scm" default-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file)))
       (insert-file-contents
        (getenv "ORG_TEXMACS_TEST_CITE_STYLE_SCHEME"))
       (goto-char (point-max))
       (insert
        (format "\n(run-loader %s %s)\n(quit-TeXmacs)\n"
                (org-texmacs--scheme-string result)
                (org-texmacs--scheme-string default-directory))))
     (with-temp-buffer
       (let ((process
              (make-process
               :name "native-loader-probe"
               :buffer (current-buffer)
               :connection-type 'pipe
               :coding 'utf-8-unix
               :noquery t
               :sentinel #'ignore
               :command
               (list
                org-texmacs-program
                "-H"
                "-s"
                "-x"
                (format "(load %S)" script))))
             (deadline (+ (float-time) 45)))
         (unwind-protect
             (progn
               (while (and (process-live-p process)
                           (< (float-time) deadline))
                 (accept-process-output process 0.1))
               (write-region
                (point-min)
                (point-max)
                (expand-file-name "native-output.txt" out)
                nil
                'silent)
               (message "Native probe output: %s" (buffer-string))
               (should-not (process-live-p process))
               (should (= 0 (process-exit-status process))))
           (when (process-live-p process)
             (delete-process process)))))
     (with-temp-buffer
       (insert-file-contents result)
       (let* ((data (read (current-buffer)))
              (normal (nth 1 data))
              (missing (nth 2 data)))
         (should
          (cl-every
           (lambda (r) (eq (nth 1 r) 'ok)) (cl-subseq normal 0 4)))
         (should
          (cl-every
           (lambda (r)
             (and (eq (nth 1 r) 'error) (= (car (last r)) 0)))
           (nthcdr 4 normal)))
         (should (eq (nth 1 missing) 'error))
         (should (= (car (last missing)) 0))
         (should (eq (nth 1 (nth 3 data)) 'ok))
         (should (eq (nth 1 (nth 4 data)) 'error))
         (should (= (car (last (nth 4 data))) 0))
         (should (eq (nth 5 data) 'restored)))))))

(ert-deftest org-texmacs-native-cite-nested-real-transactions ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "references.bib" test-directory))
         child
         (calls 0))
     (with-temp-file file
       (insert org-texmacs-test--cite-bib))
     (let ((org-export-before-processing-functions
            (list
             (lambda (_backend)
               (cl-incf calls)
               (when (= calls 1)
                 (setq child
                       (org-texmacs-test--cite-source
                        file "alpha")))))))
       (let* ((outer (org-texmacs-test--cite-source file "plain"))
              (body
               (org-texmacs-document-body
                (org-texmacs-document outer)))
              (nested
               (org-texmacs-document-body
                (org-texmacs-document child))))
         (should (= calls 2))
         (should-not (equal body nested))
         (should-not
          (eq
           (org-texmacs-input-ast outer)
           (org-texmacs-input-ast child)))
         (should
          (equal
           body
           (org-texmacs-document-body
            (org-texmacs-document outer)))))))))

(ert-deftest org-texmacs-native-default-real-source-and-text ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "references.bib" test-directory))
         (org-cite-export-processors '((t basic)))
         (org-export-use-babel nil))
     (with-temp-file file
       (insert org-texmacs-test--cite-bib))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+bibliography: "
        file
        "\n[cite:@one; @two]\n#+print_bibliography:\n")
       (let ((document
              (org-texmacs-document-from-buffer (current-buffer))))
         (should
          (memq
           'with-bib
           (flatten-tree (org-texmacs-document-body document)))))
       (should
        (string-prefix-p "<TeXmacs|" (org-export-as 'texmacs)))))))
