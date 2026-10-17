import hashlib, json, os, pathlib, subprocess, sys
import xml.etree.ElementTree as ET
from pypdf import PdfReader

out = pathlib.Path(sys.argv[1])
export = pathlib.Path(sys.argv[2])
program = os.environ['TEXMACS_PROGRAM']

def run(args, name, env=None, seconds=45):
    p = subprocess.run(['timeout', str(seconds)+'s', *map(str,args)], env=env,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out/(name+'.log')).write_bytes(p.stdout + b'\n--- stderr ---\n' + p.stderr)
    if p.returncode:
        print(p.stdout.decode(errors='replace')[-6000:])
        raise RuntimeError((name,p.returncode))
    return p.stdout

def quote(s): return json.dumps(str(s))

env = os.environ.copy()
env['PROBE_OUT'] = str(out)
env['TEXMACS_HOME_PATH'] = str(pathlib.Path(os.environ['TMPDIR'])/'org-config')
run([os.environ['EMACS_PROGRAM'], '-Q', '--batch', '--load', export], 'org-export', env, 120)
rows = {}
for style in ['generic','article']:
    for origin in ['native','org','control']:
        for variant in (['links'] if origin=='control' else ['minimal','paragraphs']):
            name = f'{origin}-{style}-{variant}'
            base = out/name
            if origin=='org':
                setup = f'(load-buffer (system->url {quote(str(base)+".tm")}))'
                end = ''
            else:
                if origin=='control':
                    body = '(document (concat (hlink "JumpControl" "#probe-control")) (new-page) (concat (label "probe-control") "DestinationControl"))'
                elif variant=='minimal':
                    body = '(document (concat "1" (footnote (document "1")) " 2" (footnote (document "2"))))'
                else:
                    body = '(document (concat "1" (footnote (document "1"))) (concat "2" (footnote (document "2"))))'
                (out/(name+'.stree')).write_text(body+'\n')
                setup = f'(let ((b (buffer-new))) (view-new b) (with-buffer b (set-style-list (list "{style}")) (buffer-set-body b (stree->tree \'{body}))'
                end = '))'
            direct = str(base)+'-native.pdf'
            ps = str(base)+'-export.ps'
            printps = str(base)+'-print.ps'
            script = '''(use-modules (utils library cursor) (generic document-edit) (generic document-style))
(begin (catch #t (lambda () '''+setup+f'''
  (do ((pass 0 (+ pass 1))) ((= pass 2))
    (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer))
    (update-forced) (print-to-file (system->url {quote(direct)})))
  (if (not (defined? 'export-postscript)) (error "export-postscript unavailable"))
  (export-postscript (system->url {quote(ps)}))
  (print-to-file (system->url {quote(printps)}))
  {end}
  (display "FORWARD-PROBE-OK\\n"))
  (lambda args (display "FORWARD-PROBE-ERROR ") (write args))) (quit-TeXmacs))
'''
            scm = out/(name+'.scm'); scm.write_text(script)
            nativeenv = os.environ.copy()
            nativeenv['TEXMACS_HOME_PATH'] = str(pathlib.Path(os.environ['TMPDIR'])/(name+'-config'))
            log = run([program,'-H','-s','-x',f'(load {quote(scm)})'],name,nativeenv,40)
            assert b'FORWARD-PROBE-OK' in log, (name, log[-4000:])
            for route in ['export','print']:
                psfile = out/(name+f'-{route}.ps')
                assert psfile.read_bytes().startswith(b'%!PS'), (name,route,'not PostScript')
                run(['ps2pdf','-dSAFER',psfile,out/(name+f'-{route}-ps.pdf')], name+'-'+route+'-ps2pdf')
            pdfs = [out/(name+'-native.pdf'),out/(name+'-export-ps.pdf'),out/(name+'-print-ps.pdf')]
            if origin=='org': pdfs.append(out/(name+'-package.pdf'))
            for pdf in pdfs:
                reader = PdfReader(pdf)
                destinations = {}
                for key,val in reader.named_destinations.items():
                    destinations[str(key)] = {'page':reader.get_destination_page_number(val)+1,
                                              'left':str(val.left),'top':str(val.top)}
                def resolve(dest):
                    if dest is None: return None
                    if isinstance(dest,(str,bytes)):
                        key=dest.decode() if isinstance(dest,bytes) else str(dest)
                        return destinations.get(key) or destinations.get(key.lstrip('/')) or destinations.get('/'+key)
                    if isinstance(dest,list):
                        ref=dest[0]
                        page=next((i+1 for i,p in enumerate(reader.pages)
                                   if p.indirect_reference==ref),None)
                        return {'page':page,'array':str(dest)} if page else None
                    return None
                annotations=[]
                for n,page in enumerate(reader.pages,1):
                    height=float(page.mediabox.height)
                    for ref in page.get('/Annots',[]):
                        a=ref.get_object()
                        if a.get('/Subtype')!='/Link':continue
                        action=a.get('/A',{})
                        dest=a.get('/Dest',action.get('/D'))
                        rect=[float(v) for v in a['/Rect']]
                        annotations.append({'from':n,'destination':str(dest),'target':resolve(dest),
                                            'rect':rect,'top_rect':[rect[0],height-rect[3],rect[2],height-rect[1]],
                                            'uri':str(action.get('/URI',''))})
                xml=run(['pdftohtml','-xml','-i','-hidden','-stdout',pdf],pdf.stem+'-poppler')
                (out/(pdf.stem+'.xml')).write_bytes(xml)
                root=ET.fromstring(xml)
                texts=[{'page':int(p.attrib['number']),**t.attrib,'text':''.join(t.itertext())}
                       for p in root.findall('page') for t in p.findall('text')]
                visible=[{'from':int(p.attrib['number']),'text':''.join(a.itertext()),'href':a.attrib.get('href')}
                         for p in root.findall('page') for a in p.iter('a')]
                text=' '.join(t['text'] for t in texts)
                if origin=='control': assert 'JumpControl' in text and 'DestinationControl' in text
                else: assert '1' in text and '2' in text, (pdf.name,text)
                rows[pdf.name]={'origin':origin,'style':style,'variant':variant,'pages':len(reader.pages),
                                'annotations':annotations,'destinations':destinations,
                                'visible_links':visible,'texts':texts,
                                'dangling':[a for a in annotations if a['destination']!='None' and a['target'] is None]}
                print(pdf.name, 'links',len(annotations),'dangling',len(rows[pdf.name]['dangling']),flush=True)
(out/'annotations.json').write_text(json.dumps(rows,indent=2)+'\n')
assert len(rows)==34,len(rows)
(out/'SUMMARY.txt').write_text('\n'.join(f'{k}: links={len(v["annotations"])} dangling={len(v["dangling"])}' for k,v in rows.items())+'\n')
print('FORWARD-MATRIX-OK',len(rows),flush=True)
