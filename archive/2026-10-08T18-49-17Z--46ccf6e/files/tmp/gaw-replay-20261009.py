import subprocess, re, json, pathlib, hashlib, sys, os

ROOT = pathlib.Path('/home/lingyu/Projects/org-texmacs')
WT = ROOT / '.agents'
OUT = ROOT / 'tmp/gaw-replay-20261009-v2'
G = '/nix/store/awkhq40rk03w0igiv1xir0qrkl1yxvpg-git-with-svn-2.55.0/bin/git'
GAW = '/nix/store/x3347xlv6ys97myprar1xby7s94g36ph-git-agent-workflow-0.5.0/bin/git-gaw'
BASE = '6035ed7122f1a24c406b6cdaa15c619d1693f4c5'
SOURCE = '6c7a8b3dba88ab7b11a560f3ab2759c5932c95c0'

def git(*args):
    return subprocess.check_output([G, *args], cwd=WT, stderr=subprocess.PIPE, timeout=10)

def tree(h):
    result = {}
    for line in git('ls-tree', '-r', h).decode().splitlines():
        meta, p = line.split('\t', 1)
        mode, typ, oid = meta.split()
        assert mode in ('100644', '100755') and typ == 'blob', (h, p, mode)
        result[p] = (mode, oid)
    return result

cache = {}
def blob(oid):
    if oid not in cache:
        size = int(git('cat-file', '-s', oid))
        assert size <= 1048576, (oid, size)
        cache[oid] = git('cat-file', 'blob', oid)
    return cache[oid]

resolved = {}
def resolve(t):
    if t not in resolved:
        try:
            oid = git('rev-parse', '--verify', t+'^{object}').decode().strip()
            typ = git('cat-file', '-t', oid).decode().strip()
            resolved[t] = (oid, typ)
        except subprocess.CalledProcessError:
            resolved[t] = (None, None)
    return resolved[t]

TOK = re.compile(r'(?<![0-9a-f])[0-9a-f]{7,40}(?![0-9a-f])')
GAW_LOCATORS = {
 'dbc0df9': 'the archive-only checkpoint introducing archive/2026-10-06T08-59-24Z--1a90b7b/MANIFEST.md',
 'ab46bc0': 'the checkpoint introducing memory/backlog.md and completing the bootstrap recovery surface',
 '9d8d351': 'the archive-only checkpoint introducing archive/2026-10-06T14-50-30Z--b09b451/MANIFEST.md',
 '548e6c3': 'the archive-only checkpoint introducing archive/2026-10-06T16-59-25Z--77a2888/MANIFEST.md',
 '84be873': 'the archive-only checkpoint introducing archive/2026-10-06T17-35-50Z--a242eb2/MANIFEST.md',
}
NAMES = {
 '6fd4894':'the v0.1.0 parsing foundation revision',
 'c115285':'the v0.2.0 body and session revision',
 '9988476':'the v0.2.1 interface hardening revision',
 'b7cdefd':'the prepared-input boundary revision',
 '1ed6e49':'the restricted document-context revision',
 '4559482':'the list and container lowering revision',
 '746a798':'the v0.3 metadata and style revision',
 '8c157d0':'the v0.3.0 structured-document release revision',
 '1a90b7b':'the post-v0.3 project baseline',
 'ec72c89':'the ARCH-01 layering refactor revision',
 '880d4e0':'the v0.3.1 release revision',
 'a3ba241':'the local-link resolution revision',
 'b09b451':'the source-location snapshot revision',
 '77a2888':'the local file-link semantics revision',
 'a242eb2':'the named-footnote revision',
 '8e1abf7':'the owned bibliography foundation revision',
 'fe6c435':'the citation and plain bibliography revision',
 '544e246':'the named-table and caption revision',
 'e7377e5':'the native serialization revision',
 '0ee17c4':'the explicit new-file saving revision',
 'ee225ad':'the explicit-source export adapter revision',
 '1ed04db':'the interactive export revision',
 'db33c14':'the native PDF consumer revision',
 'b5100a9':'the PDF semantic regression and citation repair revision',
 'be284dd':'the bounded ox-texmacs frontend revision',
 'b4ee215':'the Org output naming and repeat-export revision',
 'ee3e028':'the subtree export revision',
 '7e6b4e0':'the region export revision',
 'd71204d':'the external configuration override revision',
 '82552db':'the narrowed-source export revision',
 'c26985f':'the v0.4.0 release preparation revision',
 '46ccf6e':'the final HTML coexistence regression revision',
}

rows = [s.split('\t') for s in git('log', '--reverse', '--first-parent', '--format=%H%x09%P%x09%s', SOURCE).decode().splitlines()]
gaw_ids = {h for h, ps, s in rows}
first = {}
references = {}
for h, ps, subject in rows:
    refs = set()
    for p, (mode, oid) in tree(h).items():
        if p.startswith(('memory/', 'skills/')):
            text = blob(oid).decode('utf-8')
            for m in TOK.finditer(text):
                if text[max(0,m.start()-2):m.start()]=='--': continue
                t=m.group(0)
                obj, typ = resolve(t)
                if typ == 'commit' and obj not in gaw_ids:
                    refs.add(obj)
                    first.setdefault(obj, h)
    references[h] = refs

