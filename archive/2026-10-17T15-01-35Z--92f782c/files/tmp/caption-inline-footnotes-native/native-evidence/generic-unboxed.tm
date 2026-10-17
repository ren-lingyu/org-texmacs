<TeXmacs|2.1.5>

<style|generic>

<\body>
  Before<\footnote>
    BodyNoteOne
  </footnote>

  <with|render-big-figure|<\macro|type|name|fig|cap>
    <arg|fig>

    <render-caption|<arg|type>|<arg|name>|<arg|cap>>
  </macro>|<big-table|<tabular|<tformat|<table|<row|<cell|A>>>>>|CapToken<\footnote>
    NoteToken
  </footnote>>>

  After<\footnote>
    BodyNoteTwo
  </footnote>
</body>