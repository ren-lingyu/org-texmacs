from pathlib import Path
import hashlib,json
base=Path(__file__).parent
p=base/'org-texmacs-worker.scm';s=p.read_text()
assert hashlib.sha256(p.read_bytes()).hexdigest()==json.loads((base/'source-inputs.json').read_text())['org-texmacs-worker.scm']
helpers='''
;; ISOLATED PROBE ONLY: no protocol addition or production source modification.
(define (org-texmacs-probe-mode)
  (string-load (system->url (getenv "PROBE_CONTROL"))))
(define (org-texmacs-probe-log event)
  (let ((port (open-file (getenv "PROBE_EVENTS") "a")))
    (write event port) (newline port) (close-port port)))
(define (org-texmacs-probe-footnote-anchor native)
  (cond
   ((equal? (org-texmacs-probe-mode) "disabled")
    (org-texmacs-probe-log (list 'disabled org-texmacs-render-counter)))
   ((assoc "render-footnote*" (list-ref native 1))
    (org-texmacs-probe-log (list 'explicit-macro-preserved org-texmacs-render-counter)))
   (else
    (let* ((original (tree->stree (get-env-tree "render-footnote*")))
           (count 0)
           (patched
            (letrec ((walk (lambda (node)
              (cond ((and (pair? node) (eq? (car node) 'set-binding)
                          (equal? (cadr node) '(merge "footnote-" (arg "nr"))))
                     (set! count (+ count 1))
                     (list 'concat (list 'label (cadr node)) node))
                    ((pair? node) (map walk node))
                    (else node))))) (walk original))))
      (if (not (= count 1)) (error "Probe unexpected footnote macro"))
      (init-env-tree "render-footnote*" (stree->tree patched))
      (org-texmacs-probe-log (list 'patched org-texmacs-render-counter))
      (if (equal? (org-texmacs-probe-mode) "fail-after-override")
          (error "Probe forced failure after local override"))))))
(define (org-texmacs-probe-session-state)
  (if org-texmacs-session-buffer
      (org-texmacs-with-session-buffer
       (lambda ()
         (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer))
         (update-forced)
         (print-to-file (system->url (string-append (getenv "PROBE_OUT") "/guard.pdf")))
         (list (org-texmacs-native-readback)
               (tree->stree (get-env-tree "render-footnote*")))))
      #f))
'''
s=s.replace('(define (org-texmacs-render-native-pdf native)',helpers+'\n(define (org-texmacs-render-native-pdf-base native)',1)
needle='''                  (print-to-file file)
                  (do ((pass 0 (+ pass 1)))'''
assert needle in s
s=s.replace(needle,'''                  (print-to-file file)
                  (org-texmacs-probe-footnote-anchor native)
                  (do ((pass 0 (+ pass 1)))''',1)
s=s.replace('(lambda () (if buffer (buffer-close buffer)))', '''(lambda () (if buffer (begin (buffer-close buffer)
                  (org-texmacs-probe-log (list 'buffer-closed org-texmacs-render-counter)))))''',1)
s=s.replace('(lambda () (if file (system-remove file)))', '''(lambda () (if file (begin (system-remove file)
                  (if (url-exists? file) (error "Probe leaked temporary PDF"))
                  (org-texmacs-probe-log (list 'file-removed org-texmacs-render-counter)))))''',1)
wrapper='''(define (org-texmacs-render-native-pdf native)
  (let ((before (org-texmacs-probe-session-state)) (result #f) (failure #f))
    (catch #t
      (lambda () (set! result (org-texmacs-render-native-pdf-base native)))
      (lambda args (set! failure args)))
    (if (not (equal? before (org-texmacs-probe-session-state)))
        (error "Probe leaked into existing session"))
    (org-texmacs-probe-log (list 'session-intact org-texmacs-render-counter
                               (if failure 'failed 'ok)))
    (if failure (apply throw failure))
    result))

'''
s=s.replace('(define (org-texmacs-pdf-reply request)',wrapper+'(define (org-texmacs-pdf-reply request)',1)
p.write_text(s)
print('Patched isolated worker only',p)
