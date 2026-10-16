import os,sys,pathlib,json,subprocess,hashlib,xml.etree.ElementTree as ET
from pypdf import PdfReader
out=pathlib.Path(sys.argv[1]); program=os.environ['TEXMACS_PROGRAM']; rows={}
bodies={
 'atom':'"BodySentinel."',
 'document':'(document "BodySentinel.")',
 'document-label':'(document (concat (label "probe-note") "BodySentinel."))',
 'surround-label':'(surround (label "probe-note") "" (document (concat "BodySentinel.")))'
}
def quote(s):return json.dumps(str(s))
for style in ['generic','article']:
 for variant in list(bodies)+['package-control']:
  for passes in [2,6]:
   name=f'{style}-{variant}-{passes}';pdf=out/(name+'.pdf'); scm=out/(name+'.scm')
   if variant=='package-control':
    control=sys.argv[2 if style=='generic' else 3]
    setup=f'(load-buffer (system->url {quote(control)}))'
    context_end=''
   else:
    repeat='(concat "Again" (rsup (with "font-shape" "right" (reference "probe-note"))) ".")' if variant.endswith('label') else '"No repeated reference in this control."'
    body=f'(document (concat "First" (footnote {bodies[variant]}) ".") (new-page) {repeat})'
    setup=f'(let ((b (buffer-new))) (view-new b) (with-buffer b (set-style-list (list "{style}")) (buffer-set-body b (stree->tree \'{body}))'
    context_end='))'
   script='(use-modules (utils library cursor) (generic document-edit) (generic document-style))\n'
   script+='(begin (catch #t (lambda () '+setup
   capture=f' (with-output-to-file {quote(out/(name+"-macros.sexp"))} (lambda () (if (defined? \'get-env-tree) (for-each (lambda (key) (display (object->string (list key (tree->stree (get-env-tree key))))) (newline)) \'("footnote" "footnote-text" "footnote-nr" "footnote-sep" "render-footnote" "render-footnote*" "the-footnote" "next-footnote")) (display "get-env-tree unavailable"))))'
   script+=f' (do ((pass 0 (+ pass 1))) ((= pass {passes})) (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer)) (update-forced) (if (= pass 0) {capture} #t) (print-to-file (system->url {quote(pdf)}))) {context_end} (display "FOOTNOTE-OK\\n")) (lambda args (display "FOOTNOTE-ERROR") (write args))) (quit-TeXmacs))\n'
   scm.write_text(script)
   env=os.environ.copy();env['TEXMACS_HOME_PATH']=str(pathlib.Path(os.environ['TMPDIR'])/(name+'-config'))
   p=subprocess.run(['timeout','30s',program,'-H','-s','-x',f'(load {quote(scm)})'],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
   (out/(name+'.log')).write_bytes(p.stdout)
   if p.returncode or b'FOOTNOTE-OK' not in p.stdout or not pdf.exists():
    print(p.stdout.decode(errors='replace'));raise RuntimeError((name,p.returncode))
   xml=subprocess.run(['pdftohtml','-xml','-i','-hidden','-stdout',str(pdf)],capture_output=True,check=True).stdout
   (out/(name+'.xml')).write_bytes(xml);root=ET.fromstring(xml);visible=[]
   text=' '.join(''.join(t.itertext()) for t in root.iter('text'))
   assert 'First' in text and 'BodySentinel' in text,(name,text)
   for page in root.findall('page'):
    for a in page.iter('a'):visible.append({'from':int(page.attrib['number']),'text':''.join(a.itertext()),'href':a.attrib['href']})
   reader=PdfReader(pdf);ann=[];destinations={}
   for key,value in reader.named_destinations.items():
    destinations[str(key)]={'page':reader.get_destination_page_number(value)+1,'top':str(value.top),'left':str(value.left)}
   for number,page in enumerate(reader.pages,1):
    for ref in page.get('/Annots',[]):
     a=ref.get_object()
     if a.get('/Subtype')!='/Link':continue
     dest=a.get('/Dest');ann.append({'from':number,'destination':str(dest),'target':destinations.get(str(dest)),'uri':str(a.get('/A',{}).get('/URI','')),'rect':[float(v) for v in a['/Rect']]})
   rows[name]={'style':style,'variant':variant,'passes':passes,'pages':len(reader.pages),'annotations':ann,'destinations':destinations,'visible_links':visible,'dangling':[a for a in ann if a['destination']!='None' and a['target'] is None]}
   print(name,'annotations',len(ann),'dangling',len(rows[name]['dangling']),flush=True)
(out/'annotations.json').write_text(json.dumps(rows,indent=2)+'\n')
assert len(rows)==20
