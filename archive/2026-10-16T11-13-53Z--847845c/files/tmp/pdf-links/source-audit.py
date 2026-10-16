import os, pathlib, tarfile, json, hashlib
out=pathlib.Path(os.environ['out'])
paths=['src/Edit/Editor/edit_main.cpp','src/Typeset/Concat/concat_active.cpp','src/Typeset/Bridge/typesetter.cpp','src/Typeset/Bridge/bridge.cpp','src/Plugins/Pdf/pdf_hummus_renderer.cpp','TeXmacs/packages/standard/std-markup.ts','TeXmacs/progs/texmacs/texmacs/tm-print.scm','TeXmacs/progs/texmacs/texmacs/tm-files.scm']
source=pathlib.Path(os.environ['NATIVE_SOURCE']); manifest={}
def save(name,data):
    assert len(data)<1048576
    p=out/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
    manifest[name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}
if source.is_dir():
    for name in paths:
        p=source/name
        if p.is_file(): save(name,p.read_bytes())
else:
    with tarfile.open(source) as archive:
        for member in archive:
            for name in paths:
                if member.isfile() and (member.name==name or member.name.endswith('/'+name)):
                    assert member.size<1048576
                    save(name,archive.extractfile(member).read())
(out/'manifest.json').write_text(json.dumps({'version':os.environ['NATIVE_VERSION'],'source':str(source),'package':os.environ['NATIVE_PACKAGE'],'files':manifest},indent=2)+'\n')
assert 'src/Edit/Editor/edit_main.cpp' in manifest, 'Printing implementation not found'
print(json.dumps(manifest,indent=2))
