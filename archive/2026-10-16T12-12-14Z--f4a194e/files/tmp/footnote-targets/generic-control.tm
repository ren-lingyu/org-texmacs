<TeXmacs|2.1.5>

<style|generic>

<\body>
  <\table-of-contents|org-texmacs-toc>
    <toc-1|<hlink|1 AlphaDestination|#org-texmacs-toc-1>|<pageref|org-texmacs-toc-1>>

    <toc-1|<hlink|2 OmegaDestination|#org-texmacs-toc-2>|<pageref|org-texmacs-toc-2>>

    <toc-1|<hlink|3 ReferencesDestination|#org-texmacs-toc-3>|<pageref|org-texmacs-toc-3>>
  </table-of-contents>

  <hlink|ExternalLink|https://example.org> and
  <hlink|ForwardToOmega|#org-texmacs-ref-2>.\ 

  <new-page>

  <section|AlphaDestination>

  <label|org-texmacs-toc-1>

  <label|org-texmacs-ref-1>

  AlphaBodySentinel. Group <with-bib|org-texmacs-bib-1|<cite|alpha|beta>>.\ 

  First<footnote|<\surround|<label|org-texmacs-fn-1>|>
    NamedFootnoteBodySentinel.\ 
  </surround>>.\ 

  <new-page>

  <section|OmegaDestination>

  <label|org-texmacs-toc-2>

  <label|org-texmacs-ref-2>

  OmegaBodySentinel. <hlink|BackToAlpha|#org-texmacs-ref-1>.\ 

  AlphaNumber <reference|org-texmacs-ref-1>.
  Again<rsup|<with|font-shape|right|<reference|org-texmacs-fn-1>>>. Repeat
  <with-bib|org-texmacs-bib-1|<cite|alpha>>.\ 

  <new-page>

  <section|ReferencesDestination>

  <label|org-texmacs-toc-3>

  BibSectionSentinel.\ 

  <\bib-list|2>
    <bibitem*|1><label|org-texmacs-bib-1-alpha>Ada Alpha.
    <newblock><with|font-shape|italic|FirstTitleSentinel>. <newblock>Example,
    2024.<newblock>

    <bibitem*|2><label|org-texmacs-bib-1-beta>Bob Beta.
    <newblock><with|font-shape|italic|SecondTitleSentinel>.
    <newblock>Example, 2025.<newblock>
  </bib-list>
</body>