"""Local review server; reuse the website's installed WASM packages."""
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import tempfile
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--website',type=Path,required=True);p.add_argument('--emulator-package',type=Path);p.add_argument('--port',type=int,default=1987);a=p.parse_args()
emulator_package=a.emulator_package or a.website/'node_modules/@emu198x/zx-spectrum'
if not (emulator_package/'emu198x_spectrum_web.js').exists() or 'createHeadlessBundled' not in (emulator_package/'emu198x_spectrum_web.js').read_text():
 p.error('This preview needs the worker-enabled emulator build; pass --emulator-package /path/to/pkg')
build=hashlib.sha256(b''.join((emulator_package/name).read_bytes() for name in ('emu198x_spectrum_web.js','emu198x_spectrum_web_bg.wasm'))).hexdigest()
# Bundle the same editor enhancement used by the authored Astro lessons.
editor_temp=tempfile.TemporaryDirectory(prefix='meet-assembly-editor-')
editor_root=Path(editor_temp.name)
entry=editor_root/'entry.mjs'
entry.write_text('import {highlightAssemblyEditor} from '+json.dumps(str((a.website/'src/lib/assembly-editor.ts').resolve()))+'; const source=document.querySelector("#source"); source.classList.add("sandbox-source"); highlightAssemblyEditor(source).catch(console.error);')
subprocess.run([str((a.website/'node_modules/.bin/esbuild').resolve()),str(entry),'--bundle','--format=esm','--outfile='+str(editor_root/'editor.js')],check=True,cwd=a.website)
class Handler(SimpleHTTPRequestHandler):
 def end_headers(self):
  self.send_header('Cache-Control','no-store')
  super().end_headers()
 def do_GET(self):
  if self.path.split('?',1)[0]=='/emulator-build.json':
   body=json.dumps({'build':build}).encode()
   self.send_response(200);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(body)));self.end_headers();self.wfile.write(body)
  else:super().do_GET()
 def translate_path(self,path):
  path=path.split('?',1)[0]
  roots={'/vendor/editor/':editor_root,'/vendor/assembler/':a.website/'node_modules/@asm198x/z80','/vendor/emulator/':(a.emulator_package or a.website/'node_modules/@emu198x/zx-spectrum')}
  for prefix,root in roots.items():
   if path.startswith(prefix):
    file=(root/path[len(prefix):]).resolve();return str(file if file.is_relative_to(root.resolve()) else ROOT/'missing')
  return str(ROOT/'preview.html') if path=='/' else super().translate_path(path)
 def __init__(self,*args,**kwargs):super().__init__(*args,directory=ROOT,**kwargs)
print(f'Preview: http://127.0.0.1:{a.port}',flush=True)
ThreadingHTTPServer(('127.0.0.1',a.port),Handler).serve_forever()
