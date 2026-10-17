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
        print(p.stdout.decode(errors='replace')[:1800]); print(p.stderr.decode(errors='replace')[:1800])
        raise RuntimeError((name,p.returncode))
    return p.stdout

def quote(s): return json.dumps(str(s))

env=os.environ.copy()
run([os.environ['EMACS_PROGRAM'],'-Q','--batch','--eval',f'(condition-case err (load {quote(export)} nil t) (error (princ (format "PROBE-ELISP-ERROR %S\\n" err)) (kill-emacs 1)))'], 'integration-export', env, 360)
cases=json.loads((out/'exports.json').read_text())
assert len(cases)==44,len(cases)
def reading_order(items):
    lines=[]
    for a in sorted(items,key=lambda a:(a['from'],a['top_rect'][1])):
        if lines and lines[-1][0]['from']==a['from'] and abs(lines[-1][0]['top_rect'][1]-a['top_rect'][1])<3:
            lines[-1].append(a)
        else:lines.append([a])
    return [a for line in lines for a in sorted(line,key=lambda a:a['top_rect'][0])]
rows={}
for case in cases:
    pdf=out/case['file']
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
    assert text.strip(),pdf.name
    rows[pdf.name]={'case':case,'pages':len(reader.pages),
                    'annotations':annotations,'destinations':destinations,
                    'visible_links':visible,'texts':texts,
                    'dangling':[a for a in annotations if a['destination']!='None' and a['target'] is None]}
    print(pdf.name, 'links',len(annotations),'dangling',len(rows[pdf.name]['dangling']),flush=True)
    value=rows[pdf.name]
    if not case['targets']:
        assert not annotations,(pdf.name,annotations)
        continue
    forward=[]
    for a in annotations:
        bodytexts=[t for t in texts if t['page']==a['from'] and any(w in t['text'] for w in set(case['targets']))]
        if bodytexts and a['top_rect'][1] < min(float(t['top'])/1.5 for t in bodytexts)-2:
            forward.append(a)
    forward=reading_order(forward)
    assert len(forward)==len(case['targets']),(pdf.name,forward,case['targets'])
    for index,(a,word) in enumerate(zip(forward,case['targets'])):
        if case['mode']=='disabled' and not (case['name']=='baseline-named' and index==1):
            assert a['target'] is None,(pdf.name,a)
        else:
            target=a['target'];assert target,(pdf.name,a)
            t=next(t for t in texts if word in t['text'] and t['page']==target['page'])
            line=[part for part in texts if part['page']==t['page']
                  and abs(float(part['top'])-float(t['top']))<4]
            left=min(float(part['left']) for part in line)
            right=max(float(part['left'])+float(part['width']) for part in line)
            top=min(float(part['top']) for part in line)
            bottom=max(float(part['top'])+float(part['height']) for part in line)
            height=float(reader.pages[target['page']-1].mediabox.height)
            x=float(target['left'])*1.5;y=(height-float(target['top']))*1.5
            assert top-2<=y<=bottom+2,(pdf.name,target,t)
            # Named-note surround can place a zero-width first-use anchor just
            # beyond the text run. Require the correct body line and at most
            # one line-height of horizontal adjacency, not unrelated page area.
            margin=float(t['height']) if case['name'] in ['named-repeat','baseline-named'] else 3
            assert left-margin<=x<=right+margin,(pdf.name,target,t)
    if case['mode']!='disabled':assert not value['dangling'],pdf.name
# Repeats and failure recovery preserve visible text/layout and target geometry.
for style in ['generic','article']:
    for name in ['minimal','named-repeat','markup','cross-page','no-notes','after-failure']:
        group=[v for v in rows.values() if v['case']['style']==style and v['case']['name']==name]
        assert len(group)==3
        assert all(v['texts']==group[0]['texts'] for v in group), (style,name,'unstable text/layout')
        signature=lambda v:[(a['from'],a['rect'],a['target']) for a in v['annotations']]
        assert all(signature(v)==signature(group[0]) for v in group),(style,name,'unstable target geometry')
# Existing named-note repeat anchor must stay exactly equal to disabled baseline.
for style in ['generic','article']:
    baseline=rows[style+'-baseline-named-0.pdf']
    repeat_target=reading_order(baseline['annotations'])[1]['target']
    for v in rows.values():
        if v['case']['style']==style and v['case']['name']=='named-repeat':
            actual=reading_order(v['annotations'])[1]['target']
            assert actual==repeat_target,(style,'changed existing repeat anchor')
events=(out/'worker-events.sexp').read_text().splitlines()
counts={k:sum(line.startswith('('+k+' ') for line in events) for k in ['patched','disabled','explicit-macro-preserved','buffer-closed','file-removed','session-intact']}
assert counts=={'patched':38,'disabled':6,'explicit-macro-preserved':2,'buffer-closed':46,'file-removed':46,'session-intact':46},counts
assert sum(line.endswith('failed)') for line in events if line.startswith('(session-intact '))==2
(out/'annotations.json').write_text(json.dumps(rows,indent=2)+'\n')
(out/'integration-summary.json').write_text(json.dumps({'pdfs':len(rows),'event_counts':counts,'failure_cleanup':2,'status':'passed'},indent=2)+'\n')
print('PRIVATE-INTEGRATION-OK',len(rows),counts,flush=True)
