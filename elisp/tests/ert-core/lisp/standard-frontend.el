;;; standard-frontend.el --- Standard frontend ownership -*- lexical-binding: t; -*-

(ert-deftest
    org-texmacs-standard-frontend-scalar-info-is-literal-owned-metadata
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "Body.
")
    (let* ((org-export-use-babel nil)
           (title (copy-sequence "*Literal title*"))
           (input
            (org-texmacs--standard-consume
             'input nil nil (list :title title)))
           (metadata
            (plist-get (org-texmacs-input-info input) :title)))
      (aset title 0 ?X)
      (should (equal metadata '("*Literal title*")))
      (should-not (org-element-map metadata 'bold #'identity))
      (should
       (string-search
        "*Literal title*"
        (prin1-to-string
         (org-texmacs-document-body
          (org-texmacs-document input))))))))

(ert-deftest
    org-texmacs-standard-frontend-parsed-options-and-extension-context
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "Body.
")
    (let* ((org-export-use-babel nil)
           (title (copy-sequence "Owned title"))
           (bold (org-element-create 'bold nil title))
           (secondary (list bold))
           (opaque (make-hash-table))
           (filter-calls 0)
           (options
            (list :title secondary :extension-context opaque)))
      (org-element-put-property bold :parent secondary)
      (let ((org-export-filter-options-functions
             (list
              (lambda (info _backend)
                (cl-incf filter-calls)
                (should
                 (eq opaque (plist-get info :extension-context)))
                info))))
        (cl-letf (((symbol-function 'read-file-name)
                   (lambda (&rest _)
                     (aset title 0 ?X)
                     (expand-file-name "owned.tm" default-directory)))
                  ((symbol-function 'org-texmacs-document-serialize)
                   (lambda (document)
                     (should
                      (string-search
                       "Owned title"
                       (prin1-to-string
                        (org-texmacs-document-body document))))
                     "Native"))
                  ((symbol-function 'org-texmacs--native-save-bytes)
                   (lambda (_bytes target &rest _) target)))
          (org-texmacs-export-to-texmacs nil nil nil nil options)))
      (should (= filter-calls 1)))))

(ert-deftest
    org-texmacs-standard-frontend-complete-latin1-byte-transport
    ()
  (let* ((bytes (apply #'unibyte-string (number-sequence 0 255)))
         (text (decode-coding-string bytes 'iso-latin-1-unix)))
    (should (equal bytes (org-texmacs--standard-text-bytes text)))
    (should-error
     (org-texmacs--standard-text-bytes (concat text "中"))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-standard-frontend-table-alignment-is-frozen
    ()
  (dolist
      (case
       '(("| Left | Center | Right |\n| <l> | <c> | <r> |\n| L | C | R |\n"
          "l"
          "c"
          "r")
         ("| Name | Count |\n| A | 1 |\n| B | 2 |\n" "l" "r")))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       (car case))
      (let* ((org-export-use-babel nil)
             (input (org-texmacs--standard-consume 'input))
             (table
              (car
               (org-element-map
                (org-texmacs-input-ast input) 'table #'identity)))
             (query
              (plist-get
               (org-texmacs-input-info input)
               :texmacs-org-query))
             (alignment
              (cdr (assq table (plist-get query :table-alignments)))))
        (should (equal alignment (cdr case)))
        (should-not (string-search "<c>" (prin1-to-string table)))
        (erase-buffer)
        (cl-letf (((symbol-function 'org-export-table-cell-alignment)
                   (lambda (&rest _)
                     (ert-fail "Pure lowering queried Org"))))
          (dotimes (_ 2)
            (let* ((body
                    (org-texmacs-document-body
                     (org-texmacs-document input)))
                   (format (cadr (cadr body)))
                   (commands (butlast (cdr format))))
              (should (eq (car format) 'tformat))
              (should
               (equal
                (mapcar
                 (lambda (command) (nth 6 command)) commands)
                (cdr case))))))))))

(ert-deftest org-texmacs-standard-frontend-table-width-is-rejected ()
  (dolist (cookie '("<10>" "<r10>"))
    (with-temp-buffer
      (org-mode)
      (insert
       (format "| Name | Count |\n| <l> | %s |\n| A | 1 |\n" cookie))
      (let ((org-export-use-babel nil))
        (should-error
         (org-texmacs--standard-consume 'document)
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-standard-source-main-loads-backend-on-use ()
  (org-texmacs-test--menu-fresh-process
   '(progn
      (require 'org-texmacs)
      (should-not (featurep 'ox-texmacs))
      (with-temp-buffer
        (org-mode)
        (insert
         "#+OPTIONS: toc:nil title:nil author:nil date:nil\nBody.\n")
        (let ((calls 0))
          (let ((org-export-before-processing-functions
                 (list (lambda (_) (cl-incf calls)))))
            (cl-letf (((symbol-function
                        'org-texmacs-document-serialize)
                       (lambda (_document)
                         (encode-coding-string "Native" 'us-ascii)))
                      ((symbol-function 'org-texmacs--prepare-buffer)
                       (lambda (&rest _)
                         (ert-fail "Legacy preparation"))))
              (should
               (equal
                "Native"
                (org-texmacs-export-texmacs-from-buffer
                 (current-buffer))))))
          (should (= calls 1))
          (should (featurep 'ox-texmacs)))))))
