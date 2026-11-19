{ mkPdfCheck, pdfSuites }:
mkPdfCheck {
  name = "org-texmacs-ert-pdf-document";
  testFiles = pdfSuites.document;
}
