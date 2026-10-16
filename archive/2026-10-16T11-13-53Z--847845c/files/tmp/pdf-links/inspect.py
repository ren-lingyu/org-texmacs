import sys,pathlib,json,subprocess
from pypdf import PdfReader
out=pathlib.Path(sys.argv[1]); results={}
for pdf in sorted(out.glob('*.pdf')):
    for command,suffix in [(['pdfinfo','-url',str(pdf)],'-urls.txt'),(['pdftohtml','-xml','-i','-hidden','-stdout',str(pdf)],'-links.xml')]:
        result=subprocess.run(command,check=True,capture_output=True)
        (out/(pdf.stem+suffix)).write_bytes(result.stdout)
    reader=PdfReader(pdf); links=[]
    for number,page in enumerate(reader.pages,1):
        for ref in page.get('/Annots',[]):
            annot=ref.get_object()
            if annot.get('/Subtype')=='/Link':
                links.append({'page':number,'rect':[float(v) for v in annot.get('/Rect',[])],'action':str(annot.get('/A')),'destination':str(annot.get('/Dest'))})
    results[pdf.name]={'pages':len(reader.pages),'links':links,'named_destinations':list(reader.named_destinations),'text':'\n'.join(page.extract_text() or '' for page in reader.pages)}
assert len(results)==12, ('Missing expected outcomes',list(results))
(out/'annotations.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps({k:len(v['links']) for k,v in results.items()},indent=2))
