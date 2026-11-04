"""Apply the reviewed catalog offline, preserving resource paths and machine IDs."""
import ast,json,re,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
catalog=json.loads((ROOT/'Godot/datas/locales/en.json').read_text())
def english(s):
    if s.startswith('@question'):return s
    return ''.join(catalog.get(part,part) for part in re.split(r'(#|\\n|\n)',s))
for filename in ('data','questions'):
    tree=ET.parse(ROOT/f'Godot/datas/{filename}.xml')
    for node in tree.iter():
        for key,value in list(node.attrib.items()):
            visible=(node.tag=='message' and key=='value') or key=='ask' or (node.tag=='answer' and key=='value')
            action=(node.tag=='action' and key=='key') or (node.tag=='surface' and key=='action') or (node.tag=='action' and node.attrib.get('type')=='printMsg' and key=='value')
            if visible or action:node.set(key,english(value))
    ET.indent(tree,space='\t')
    tree.write(ROOT/f'Godot/datas/{filename}.en.xml',encoding='utf-8',xml_declaration=True)
for p in (ROOT/'Godot').rglob('*.gd'):
    if 'addons' in p.parts or 'tests' in p.parts or p.name=='english.gd':continue
    def replace(match):
        raw=match.group(1)
        try:s=ast.literal_eval('"'+raw+'"')
        except (ValueError,SyntaxError):return match.group()
        if any(t in s for t in ('res:','://')):return match.group()
        if re.search(r'[ À-ÿ]',s) or '#' in s or s == '»' or s in ('Annuler','Annuler.','Suite...','Menu','Ok'):
            translated=english(s)
            return json.dumps(translated,ensure_ascii=False)
        return match.group()
    p.write_text(re.sub(r'"((?:\\.|[^"\\])*)"',replace,p.read_text()))
