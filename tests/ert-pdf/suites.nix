{
  render = [ ./lisp/pdf.el ];
  document = [
    ./lisp/metadata.el
    ./lisp/document.el
    ./lisp/frontend.el
    ./lisp/standard-frontend.el
    ./lisp/standard-source.el
    ./lisp/preprocess.el
    ./lisp/serialization.el
    ./lisp/special-blocks.el
    ./lisp/worker.el
  ];
  inspector = ./python/pdf-links.py;
}
