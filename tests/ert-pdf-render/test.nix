{ mkPdfCheck, pdfSuites }:
mkPdfCheck {
  name = "org-texmacs-ert-pdf-render";
  testFiles = pdfSuites.render;
}
