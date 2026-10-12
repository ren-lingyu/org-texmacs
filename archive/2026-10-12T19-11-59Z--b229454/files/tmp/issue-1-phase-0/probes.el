;;; probes.el --- Isolated Phase 0 evidence -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'ox)
(require 'ox-ascii)
(require 'ox-html)
(require 'oc)
(require 'ox-texmacs)
(defvar p0-observations nil)
(defvar p0-events nil)
(defvar p0-source nil)
(defvar p0-working nil)
(defvar p0-includes nil)
(defvar p0-filter-context nil)
(defvar p0-discovery nil)

(defun p0-record (name value)
  (push (cons name value) p0-observations))
(defun p0-state ()
  (list (save-restriction (widen) (buffer-string)) (point) (mark t)
        mark-active (point-min) (point-max) (buffer-modified-p)
        (buffer-file-name) default-directory))
(defun p0-org (text function)
  (with-temp-buffer
    (let ((org-mode-hook nil) (org-inhibit-startup t)
          (org-export-use-babel nil) (org-export-replace-macros nil)
          (org-export-allow-bind-keywords nil)
          (org-export-before-processing-functions nil)
          (org-export-before-parsing-functions nil)
          (org-export-filter-parse-tree-functions nil)
          (org-cite-global-bibliography nil))
      (org-mode)
      (insert text)
      (goto-char (point-min))
      (funcall function))))
(defun p0-annotate (text citep &optional filter)
  (p0-org text
    (lambda ()
      (let* ((backend (org-export-get-backend 'ascii))
             (org-export-current-backend 'ascii)
             (info (org-combine-plists
                    (org-export--get-export-attributes backend nil nil nil)
                    (org-export--get-buffer-attributes)))
             (org-export-filter-parse-tree-functions (and filter (list filter))))
        (org-export-with-buffer-copy
          (org-export--annotate-info
           backend info nil nil
           (list :with-cite-processors citep :cite-export '((t p0)))))))))
(defun p0-keys (tree)
  (org-element-map tree 'citation-reference
    (lambda (r) (org-element-property :key r))))
(defun p0-raw-values (tree)
  (let (values)
    (cl-labels ((walk (node)
                  (unless (stringp node)
                    (if (eq (org-element-type node) 'raw)
                        (push (apply #'concat (org-element-contents node)) values)
                      (mapc #'walk (org-element-contents node))))))
      (walk tree))
    (nreverse values)))
(defun p0-remap (tree backend info)
  (setq p0-filter-context
        (list backend (plist-get info :bibliography)
              (plist-get info :parse-tree) major-mode
              org-export-current-backend))
  (org-element-map tree 'citation-reference
    (lambda (r)
      (when (equal (org-element-property :key r) "managed-uuid")
        (org-element-put-property r :key "external-key"))))
  tree)
(org-cite-register-processor 'p0
  :export-citation (lambda (&rest _) "PROCESSOR-STRING")
  :export-bibliography (lambda (&rest _) "BIBLIOGRAPHY-STRING"))

(ert-deftest p0-01-copy-hook-lifecycle ()
  (p0-org "hidden\n* Heading\ntext\n"
    (lambda ()
      (goto-char 13)
      (set-mark 18)
      (narrow-to-region 8 (point-max))
      (let* ((before (p0-state)) (p0-source (current-buffer))
             (p0-events nil) (p0-working nil)
             (org-export-before-processing-functions
              (list (lambda (backend)
                      (setq p0-working (current-buffer))
                      (should-not (eq (current-buffer) p0-source))
                      (should (derived-mode-p 'org-mode))
                      (push (list 'before-processing backend
                                  org-export-current-backend) p0-events)
                      (goto-char (point-max)) (insert "\nHOOK-MARKER\n"))))
             (org-export-before-parsing-functions
              (list (lambda (backend)
                      (push (list 'before-parsing backend) p0-events))))
             (org-export-filter-parse-tree-functions
              (list (lambda (tree backend info)
                      (push (list 'ast-filter backend
                                  (org-export-backend-name (plist-get info :back-end)))
                            p0-events)
                      tree)))
             (out (org-export-as 'ascii nil nil t '(:with-cite-processors nil))))
        (should (string-match-p "HOOK-MARKER" out))
        (should (equal before (p0-state)))
        (should-not (buffer-live-p p0-working))
        (should (equal (mapcar #'car (reverse p0-events))
                       '(before-processing before-parsing ast-filter)))
        (p0-record 'copy-lifecycle
                   (list :events (reverse p0-events) :source-preserved t
                         :work-destroyed t
                         :after-includes-hook-bound
                         (boundp 'org-export-after-includes-functions)))))))

(ert-deftest p0-02-recursive-include-and-origin ()
  (let ((p0-includes nil)
        (around (lambda (original &rest args)
                  (push (list :mode major-mode :dir default-directory
                              :args (copy-tree args)) p0-includes)
                  (apply original args))))
    (unwind-protect
        (progn
          (advice-add 'org-export-expand-include-keyword :around around)
          (p0-org "#+INCLUDE: \"parts/b.org\"\n"
            (lambda ()
              (setq-local buffer-file-name (expand-file-name "fixtures/root.org"))
              (setq-local default-directory (expand-file-name "fixtures/"))
              (let ((before (p0-state)))
                (org-export-with-buffer-copy
                  (org-export-expand-include-keyword)
                  (let* ((expanded (buffer-string))
                         (tree (org-element-parse-buffer))
                         (links (org-element-map tree 'link
                                  (lambda (l) (org-element-property :path l))))
                         (runs nil) (pos (point-min)))
                    (while (< pos (point-max))
                      (when (text-properties-at pos)
                        (push (list pos (text-properties-at pos)) runs))
                      (setq pos (next-property-change pos nil (point-max))))
                    (should (string-match-p "NESTED-MARKER" expanded))
                    (should (member "parts/b.png" links))
                    (should (member "parts/deeper/c.png" links))
                    (should (string-match-p "(strong \"same\")" expanded))
                    (p0-record 'include
                               (list :calls (reverse p0-includes) :links links
                                     :expanded expanded :property-runs runs))))
                (should (equal before (p0-state)))))))
      (advice-remove 'org-export-expand-include-keyword around))
    (should-not (advice-member-p around 'org-export-expand-include-keyword))
    (should (>= (length p0-includes) 3))))

(ert-deftest p0-03-filter-retains-structured-citations ()
  (let* ((p0-filter-context nil)
         (info (p0-annotate "[cite:@managed-uuid]\n#+PRINT_BIBLIOGRAPHY:\n"
                            nil #'p0-remap))
         (tree (plist-get info :parse-tree)))
    (should (equal (p0-keys tree) '("external-key")))
    (should (eq (car p0-filter-context) 'ascii))
    (should (eq (nth 3 p0-filter-context) 'org-mode))
    (should (org-element-map tree 'keyword
              (lambda (k) (equal "PRINT_BIBLIOGRAPHY" (org-element-property :key k)))
              nil t))
    (p0-record 'retained-citation
               (list :keys (p0-keys tree) :filter-context p0-filter-context
                     :raw-citation-count
                     (length (org-element-map tree 'export-snippet #'identity))))))

(ert-deftest p0-04-full-annotation-replaces-citations ()
  (let* ((info (p0-annotate "[cite:@managed-uuid]\n#+PRINT_BIBLIOGRAPHY:\n"
                           t #'p0-remap))
         (tree (plist-get info :parse-tree))
         (snippets (p0-raw-values tree)))
    (should-not (p0-keys tree))
    (should (cl-some (lambda (s) (string-match-p "PROCESSOR-STRING" s)) snippets))
    (should (cl-some (lambda (s) (string-match-p "BIBLIOGRAPHY-STRING" s)) snippets))
    (p0-record 'processor-replacement (list :keys nil :snippets snippets))))

(ert-deftest p0-05-bibliography-discovery-advice ()
  (p0-org "#+BIBLIOGRAPHY: local.bib\n"
    (lambda ()
      (let* ((org-cite-global-bibliography '("global.bib" "local.bib"))
             (normal (org-cite-list-bibliography-files))
             (p0-discovery nil)
             (filter (lambda (paths)
                       (should (derived-mode-p 'org-mode))
                       (setq p0-discovery (list major-mode default-directory))
                       (append paths '("managed.bib"))))
             (reads nil))
        (unwind-protect
            (progn
              (advice-add 'org-cite-list-bibliography-files :filter-return filter)
              (cl-letf (((symbol-function 'org-file-contents)
                         (lambda (&rest args) (push args reads) (error "Unexpected read"))))
                (let* ((paths (org-cite-list-bibliography-files))
                       (info (org-cite-store-bibliography (list :bibliography nil))))
                  (should (equal paths '("local.bib" "global.bib" "managed.bib")))
                  (should (equal (plist-get info :bibliography) paths))
                  (should-not reads)
                  (p0-record 'bibliography-discovery
                             (list :normal normal :advised paths :info-paths paths
                                   :context p0-discovery :text-reads reads)))))
          (advice-remove 'org-cite-list-bibliography-files filter))
        (should (equal (org-cite-list-bibliography-files) normal))))))

(ert-deftest p0-06-html-coexistence-and-guard ()
  (p0-org "A\n"
    (lambda ()
      (let ((before (p0-state))
            (org-export-before-processing-functions
             (list #'org-texmacs--export-reject-generic-preprocessing
                   (lambda (_backend) (goto-char (point-max)) (insert "HTML-HOOK\n"))))
            (org-export-filter-parse-tree-functions
             (list (lambda (tree _backend _info)
                     (org-element-map tree 'paragraph
                       (lambda (p) (org-element-adopt p "FILTER-MARKER"))) tree))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (error "Unexpected worker request"))))
          (let ((out (org-export-as 'html nil nil t '(:with-cite-processors nil))))
            (should (string-match-p "HTML-HOOK" out))
            (should (string-match-p "FILTER-MARKER" out)))
          (should-error (org-export-as 'texmacs) :type 'user-error))
        (should (equal before (p0-state)))
        (p0-record 'html-coexistence (list :html-hooks t :texmacs-guard t
                                         :source-preserved t :worker-requests 0))))))

(ert-deftest p0-07-selection-and-options ()
  (p0-org "#+TITLE: FILE-TITLE\n* Root\n:PROPERTIES:\n:EXPORT_TITLE: SUBTREE-TITLE\n:END:\nalpha\n** Child\nbeta\n* Other\ngamma\n"
    (lambda ()
      (search-forward "* Root") (beginning-of-line)
      (let* ((before (p0-state)) (captured nil)
            (org-export-filter-parse-tree-functions
             (list (lambda (tree _backend info)
                     (setq captured (list :title (org-element-interpret-data (plist-get info :title))
                                          :heads (org-element-map tree 'headline
                                                   (lambda (h) (org-element-property :raw-value h)))))
                     tree))))
        (let ((out (org-export-as 'ascii t nil t
                                  '(:title "EXTERNAL-TITLE" :with-cite-processors nil))))
          (should (string-match-p "beta" out))
          (should-not (string-match-p "gamma" out))
          (should (string-match-p "SUBTREE-TITLE" (plist-get captured :title)))
          (should (equal before (p0-state)))
          (p0-record 'subtree captured))
        (search-forward "alpha")
        (let ((beg (- (point) 5)) (end (point)))
          (goto-char beg) (set-mark end) (setq mark-active t)
          (let ((transient-mark-mode t) (before-region (p0-state)))
            (let ((out (org-export-as 'ascii t nil t '(:with-cite-processors nil))))
              (should (string-match-p "alpha" out))
              (should-not (string-match-p "beta" out))
              (should (equal before-region (p0-state)))
              (p0-record 'region-with-subtree captured))))))))

(ert-deftest p0-08-copy-error-cleanup ()
  (p0-org "text\n"
    (lambda ()
      (let* ((before (p0-state)) (work nil)
            (org-export-before-processing-functions
             (list (lambda (_backend)
                     (setq work (current-buffer))
                     (insert "modified") (error "controlled hook error")))))
        (should-error (org-export-as 'ascii))
        (should-not (buffer-live-p work))
        (should (equal before (p0-state)))
        (p0-record 'copy-error-cleanup t)))))

(ert-deftest p0-09-public-filter-tool-on-texmacs-ast ()
  (p0-org "[cite:@managed-uuid]\n"
    (lambda ()
      (let* ((original (org-element-parse-buffer))
             (owned (org-element-copy original t))
             (org-export-current-backend 'texmacs)
             (org-export-filter-parse-tree-functions (list #'p0-remap))
             (info (org-export-install-filters
                    (list :back-end (org-export-get-backend 'texmacs)
                          :parse-tree owned :bibliography '("snapshot.bib"))))
             (filtered (org-export-filter-apply-functions
                        (plist-get info :filter-parse-tree) owned info)))
        (should (equal (p0-keys original) '("managed-uuid")))
        (should (equal (p0-keys filtered) '("external-key")))
        (should (eq (car p0-filter-context) 'texmacs))
        (p0-record 'public-filter-tools
                   (list :original (p0-keys original) :owned (p0-keys filtered)
                         :backend (car p0-filter-context)))))))

(ert-deftest p0-10-island-coordinates-and-replacement-identity ()
  (p0-org "Text (math \"x\") *bold*.\n\n#+begin_texmacs\n(strong \"same\")\n#+end_texmacs\n"
    (lambda ()
      (let* ((tags '("math"))
             (_ (setq-local org-texmacs-fragment-tags tags))
             (source (buffer-string))
             (spans (org-texmacs--fragment-collect tags))
             (old-pos (org-texmacs-fragment-span-begin (car spans)))
             (prepared (org-texmacs--document-prepare-source
                        source tags (org-texmacs--document-heading-settings)
                        (org-texmacs--document-link-settings)
                        (org-texmacs--document-options)))
             (tree (nth 0 prepared))
             (islands (nth 1 prepared))
             (replacement (org-element-copy tree t))
             (reachable nil))
        (cl-labels ((walk (node)
                      (push node reachable)
                      (unless (stringp node)
                        (mapc #'walk (org-element-contents node)))))
          (walk replacement))
        (should (= (length islands) 2))
        (should (cl-every (lambda (entry) (not (memq (car entry) reachable))) islands))
        (goto-char (point-min)) (insert "PREFIX\n")
        (let* ((new-spans (org-texmacs--fragment-collect tags))
               (new-pos (org-texmacs-fragment-span-begin (car new-spans))))
          (should (= new-pos (+ old-pos 7)))
          (p0-record 'islands
                     (list :before old-pos :after new-pos :island-count (length islands)
                           :replacement-invalidates-identity-maps t)))))))

(ert-deftest p0-11-discovery-can-read-setup-files ()
  (p0-org "#+SETUPFILE: config/setup.org\n#+BIBLIOGRAPHY: local.bib\n"
    (lambda ()
      (setq-local default-directory (expand-file-name "fixtures/"))
      (let* ((reads nil)
             (spy (lambda (original file &rest args)
                    (push file reads) (apply original file args))))
        (unwind-protect
            (progn
              (advice-add 'org-file-contents :around spy)
              (let ((paths (org-cite-list-bibliography-files)))
                (should (member "config/library.bib" paths))
                (should (cl-some (lambda (p) (string-suffix-p "config/setup.org" p)) reads))
                (should-not (cl-some (lambda (p) (string-suffix-p ".bib" p)) reads))
                (p0-record 'setup-discovery (list :paths paths :reads (reverse reads)))))
          (advice-remove 'org-file-contents spy))))))

(ert-deftest p0-12-macro-babel-stage-controls ()
  (p0-org "#+MACRO: demo EXPANDED-MACRO\n{{{demo}}}\n"
    (lambda ()
      (let* ((events nil)
             (org-export-replace-macros t)
             (org-export-use-babel t)
             (org-export-before-processing-functions
              (list (lambda (_backend) (push 'before-processing events))))
             (org-export-before-parsing-functions
              (list (lambda (_backend)
                      (should (string-match-p "EXPANDED-MACRO" (buffer-string)))
                      (push 'before-parsing events)))))
        (cl-letf (((symbol-function 'org-babel-exp-process-buffer)
                   (lambda () (push 'babel-stage events))))
          (org-export-as 'ascii nil nil t '(:with-cite-processors nil)))
        (should (equal (reverse events) '(before-processing babel-stage before-parsing)))
        (p0-record 'macro-babel (list :events (reverse events) :real-code-execution nil))))))

(ert-deftest p0-13-full-annotation-queries-id-database ()
  (require 'org-id)
  (let ((calls nil))
    (cl-letf (((symbol-function 'org-id-find)
               (lambda (id &rest _) (push id calls) nil)))
      (p0-annotate "[[id:outside-id][target]]\n" nil))
    (should (equal calls '("outside-id")))
    (p0-record 'ambient-id-lookup (list :calls calls :real-database-reads nil))))

(ert-deftest p0-14-local-copy-shares-mutable-values ()
  (p0-org "text\n"
    (lambda ()
      (setq-local org-cite-global-bibliography (list (copy-sequence "original.bib")))
      (let ((source-value org-cite-global-bibliography))
        (org-export-with-buffer-copy
          (should (eq source-value org-cite-global-bibliography))
          (setcar org-cite-global-bibliography "changed.bib"))
        (should (equal org-cite-global-bibliography '("changed.bib")))
        (p0-record 'mutable-local-alias
                   (list :copy-shares-list t :mutation-affects-source-setting t))))))

(defun p0-run ()
  (let ((stats (ert-run-tests-batch "^p0-")))
    (with-temp-file "observations.sexp"
      (let ((print-length nil) (print-level nil))
        (prin1 (reverse p0-observations) (current-buffer)) (insert "\n")))
    (with-temp-file "summary.txt"
      (insert (format "Emacs %s / Org %s\nTotal: %s\nUnexpected: %s\n"
                      emacs-version (org-version) (ert-stats-total stats)
                      (ert-stats-completed-unexpected stats))))
    (kill-emacs (if (zerop (ert-stats-completed-unexpected stats)) 0 1))))
(p0-run)
