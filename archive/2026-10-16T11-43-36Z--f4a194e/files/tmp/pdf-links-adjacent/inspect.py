import json,pathlib,subprocess,sys,xml.etree.ElementTree as ET,re,hashlib
from pypdf import PdfReader
out=pathlib.Path(sys.argv[1]);results={}
markers=['AlphaBodySentinel','OmegaBodySentinel','NamedFootnoteBodySentinel','FirstTitleSentinel','SecondTitleSentinel']
for pdf in sorted(out.glob('*.pdf')):
    raw=subprocess.run(['pdftohtml','-xml','-i','-hidden','-stdout',str(pdf)],capture_output=True,check=True).stdout
    (out/(pdf.stem+'-links.xml')).write_bytes(raw)
    root=ET.fromstring(raw); visible=[];texts=[]
    for page in root.findall('page'):
        texts.append(' '.join(''.join(t.itertext()) for t in page.findall('text')))
        for a in page.iter('a'):
            visible.append({'from':int(page.attrib['number']),'text':''.join(a.itertext()),'href':a.attrib['href']})
    pages={}
    for marker in markers:
        matches=[i+1 for i,text in enumerate(texts) if marker in text]
        assert len(matches)==1,(pdf.name,marker,matches)
        pages[marker]=matches[0]
    reader=PdfReader(pdf);annotations=[]
    for page_number,page in enumerate(reader.pages,1):
        for ref in page.get('/Annots',[]):
            a=ref.get_object()
            if a.get('/Subtype')!='/Link':continue
            dest=a.get('/Dest');target=None
            if dest is not None:
                if dest in reader.named_destinations:
                    target=reader.get_destination_page_number(reader.named_destinations[dest])+1
            annotations.append({'from':page_number,'uri':str(a.get('/A',{}).get('/URI','')),'to':target,'destination':str(dest),'rect':[float(v) for v in a['/Rect']]})
    results[pdf.name]={'pages':len(reader.pages),'marker_pages':pages,'visible_links':visible,'annotations':annotations,'dangling_destinations':[a for a in annotations if a['destination']!='None' and a['to'] is None],'normalized_page_text_sha256':[hashlib.sha256(re.sub(r'\s+',' ',text).strip().encode()).hexdigest() for text in texts]}
assert len(results)==12,len(results)
comparisons={}
for style in ['generic','article']:
    for size in ['short','flow']:
        stem=style+'-'+size
        entries=[results[stem+'-'+route+'.pdf'] for route in ['direct','reload-2','reload-6']]
        comparisons[stem]={key:all(entry[key]==entries[0][key] for entry in entries[1:]) for key in ['pages','marker_pages','normalized_page_text_sha256']}
(out/'annotations.json').write_text(json.dumps(results,indent=2)+'\n')
(out/'convergence.json').write_text(json.dumps(comparisons,indent=2)+'\n')
print(json.dumps({name:{'pages':v['pages'],'links':len(v['annotations']),'dangling':len(v['dangling_destinations']),'markers':v['marker_pages']} for name,v in results.items()},indent=2))
print(json.dumps(comparisons,indent=2))

assert all(all(v.values()) for v in comparisons.values()), comparisons
