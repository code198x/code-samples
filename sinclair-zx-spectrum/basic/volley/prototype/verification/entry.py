"""Convert readable listings to ROM keystrokes without redundant token spacing."""
import importlib.util
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('spark_entry',ROOT.parents[1]/'bright-spark/opening/verification/completion.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
KEYWORDS=['GO SUB','GO TO','RANDOMIZE','PRINT','LET','RUN','SAVE','LOAD','INPUT','CLS','IF','RETURN','BORDER','FOR','NEXT','PAUSE','THEN','STOP','AT','TO','INKEY$','LEN','VAL','STR$','INT','RND','PAPER','INK','BEEP','BRIGHT']
pattern=re.compile(r'"[^"\n]*"|(?:'+ '|'.join(re.escape(k) for k in sorted(KEYWORDS,key=len,reverse=True))+r') +')
def compact_source(text):
    """Normalise only for ROM entry; never use this output as the displayed listing."""
    return pattern.sub(lambda m:m[0] if m[0].startswith('"') else m[0].rstrip(' '),text)
class Spectrum(module.Spectrum):
    def statement(self,line):
        super().statement(compact_source(line))