def transform(data, parents):
    text = data.decode('utf-8').replace(' (declared as a non-first parent of this checkpoint)', '')
    def replacement(m):
        t = m.group(1)
        oid, typ = resolve(t)
        if typ != 'commit':
            return m.group(0)
        if oid in gaw_ids:
            assert oid[:7] in GAW_LOCATORS, oid
            return GAW_LOCATORS[oid[:7]]
        if oid in parents:
            return '`'+t+'` (declared as a non-first parent of this checkpoint)'
        assert oid[:7] in NAMES, oid
        return NAMES[oid[:7]]
    # An entire code span is handled separately so descriptive prose is not formatted as an OID.
    text = re.sub(r'`([0-9a-f]{7,40})`', replacement, text)
    def bare(m):
        t=m.group(0)
        if text[max(0,m.start()-2):m.start()]=='--': return t
        # Backtick-surrounded tokens have already received their declaration.
        if m.start()>0 and text[m.start()-1]=='`':
            return t
        oid, typ=resolve(t)
        if typ != 'commit': return t
        if oid in gaw_ids:
            assert oid[:7] in GAW_LOCATORS, oid
            return GAW_LOCATORS[oid[:7]]
        if oid in parents:
            return t+' (declared as a non-first parent of this checkpoint)'
        assert oid[:7] in NAMES, oid
        return NAMES[oid[:7]]
    text = TOK.sub(bare, text)
    text = re.sub(r'(?i)\bcommit (the [^\n`]+? revision)', r'\1', text)
    text = text.replace('Checkpoint the checkpoint ', 'The checkpoint ')
    text = text.replace('checkpoint the archive-only checkpoint ', 'archive-only checkpoint ')
    text = re.sub(r'\b(?:Foundation|Adapter|Saving|Serialization|Named-table|PDF|Semantic|Frontend|Naming/reexport|Subtree|Override|Narrowing|HTML|Project|Metadata|v0\.4\.0 preparation) the ', 'The ', text)
    text = text.replace('The later project the ', 'The later ').replace('The later the ', 'The later ')
    text = text.replace('baseline the ', 'the baseline ').replace('subtree the subtree ', 'the subtree ')
    text = text.replace('is interactive the interactive ', 'is the interactive ')
    text = text.replace('main@the ', 'the ')
    text = text.replace('. the ', '. The ')
    return text.encode('utf-8')

def load_state(h, parents):
    state={}
    for p,(mode,oid) in tree(h).items():
        data=blob(oid)
        if p.startswith(('memory/','skills/')): data=transform(data,parents)
        state[p]=(mode,data)
    return state

def changed(a,b):
    return sorted(p for p in set(a)|set(b) if a.get(p)!=b.get(p))

def save_plan():
    assert not OUT.exists(), OUT
    OUT.mkdir()
    start=next(i for i,r in enumerate(rows) if r[0]==BASE)+1
    previous={p:(mode,blob(oid)) for p,(mode,oid) in tree(BASE).items()}
    plan=[]
    for h,ps,subject in rows[start:]:
        parents=ps.split()[1:]
        original_prev=tree(ps.split()[0]); original_now=tree(h)
        delta=changed(original_prev,original_now)
        archive_only=bool(delta) and all(p.startswith('archive/') for p in delta)
        if archive_only:
            clean={p:(mode,transform(data,[])) if p.startswith(('memory/','skills/')) else (mode,data) for p,(mode,data) in previous.items()}
            if changed(previous,clean):
                plan.append({'source':None,'subject':'memory: retire carried commit identifiers before archive checkpoint','parents':[],'state':clean,'kind':'reference cleanup'})
                previous=clean
            state=dict(previous)
            for p in delta:
                if p in original_now:
                    mode,oid=original_now[p];state[p]=(mode,blob(oid))
                else:state.pop(p,None)
        else:
            for obj in sorted(references[h]):
                if first[obj]==h and obj not in parents:parents.append(obj)
            state=load_state(h,parents)
        plan.append({'source':h,'subject':subject,'parents':parents,'state':state,'kind':'archive' if archive_only else 'summary' if len(parents)>1 else 'record'})
        previous=state
    public=[]
    for i,rec in enumerate(plan):
        d=OUT / str(i).zfill(3);d.mkdir()
        files={}
        for p,(mode,data) in rec.pop('state').items():
            f=d / p;f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(data)
            files[p]={'mode':mode,'sha256':hashlib.sha256(data).hexdigest()}
        rec['directory']=str(d);rec['files']=files;public.append(rec)
    (OUT/'plan.json').write_text(json.dumps(public,indent=2)+'\n')
    print(json.dumps({'records':len(public),'original_records':len(rows)-start,'summaries':[{'source':r['source'],'parents':r['parents']} for r in public if r['kind']=='summary'],'cleanups':sum(r['kind']=='reference cleanup' for r in public)},indent=2))

