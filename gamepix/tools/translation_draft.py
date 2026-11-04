"""Generate an offline English catalog. Requires explicit approval to send text to Google."""
import concurrent.futures, json, re, subprocess, xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
strings=set()
def add(s):
    for part in re.split(r'#|\\n|\n',s):
        if part.strip() and not part.startswith('@question'):strings.add(part)
for name in ('data.xml','questions.xml'):
    for n in ET.parse(ROOT/'Godot/datas'/name).iter():
        for k,v in n.attrib.items():
            if (n.tag=='message' and k=='value') or k=='ask' or (n.tag=='answer' and k=='value') or (n.tag=='action' and n.attrib.get('type')=='printMsg' and k=='value'):add(v)
for p in (ROOT/'Godot').glob('**/*.gd'):
    if 'addons' in p.parts or p.name in ('english.gd','check_game.gd'):continue
    for s in re.findall(r'"((?:\\.|[^"\\])*)"',p.read_text()):
        if not any(x in s for x in ('res:','@question','://')) and (re.search(r'[ À-ÿ]',s) or s in ('Annuler','Menu','Ok')):add(s.replace('\\"','"'))
path=ROOT/'Godot/datas/locales/en.json'
translations=json.loads(path.read_text()) if path.exists() else {}
def translate(s):
    clean=s.replace('falsembreuses','nombreuses').replace('gefalseux','genoux').replace('falsemination','nomination')
    placeholders=re.findall(r'@[a-zA-Z]+',clean)
    for i,p in enumerate(placeholders):clean=clean.replace(p,f'ZXQ{i}ZXQ')
    cmd=['curl','-fsS','--retry','3','--max-time','30','--get','https://translate.googleapis.com/translate_a/single']
    for k,v in dict(client='gtx',sl='fr',tl='en',dt='t',q=clean).items():cmd+=['--data-urlencode',f'{k}={v}']
    result=json.loads(subprocess.check_output(cmd,text=True))
    out=''.join(x[0] for x in result[0] if x[0])
    for i,p in enumerate(placeholders):out=re.sub(f'ZXQ\\s*{i}\\s*ZXQ',p,out,flags=re.I)
    return s,out
missing=sorted(strings-translations.keys());print(f'{len(strings)} entries; {len(missing)} missing',flush=True)
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
    for i,(s,t) in enumerate(pool.map(translate,missing)):
        translations[s]=t
        if i%25==0:
            path.write_text(json.dumps(translations,ensure_ascii=False,indent=2)+'\n');print(f'{i+1}/{len(missing)}',flush=True)
path.write_text(json.dumps(translations,ensure_ascii=False,indent=2)+'\n')
