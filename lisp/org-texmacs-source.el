;;; org-texmacs-source.el --- Org source capture for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Read STM source directly from the buffer bounds of an Org special block.
;; Org's parsed children are not the source representation for TeXmacs.
;; Copy source location strings without consulting the filesystem.

;;; Code:

(require 'org-texmacs-core)

(defun org-texmacs--source-copy-path (path)
  "Validate and copy an explicit absolute source PATH, or nil.
Preserve spelling and symlinks.  Do not expand a path, resolve a home
directory, run file handlers or consult the filesystem."
  (when path
    (let ((file-name-handler-alist nil))
      (unless (and (stringp path)
                   (> (length path) 0)
                   (not (string-prefix-p "~" path))
                   (not (string-match-p "\0" path))
                   (file-name-absolute-p path))
        (signal 'org-texmacs-document-error
                '("Expected an explicit absolute source location"))))
    (substring-no-properties path)))

(defun org-texmacs--source-capture-path (path)
  "Capture source buffer PATH, or nil, during preparation.
An absolute path may use a home-directory abbreviation.  Expand that
abbreviation once now; do not defer it to pure lowering or a consumer."
  (when path
    (let ((file-name-handler-alist nil))
      (unless (and (stringp path)
                   (> (length path) 0)
                   (not (string-match-p "\0" path))
                   (file-name-absolute-p path))
        (signal 'org-texmacs-document-error
                '("Expected an absolute source buffer location")))
      (org-texmacs--source-copy-path
       (if (string-prefix-p "~" path)
           (expand-file-name path)
         path)))))

(defun org-texmacs--bibliography-source-snapshot
    (sources resource-base)
  "Copy explicit path-to-text SOURCES using captured RESOURCE-BASE.
Resolve source identities without opening files or running file handlers."
  (unless (proper-list-p sources)
    (signal 'org-texmacs-document-error
            '("Expected bibliography source text alist")))
  (let ((file-name-handler-alist nil)
        paths
        result)
    (dolist (entry sources)
      (unless (and (consp entry)
                   (stringp (car entry))
                   (> (length (car entry)) 0)
                   (not (string-match-p "\0" (car entry)))
                   (stringp (cdr entry)))
        (signal 'org-texmacs-document-error
                '("Invalid bibliography source text")))
      (unless (or (file-name-absolute-p (car entry)) resource-base)
        (signal
         'org-texmacs-document-error
         '("Relative bibliography identity needs resource base")))
      (let ((path
             (org-texmacs--source-copy-path
              (expand-file-name (car entry) resource-base))))
        (when (member path paths)
          (signal 'org-texmacs-document-error
                  '("Duplicate bibliography source identity")))
        (push path paths)
        (push
         (cons path (substring-no-properties (cdr entry))) result)))
    (nreverse result)))

(defun org-texmacs--bibliography-view-copy (view)
  "Own explicit effective bibliography VIEW without discovery or I/O.
VIEW is nil for legacy preparation, or a plist with :document raw-to-absolute
declarations and :sources ordered unique absolute identities."
  (when view
    (unless (and (proper-list-p view)
                 (= (length view) 4)
                 (memq (car view) '(:document :sources))
                 (memq (nth 2 view) '(:document :sources))
                 (not (eq (car view) (nth 2 view)))
                 (proper-list-p (plist-get view :document))
                 (proper-list-p (plist-get view :sources)))
      (signal 'org-texmacs-document-error
              '("Invalid effective bibliography view")))
    (let (sources
          document)
      (dolist (id (plist-get view :sources))
        (setq id (org-texmacs--source-copy-path id))
        (unless (and id (not (member id sources)))
          (signal 'org-texmacs-document-error
                  '("Duplicate effective bibliography identity")))
        (push id sources))
      (dolist (entry (plist-get view :document))
        (unless (and (consp entry)
                     (stringp (car entry))
                     (> (length (car entry)) 0)
                     (stringp (cdr entry)))
          (signal 'org-texmacs-document-error
                  '("Invalid document bibliography association")))
        (let ((id (org-texmacs--source-copy-path (cdr entry))))
          (unless (and (member id sources)
                       (or (not (assoc (car entry) document))
                           (equal
                            id (cdr (assoc (car entry) document)))))
            (signal 'org-texmacs-document-error
                    '("Missing or ambiguous bibliography identity")))
          (push
           (cons (substring-no-properties (car entry)) id) document)))
      (list
       :document (nreverse document)
       :sources (nreverse sources)))))

(defun org-texmacs--block-p (node)
  "Return non-nil when Org NODE is a TeXmacs special block.
Compare its wrapper name without case, preserving NODE and its STM contents."
  (and (consp node)
       (eq (org-element-type node) 'special-block)
       (let ((type (org-element-property :type node)))
         (and (stringp type) (equal (downcase type) "texmacs")))))

(defun org-texmacs--native-body-name-kind (name)
  "Return the native raw-body kind for block NAME, or nil."
  (when (stringp name)
    (cdr
     (assoc
      (downcase name)
      '(("texmacs" . texmacs)
        ("equation" . equation)
        ("equation*" . equation*))))))

(defun org-texmacs--native-body-kind (node)
  "Return the native raw-body kind of NODE, or nil."
  (when (and (consp node) (eq (org-element-type node) 'special-block))
    (org-texmacs--native-body-name-kind
     (org-element-property :type node))))

(defun org-texmacs--native-body-blocks (ast)
  "Collect outermost native-body blocks in AST order without entering them."
  (let (blocks)
    (cl-labels
     ((walk
       (node)
       (when (consp node)
         (if (org-texmacs--native-body-kind node)
             (push node blocks)
           (mapc #'walk (org-element-contents node))))))
     (walk ast))
    (nreverse blocks)))

(defun org-texmacs--native-body-check (node)
  "Validate equation NODE parameters without reading its source."
  (when (memq
         (org-texmacs--native-body-kind node) '(equation equation*))
    (let ((parameters (org-element-property :parameters node)))
      (unless (or (null parameters)
                  (and (stringp parameters)
                       (string-match-p
                        "\\`[ \t\r\n]*\\'" parameters)))
        (signal 'org-texmacs-document-error
                '("Equation parameters are unsupported"))))))

(defun org-texmacs--native-body-source (block)
  "Read raw native BLOCK contents in the accessible source buffer."
  (unless (org-texmacs--native-body-kind block)
    (signal 'org-texmacs-error '("Expected a native-body block")))
  (let ((begin (org-element-property :contents-begin block))
        (end (org-element-property :contents-end block)))
    (cond
     ((and (null begin) (null end))
      "")
     ((and (integerp begin)
           (integerp end)
           (<= (point-min) begin end (point-max)))
      (buffer-substring-no-properties begin end))
     (t
      (signal 'org-texmacs-error
              '("Invalid native-body contents bounds"))))))

(defun org-texmacs--figure-table-kind (node)
  "Return the structural figure/table kind of NODE, or nil."
  (when (and (consp node) (eq (org-element-type node) 'special-block))
    (let ((type (org-element-property :type node)))
      (when (stringp type)
        (cdr
         (assoc
          (downcase type)
          '(("figure" . figure)
            ("figure*" . figure*)
            ("table" . table)
            ("table*" . table*))))))))

(defun org-texmacs--figure-table-blank-p (node)
  "Recognize metadata-free whitespace paragraphs used for spacing."
  (and (eq (org-element-type node) 'paragraph)
       (not (org-element-property :name node))
       (not (org-element-property :caption node))
       (not (org-element-property :texmacs-affiliated-keywords node))
       (let (attribute)
         (org-element-properties-mapc
          (lambda (key value _owner)
            (when (and value
                       (string-prefix-p ":attr_" (symbol-name key)))
              (setq attribute t)))
          node)
         (not attribute))
       (let ((begin (org-element-property :begin node))
             (post (org-element-property :post-affiliated node)))
         (or (null post) (equal begin post)))
       (org-element-contents node)
       (cl-every
        (lambda (text)
          (and (stringp text)
               (string-match-p "\\`[ \t\r\n]*\\'" text)))
        (org-element-contents node))))

(defun org-texmacs--source-affiliated-keys (node)
  "Capture NODE's affiliated keyword names from the current private source."
  (let ((begin (org-element-property :begin node))
        (post (org-element-property :post-affiliated node))
        keys)
    (when (and (integerp begin) (integerp post))
      (save-excursion
        (goto-char begin)
        (while (< (point) post)
          (push
           (if (looking-at
                "[ \t]*#\\+\\([[:alnum:]_]+\\)\\(?:\\[[^\n]*\\]\\)?:")
               (upcase (match-string-no-properties 1))
             "INVALID")
           keys)
          (forward-line 1))))
    (nreverse keys)))

(defun org-texmacs--figure-table-node-shape (node)
  "Describe NODE using owned data, without source reads or node references."
  (list
   (org-element-type node)
   (org-element-property :type node)
   (org-element-property :parameters node)
   (org-element-property :begin node)
   (org-element-property :post-affiliated node)
   (org-element-property :contents-begin node)
   (org-element-property :contents-end node)
   (org-element-property :texmacs-source-end node)
   (org-element-property :texmacs-affiliated-keywords node)))

(defun org-texmacs--source-caption-declarations (node)
  "Capture NODE's Org-recognized affiliated caption declaration evidence.
Each entry is (EXPLICIT-SHORT LONG-TEXT).  Only inspect the affiliated range
provided by Org; do not parse inline caption syntax."
  (let ((begin (org-element-property :begin node))
        (post (org-element-property :post-affiliated node))
        rows
        (case-fold-search t))
    (when (and (integerp begin) (integerp post))
      (save-excursion
        (goto-char begin)
        (while (< (point) post)
          (when
              (looking-at
               "[ \t]*#\\+CAPTION\\(\\[[^\n]*\\]\\)?:[ \t]*\\(.*\\)$")
            (push (list
                   (and (match-beginning 1) t)
                   (match-string-no-properties 2))
                  rows))
          (forward-line 1))))
    (nreverse rows)))

(defun org-texmacs--figure-table-source-shapes
    (ast &optional originals rebind)
  "Capture wrapper evidence in AST, or REBIND ORIGINALS after reparse.
Read the fixed private source.
Defer errors until retained wrappers are lowered.
Return an alist keyed by complete semantic source ranges."
  (let (result)
    (cl-labels
     ((describe
       (node)
       (org-element-put-property
        node
        :texmacs-affiliated-keywords
        (org-texmacs--source-affiliated-keys node))
       (org-element-put-property
        node
        :texmacs-source-end
        (save-excursion
          (goto-char (org-element-property :end node))
          (forward-line
           (- (or (org-element-property :post-blank node) 0)))
          (point))))
      (walk
       (node)
       (when (and (consp node)
                  (not (org-texmacs--native-body-kind node)))
         (when-let* ((kind (org-texmacs--figure-table-kind node)))
           (describe node)
           (dolist (child (org-element-contents node))
             (describe child))
           (let* ((key
                   (list
                    kind
                    (org-element-property :begin node)
                    (org-element-property :post-affiliated node)
                    (org-element-property :texmacs-source-end node)))
                  (matches
                   (and originals
                        (cl-remove-if-not
                         (lambda (entry)
                           (equal (car entry) key))
                         originals)))
                  (shape
                   (if rebind
                       (if (= (length matches) 1)
                           (cdar matches)
                         '(missing))
                     (list
                      key
                      (mapcar
                       #'org-texmacs--figure-table-node-shape
                       (cl-remove-if
                        #'org-texmacs--figure-table-blank-p
                        (org-element-contents node)))))))
             (org-element-put-property
              node
              :texmacs-figure-table-source shape)
             (push (cons key shape) result)))
         (mapc #'walk (org-element-contents node)))))
     (walk ast))
    (nreverse result)))

(defun org-texmacs--name-source-shapes
    (ast &optional originals rebind)
  "Capture affiliated NAME/caption evidence, or REBIND ORIGINALS after reparse.
Read only the private preparation buffer.
Defer validation to retained nodes."
  (let (result)
    (cl-labels
     ((walk
       (node)
       (when (consp node)
         (when (eq (org-element-type node) 'special-block)
           (let* ((begin (org-element-property :begin node))
                  (post (org-element-property :post-affiliated node))
                  (end
                   (save-excursion
                     (goto-char (org-element-property :end node))
                     (forward-line
                      (- (or (org-element-property :post-blank node)
                             0)))
                     (point)))
                  (key
                   (list
                    (org-element-property :type node) begin post end))
                  (keys (org-texmacs--source-affiliated-keys node))
                  (matching
                   (and rebind
                        (cl-remove-if-not
                         (lambda (entry)
                           (equal key (car entry)))
                         originals)))
                  (proof
                   (if rebind
                       (if (= (length matching) 1)
                           (cdar matching)
                         '(missing))
                     (list
                      key (org-element-property :name node) keys
                      (org-texmacs--source-caption-declarations
                       node)))))
             (org-element-put-property
              node
              :texmacs-affiliated-keywords keys)
             (org-element-put-property node :texmacs-source-end end)
             (org-element-put-property
              node
              :texmacs-name-source (copy-tree proof t))
             (push (cons key proof) result)))
         (unless (org-texmacs--native-body-kind node)
           (mapc #'walk (org-element-contents node))))))
     (walk ast))
    (nreverse result)))

(defun org-texmacs--block-source (block)
  "Return the raw STM source of TeXmacs special BLOCK as a string.

BLOCK must be an up-to-date Org element from the current buffer, with its
contents accessible under the current narrowing.  Read its contents bounds
without consulting parsed children or changing the buffer or point.  Strip
text properties but preserve whitespace.  An empty block has no contents
bounds in Org and yields an empty string.

Signal `org-texmacs-error' for a non-TeXmacs block or invalid contents bounds.
Bounds checks cannot detect a stale element or an element from another buffer;
the caller is responsible for supplying the correct element."
  (unless (org-texmacs--block-p block)
    (signal 'org-texmacs-error '("Expected a TeXmacs special block")))
  (org-texmacs--native-body-source block))

(provide 'org-texmacs-source)

;;; org-texmacs-source.el ends here