def verify_plan(plan):
    for i,rec in enumerate(plan):
        parents=set(rec['parents']); d=pathlib.Path(rec['directory'])
        original=tree(rec['source']) if rec['source'] else {}
        for p,meta in rec['files'].items():
            data=(d/p).read_bytes()
            assert hashlib.sha256(data).hexdigest()==meta['sha256'],(i,p,'digest')
            if p.startswith(('memory/','skills/')):
                txt=data.decode()
                for m in TOK.finditer(txt):
                    if txt[max(0,m.start()-2):m.start()]=='--':continue
                    oid,typ=resolve(m.group(0))
                    if typ!='commit':continue
                    assert oid not in gaw_ids,(i,p,'GAW literal',oid)
                    assert oid in parents,(i,p,'missing parent',oid)
                    assert 'declared as a non-first parent of this checkpoint' in txt[m.end():m.end()+85],(i,p,'missing declaration')
            if rec['source']:
                if p.startswith('archive/'):
                    assert data==blob(original[p][1]),(i,p,'archive changed')
                if p.startswith(('memory/','skills/')):
                    before=blob(original[p][1]).decode()
                    assert sorted(re.findall(r'(?<![0-9a-f])[0-9a-f]{64}(?![0-9a-f])',txt))==sorted(re.findall(r'(?<![0-9a-f])[0-9a-f]{64}(?![0-9a-f])',before)),(i,p,'SHA256 changed')
        if rec['kind']=='archive':
            prior=plan[i-1]['files'] if i else {}
            assert all(p.startswith('archive/') for p in changed(prior,rec['files'])),(i,'archive-only')
            assert len(parents)==1,(i,'archive parents')
    print('Verified plan: all literal commit refs have direct parents and declarations; archives and SHA-256 unchanged.',flush=True)

def replay():
    plan=json.loads((OUT/'plan.json').read_text())
    verify_plan(plan)
    assert git('rev-parse','_agents').decode().strip()==SOURCE
    assert git('branch','--show-current').decode().strip()=='_agents_rebuild'
    journal_path=OUT/'journal.json'
    journal=json.loads(journal_path.read_text()) if journal_path.exists() else []
    expected=journal[-1]['new'] if journal else BASE
    assert git('rev-parse','HEAD').decode().strip()==expected
    if git('status','--porcelain'):
        assert len(journal)<len(plan)
        upcoming=plan[len(journal)]
        assert not git('diff','--name-only'), 'unexpected unstaged changes'
        assert not git('ls-files','--others','--exclude-standard'), 'unexpected untracked files'
        entries={}
        for line in git('ls-files','--stage').decode().splitlines():
            meta,p=line.split('\t');mode,oid,stage=meta.split();assert stage=='0'
            entries[p]=(mode,oid)
        assert set(entries)==set(upcoming['files']), 'unexpected staged paths'
        for p,(mode,oid) in entries.items():
            assert hashlib.sha256(blob(oid)).hexdigest()==upcoming['files'][p]['sha256'],(p,'unexpected staged content')
    for i in range(len(journal),len(plan)):
        rec=plan[i]; d=pathlib.Path(rec['directory']);existing=tree('HEAD')
        dirty=[]
        for p in sorted(set(existing)|set(rec['files'])):
            target=WT/p
            assert p=='.gaw/config' or p.startswith(('memory/','skills/','archive/')),p
            assert WT.resolve() in target.resolve().parents,p
            if p not in rec['files']:
                assert target.is_file() and not target.is_symlink(),p
                target.unlink();dirty.append(p)
                continue
            data=(d/p).read_bytes()
            if p in existing and blob(existing[p][1])==data:continue
            assert not target.is_symlink(),p
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(data);dirty.append(p)
        if dirty:git('add','--',*dirty)
        check_paths=[p for p in dirty if not p.startswith('archive/')]
        if check_paths:git('diff','--cached','--check','--',*check_paths)
        subprocess.run([GAW,'check'],cwd=WT,check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=10)
        new=subprocess.check_output([GAW,'commit','--allow-empty','-m',rec['subject'],'--',*rec['parents']],cwd=WT,stderr=subprocess.PIPE,timeout=10).decode().strip()
        actual=git('show','-s','--format=%P',new).decode().strip().split()
        assert actual==[expected]+rec['parents'],(i,actual)
        got=tree(new)
        assert set(got)==set(rec['files']),(i,'paths')
        for p,(mode,oid) in got.items():
            assert mode==rec['files'][p]['mode'],(i,p,'mode')
            assert hashlib.sha256(blob(oid)).hexdigest()==rec['files'][p]['sha256'],(i,p,'content')
        assert not git('status','--porcelain'),(i,'dirty after commit')
        journal.append({'index':i,'source':rec['source'],'new':new,'parents':rec['parents'],'subject':rec['subject']})
        journal_path.write_text(json.dumps(journal,indent=2)+'\n')
        expected=new
        print(str(i+1)+'/'+str(len(plan))+' '+new[:7]+' '+rec['kind']+' '+rec['subject'],flush=True)
    assert git('rev-parse','_agents').decode().strip()==SOURCE

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='replay':replay()
    elif len(sys.argv)>1 and sys.argv[1]=='verify':verify_plan(json.loads((OUT/'plan.json').read_text()))
    else:save_plan()
