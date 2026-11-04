;;; probe.el --- native snippet fidelity experiment -*- lexical-binding: t; -*-
(ert-deftest native-latex-snippet-fidelity ()
  (org-texmacs-test--with-worker
   (let* ((out (file-name-directory (getenv "ORG_TEXMACS_TEST_NAMES_FILE")))
          (script (expand-file-name "run.scm" test-directory))
          (result (expand-file-name "converted.sexp" out))
          process)
     (with-temp-file script
       (insert-file-contents (getenv "ORG_TEXMACS_PROBE_SCHEME"))
       (goto-char (point-max))
       (insert (format "\n(run-probe %s)\n(quit-TeXmacs)\n"
                       (org-texmacs--scheme-string result))))
     (unwind-protect
         (with-temp-buffer
           (setq process
                 (make-process :name "native-latex-probe" :buffer (current-buffer)
                               :connection-type 'pipe :coding 'utf-8-unix :noquery t
                               :sentinel #'ignore
                               :command (list org-texmacs-program "-H" "-s" "-x"
                                              (format "(load %S)" script))))
           (let ((deadline (+ (float-time) 45)))
             (while (and (process-live-p process) (< (float-time) deadline))
               (accept-process-output process 0.1)))
           (with-temp-file (expand-file-name "converter-output.txt" out)
             (insert (with-current-buffer (process-buffer process) (buffer-string))))
           (message "CONVERTER: %s" (buffer-string))
           (should-not (process-live-p process))
           (should (= 0 (process-exit-status process)))
           (should (string-search "LATEX-PROBE-DONE" (buffer-string))))
       (when (and process (process-live-p process)) (delete-process process)))
     (let* ((data (with-temp-buffer (insert-file-contents result) (read (current-buffer))))
            (records (cadr data)))
       (message "CAPS %S" (car data))
       (dolist (record records) (message "CONVERSION %S" record))
       (dolist (op '(convert parse))
         (dolist (key '(cdot paren-cdot greek fraction unicode missing-brace missing-argument unknown missing-dollar macro))
           (let ((first (cl-find-if (lambda (r) (and (= (nth 1 r) 1) (eq (nth 2 r) op) (eq (nth 3 r) key))) records))
                 (second (cl-find-if (lambda (r) (and (= (nth 1 r) 2) (eq (nth 2 r) op) (eq (nth 3 r) key))) records)))
             (message "REPEAT %S %S %S" op key (equal (nthcdr 4 first) (nthcdr 4 second))))))
       (dolist (record records)
         (when (and (eq (car record) 'ok) (= (nth 1 record) 1))
           (let* ((op (nth 2 record)) (key (nth 3 record))
                  (tree (nth 5 record)) (inline tree))
             (while (and (consp inline) (memq (car inline) '(document concat)) (= (length inline) 2))
               (setq inline (cadr inline)))
             (when (and (consp inline) (memq (car inline) '(math with)))
               (let* ((name (format "%s-%s" op key))
                      (doc (org-texmacs--document-create
                            :body `(document (concat "Before " ,inline " after."))
                            :stm-paths '((0 1))))
                      (pdf (expand-file-name (concat name ".pdf") out)))
                 (condition-case err
                     (progn
                       (org-texmacs-document-save doc (expand-file-name (concat name ".tm") out))
                       (org-texmacs-document-save-pdf doc pdf)
                       (should (= 0 (call-process "pdftoppm" nil nil nil "-f" "1" "-singlefile"
                                                  "-scale-to" "1600" "-png" pdf (expand-file-name name out))))
                       (message "RENDERED %s" name))
                   (error (message "RENDER-ERROR %s %S" name err))))))))))))
