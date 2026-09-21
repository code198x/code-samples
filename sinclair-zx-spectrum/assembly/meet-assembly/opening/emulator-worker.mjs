// Own the machine in this worker. At most one tick is in flight; the page
// requests another only after presenting the previous completed frame.
const build=new URL(self.location.href).searchParams.get('build');
let machine=null;
self.onmessage=async({data})=>{
 try {
  if(data.type==='load') {
   const suffix='?build='+encodeURIComponent(build);
   const {default:init,Spectrum}=await import('/vendor/emulator/emu198x_spectrum_web.js'+suffix);
   if(typeof Spectrum.createHeadlessBundled!=='function')throw new Error('The preview server must use the worker-enabled emulator build.');
   await init({module_or_path:new URL('/vendor/emulator/emu198x_spectrum_web_bg.wasm'+suffix,self.location.href)});
   machine=Spectrum.createHeadlessBundled();
   machine.load('tape-1','tape',data.bytes);
   self.postMessage({type:'status',message:'Booting Spectrum…'});
   const start=performance.now();machine.autoload(400);
   self.postMessage({type:'ready',bootMs:performance.now()-start});
  } else if(data.type==='tick' && machine) {
   const start=performance.now();machine.tick(data.elapsed);
   const pc=JSON.parse(machine.query('cpu.pc'));
   const pixels=machine.frameRgba(),size=machine.frameSize();
   self.postMessage({type:'frame',pixels,size:Array.from(size),pc,tickMs:performance.now()-start},[pixels.buffer]);
  }
 }catch(error){self.postMessage({type:'error',message:String(error)});machine?.free();machine=null}
};
