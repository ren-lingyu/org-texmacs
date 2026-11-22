;;; support.el --- Suite-local fixtures -*- lexical-binding: t; -*-

(defun org-texmacs-test--issue13-stage3-graphic-ink (pdf)
  "Find non-text graphic ink near the first Diagram label in PDF.
Rasterize using existing Poppler, excluding the label's word box."
  (let* ((word
          (cl-find
           "Diagram"
           (org-texmacs-test--issue11-pdf-geometry pdf)
           :key #'car
           :test #'equal))
         (box (cdr word))
         (center (/ (+ (nth 1 box) (nth 3 box)) 2.0))
         (count 0)
         xs
         ys)
    (should word)
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (should
       (= 0
          (call-process "pdftoppm"
                        nil
                        t
                        nil
                        "-f"
                        "1"
                        "-singlefile"
                        "-gray"
                        "-r"
                        "72"
                        pdf)))
      (goto-char (point-min))
      (should (looking-at "P5\n\\([0-9]+\\) \\([0-9]+\\)\n255\n"))
      (let ((width (string-to-number (match-string 1)))
            (height (string-to-number (match-string 2)))
            (start (match-end 0)))
        (cl-loop
         for
         y
         from
         (max 0 (floor (- center 20)))
         below
         (min height (ceiling (+ center 20)))
         do
         (cl-loop
          for
          x
          from
          (max 0 (floor (- (car box) 35)))
          below
          (min width (ceiling (+ (nth 2 box) 35)))
          do
          (when (and (not
                      (and (<= (- (car box) 2) x (+ (nth 2 box) 2))
                           (<= (- (nth 1 box) 2)
                               y
                               (+ (nth 3 box) 2))))
                     (< (char-after (+ start (* y width) x)) 128))
            (cl-incf count)
            (push x xs)
            (push y ys))))))
    (should (> count 50))
    (list
     (apply #'min xs)
     (apply #'min ys)
     (apply #'max xs)
     (apply #'max ys))))

;;; support.el ends here
