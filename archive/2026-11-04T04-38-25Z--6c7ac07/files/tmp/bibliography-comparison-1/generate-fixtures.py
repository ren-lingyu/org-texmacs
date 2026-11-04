"""Recreate exact per-case inputs from cases.json; no new parsers or dependencies."""
from pathlib import Path
import json
f=Path(__file__).with_name('fixtures'); cases=json.loads((f/'cases.json').read_text()); allbib=[]
for c in cases:
 fields={'title':'Properties of '+c['title'],'author':'Doe, Jane and Smith, John and {Research Group}','journaltitle':'Journal Sentinel','date':'2026-11-04','doi':'10.1234/sentinel','url':'https://example.org/paper'}
 if not c.get('date_only'): fields['year']='2026'
 if c.get('journal'): fields['journal']=fields.pop('journaltitle')
 if c.get('unknown'): fields['customfield']='Custom Sentinel'
 bib='@article{'+c['id']+',\n'+',\n'.join(' '+k+'={'+v+'}' for k,v in fields.items())+'\n}\n';(f/(c['id']+'.bib')).write_text(bib)
 if c['id']!='math-case-protected':allbib.append(bib)
 item={'id':c['id'],'type':'article-journal','title':'Properties of '+c['csl'],'author':[{'family':'Doe','given':'Jane'},{'family':'Smith','given':'John'},{'literal':'Research Group'}],'container-title':'Journal Sentinel','issued':{'date-parts':[[2026,11,4]]},'DOI':'10.1234/sentinel','URL':'https://example.org/paper'}
 (f/(c['id']+'.json')).write_text(json.dumps([item],ensure_ascii=False)+'\n')
# This unused historical aggregate remains solely to reproduce the original
# fixtures directory/Nix input hash. Individual .bib files are the actual inputs.
(f/'all.bib').write_text('\n'.join(allbib))
