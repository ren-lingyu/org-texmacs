;;; signatures.el --- Isolated source signature comparison -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'ox)
(require 'oc)

(defun org-minimum-api--forms (file function)
  (when (> (file-attribute-size (file-attributes file)) 1048576)
    (error "Source exceeds permitted read size: %s" file))
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (condition-case nil
        (while t (funcall function (read (current-buffer))))
      (end-of-file nil))))

(defun org-minimum-api--range (arguments)
  "Return positional arity range, or nil for unsupported argument syntax."
  (when (proper-list-p arguments)
    (let ((required 0) (optional 0) (mode 'required) rest invalid)
      (dolist (argument arguments)
        (cond ((eq argument '&optional) (setq mode 'optional))
              ((memq argument '(&rest &body)) (setq mode 'rest rest t))
              ((and (symbolp argument)
                    (string-prefix-p "&" (symbol-name argument))) (setq invalid t))
              ((eq mode 'required) (cl-incf required))
              ((eq mode 'optional) (cl-incf optional))))
      (unless invalid (cons required (if rest 'many (+ required optional)))))))

(defun org-minimum-api-audit (project source output)
  "Compare actual direct call arities against tagged source and locked runtime.
This is an API/signature audit, not an Org 9.8 runtime compatibility test."
  (let ((definitions (make-hash-table :test 'eq))
        (aliases (make-hash-table :test 'eq))
        (calls (make-hash-table :test 'eq))
        (references (make-hash-table :test 'eq))
        rows)
    ;; Read only the Org Lisp source directory explicitly selected by the flake.
    (dolist (file (directory-files source t "\\.el\\'"))
      (cl-labels ((collect (form)
         (when (consp form)
           (cond
            ((memq (car form) '(progn eval-and-compile eval-when-compile))
             (mapc #'collect (cdr form)))
            ((memq (car form) '(defun defsubst defmacro define-inline cl-defun cl-defmacro))
             (puthash (nth 1 form) (list (nth 2 form) (file-name-nondirectory file)) definitions))
            ((eq (car form) 'defalias)
             (let ((name (nth 1 form)) (target (nth 2 form)))
               (when (and (consp name) (eq (car name) 'quote)
                          (consp target) (memq (car target) '(quote function))
                          (symbolp (cadr target)))
                 (puthash (cadr name) (cadr target) aliases))))))))
        (org-minimum-api--forms file #'collect)))
    (cl-labels
        ((external-p (symbol)
           (and (symbolp symbol) (string-prefix-p "org-" (symbol-name symbol))
                (not (string-prefix-p "org-texmacs" (symbol-name symbol)))))
         (walk (form file)
           (when (consp form)
             (cond
              ((memq (car form) '(quote function))
               (cl-labels ((reference (value)
                             (cond ((external-p value) (puthash value t references))
                                   ((consp value) (reference (car value)) (reference (cdr value))))))
                 (reference (cadr form)))
               (when (and (eq (car form) 'function) (consp (cadr form)))
                 (walk (cadr form) file)))
              (t
               (when (and (external-p (car form)) (proper-list-p form)
                          (fboundp (car form)))
                 (puthash (car form)
                          (cons (list file (1- (length form))) (gethash (car form) calls))
                          calls))
               (dolist (child form) (walk child file))))))
         (definition (symbol seen)
           (unless (memq symbol seen)
             (or (gethash symbol definitions)
                 (let ((alias (gethash symbol aliases)))
                   (when alias (definition alias (cons symbol seen))))))))
      (dolist (file (directory-files project t "\\.el\\'"))
        (org-minimum-api--forms file (lambda (form) (walk form (file-name-nondirectory file)))))
      (maphash
       (lambda (symbol sites)
         (let* ((def (definition symbol nil))
                (range (and def (org-minimum-api--range (car def))))
                (arity (org-minimum-api--range (help-function-arglist symbol t)))
                (counts (sort (delete-dups (mapcar #'cadr sites)) #'<))
                (status
                 (cond ((not def) "UNRESOLVED_SOURCE_DEFINITION")
                       ((not range) "UNRESOLVED_ARGUMENT_SYNTAX")
                       ((cl-some (lambda (count)
                                   (or (< count (car range))
                                       (and (numberp (cdr range)) (> count (cdr range))))) counts)
                        "INCOMPATIBLE_ARITY")
                       (t "ACCEPTED_ARITY"))))
           (push (list symbol status counts (and def (car def)) range arity
                       (and def (cadr def)) (delete-dups (mapcar #'car sites))) rows)))
       calls)
      (setq rows (sort rows (lambda (a b) (string< (symbol-name (car a)) (symbol-name (car b))))))
      (with-temp-file (expand-file-name "signatures.sexp" output)
        (let ((print-length nil) (print-level nil))
          (prin1 (list :baseline-org (org-version) :emacs emacs-version
                       :tagged-source source :columns
                       '(function status call-counts source-arguments source-range baseline-range
                                  source-file project-files)
                       :rows rows :callback-references
                       (sort (hash-table-keys references)
                             (lambda (a b) (string< (symbol-name a) (symbol-name b))))
                       :callback-signatures
                       (cl-loop for name being the hash-keys of references
                                when (fboundp name)
                                collect (list name (help-function-arglist name t))))
                 (current-buffer))))
      (princ (format "BASELINE Emacs %s Org %s; source release_9.8\n" emacs-version (org-version)))
      (dolist (row rows) (princ (format "%S\n" row)))
      (princ (format "SUMMARY %d direct-call interfaces; %d arity conflicts; %d unresolved definitions/syntax\n"
                     (length rows)
                     (cl-count "INCOMPATIBLE_ARITY" rows :key #'cadr :test #'equal)
                     (cl-count-if (lambda (row) (string-prefix-p "UNRESOLVED" (cadr row))) rows)))
      (princ "LIMIT: generated struct accessors/autoloads and callback invocation arities require follow-up; matching arities do not prove behavioral compatibility.\n"))))
