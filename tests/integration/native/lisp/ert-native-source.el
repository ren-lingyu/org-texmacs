;;; ert-native-source.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'org)
(require 'org-element)
(require 'org-texmacs)
(require 'ox)

(ert-deftest org-texmacs-block-case-native-conversion ()
  (org-texmacs-test--with-worker
   (let (expected-body
         expected-paths
         expected-bytes)
     (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
       (with-temp-buffer
         (org-mode)
         (setq-local org-export-with-author nil)
         (insert
          (format "#+BEGIN_%s\n" type)
          "(concat \"MiXeDSentinel \" (math (frac \"1\" \"2\")))\n"
          "#+END_TEXMACS\n")
         (goto-char (point-min))
         (let* ((state
                 (org-texmacs-test--document-buffer-state
                  (current-buffer)))
                (input (org-texmacs-prepare-buffer (current-buffer)))
                (block
                 (org-element-map
                  (org-texmacs-input-ast input)
                  'special-block
                  #'identity
                  nil
                  t))
                (document (org-texmacs-document input))
                (bytes
                 (org-texmacs-export-texmacs-from-buffer
                  (current-buffer))))
           (should (equal (org-element-property :type block) type))
           (should (= (length (org-texmacs-input-islands input)) 1))
           (if expected-bytes
               (progn
                 (should
                  (equal
                   (org-texmacs-document-body document)
                   expected-body))
                 (should
                  (equal
                   (org-texmacs-document-stm-paths
                    document)
                   expected-paths))
                 (should (equal bytes expected-bytes)))
             (setq
              expected-body (org-texmacs-document-body document)
              expected-paths (org-texmacs-document-stm-paths document)
              expected-bytes bytes)
             (should (string-match-p "MiXeDSentinel" bytes)))
           (should
            (equal
             state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))))))))

;;; ert-native-source.el ends here
