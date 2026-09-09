"""Readable Sinclair BASIC to ROM key entry; spacing is normalised only here."""
import importlib.util,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('volley_entry',ROOT.parents[1]/'volley/prototype/verification/entry.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
class Spectrum(module.Spectrum):
 def text(self,text):
  for c in text:
   if c in {'/':'v','#':'3','?':'c','!':'1'}:self.key('symbol',{'/':'v','#':'3','?':'c','!':'1'}[c])
   else:super().text(c)
 def statement(self,line):
  self.frames(100)
  normal={'PRINT':'p','LET':'l','RUN':'r','SAVE':'s','LOAD':'j','INPUT':'i','CLS':'v','IF':'u','GO TO':'g','GO SUB':'h','RETURN':'y','BORDER':'b','FOR':'f','NEXT':'n','PAUSE':'m','DIM':'d','POKE':'o','NEW':'a'}
  symbol={'THEN':'g','<>':'w','<=':'q','>=':'e','STOP':'a','AT':'i','TO':'f','AND':'y'}
  extended={'INKEY$':'n','LEN':'k','VAL':'j','STR$':'y','INT':'r','RND':'t','USR':'l','CHR$':'u','DATA':'d','READ':'a','RESTORE':'s'}
  shifted={'PAPER':'c','INK':'x','BEEP':'z','BRIGHT':'b','IN':'i'}
  tokens=sorted([*normal,*symbol,*extended,*shifted],key=len,reverse=True)
  pattern=r'"[^"\n]*"|(?:'+'|'.join(re.escape(t) for t in tokens)+r') +'
  line=re.sub(pattern,lambda m:m[0] if m[0].startswith('"') else m[0].rstrip(),line)
  for part in re.split(r'("[^"]*"|'+'|'.join(re.escape(t) for t in tokens)+')',line):
   if part in normal:self.key(normal[part])
   elif part in symbol:self.key('symbol',symbol[part])
   elif part in extended:self.key('caps','symbol');self.key(extended[part])
   elif part in shifted:self.key('caps','symbol');self.key('symbol',shifted[part])
   else:self.text(part)
  self.enter()
  self.frames(100)
