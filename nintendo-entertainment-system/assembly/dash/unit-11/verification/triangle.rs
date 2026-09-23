//! Isolated counter experiment using the same APU implementation as Emu198x.
//! No CPU, PPU, NMI or audio-output model is exercised here.
use emu198x_ricoh_apu_2a03::{Apu, ApuRegion};
fn main() {
    println!("region,phase_cycles,linear_reload,high_write,onset_ms,stop_ms,first_limit");
    for (region, name, hz) in [(ApuRegion::Ntsc,"ntsc",1_789_773.0),(ApuRegion::Pal,"pal",1_662_607.0)] {
        for phase in [0, 1000, 8000, 17000] {
            let mut stops=Vec::new();
            for (reload, high) in [(24,0),(96,0),(24,8),(96,8)] {
                let mut apu=Apu::new_with_region(region);
                apu.write(0x4017,0x40); // four-step, frame IRQ inhibited, as in Dash
                for _ in 0..phase { apu.tick(); }
                apu.write(0x4015,4);
                apu.write(0x4008,reload);
                apu.write(0x400a,0x29);
                apu.write(0x400b,high);
                assert_eq!(apu.triangle_linear(),0); // flag, not immediate reload
                assert_eq!(apu.triangle_length(),if high==0 {10} else {254});
                let mut onset=None;
                let mut stopped=None;
                for cycle in 1..1_000_000 {
                    apu.tick();
                    let open=apu.triangle_linear()>0 && apu.triangle_length()>0;
                    if open && onset.is_none(){onset=Some(cycle);}
                    if !open && onset.is_some(){stopped=Some(cycle);break;}
                }
                let onset=onset.expect("gate must open");
                let stop=stopped.expect("one-shot must stop");
                let limit=if apu.triangle_length()==0 {"length"} else {"linear"};
                assert_eq!(limit,if high==0 {"length"} else {"linear"});
                println!("{name},{phase},{reload},{high},{:.3},{:.3},{limit}",f64::from(onset)*1000.0/hz,f64::from(stop)*1000.0/hz);
                stops.push(stop);
            }
            assert_eq!(stops[0],stops[1]); // changing only reload does not lengthen this cue
            assert!(stops[3]>stops[2]*3); // longer length now permits the longer linear gate
        }
        let mut expired=Apu::new_with_region(region);
        expired.write(0x4015,4);expired.write(0x4008,1);expired.write(0x400a,0x29);expired.write(0x400b,8);
        for _ in 0..40_000 {expired.tick();}
        assert_eq!(expired.triangle_linear(),0);
        assert!(expired.triangle_length()>0);
        expired.write(0x4008,0x98); // control cannot recreate a cleared reload flag
        for _ in 0..40_000 {expired.tick();}
        assert_eq!(expired.triangle_linear(),0);
        let mut apu=Apu::new_with_region(region);
        apu.write(0x4015,0);apu.write(0x4008,0x98);apu.write(0x400a,0x29);apu.write(0x400b,0);
        assert_eq!(apu.triangle_period(),41); // disabled writes are not all ignored
        assert_eq!(apu.triangle_length(),0);
        apu.write(0x4015,4);
        assert_eq!(apu.triangle_length(),0); // enabling alone cannot restore length
        apu.write(0x400b,0);
        for _ in 0..1_000_000 {apu.tick();}
        assert_eq!(apu.triangle_length(),10); // control also halts length countdown
        assert_eq!(apu.triangle_linear(),24);
        apu.write(0x4015,0);
        assert_eq!(apu.triangle_length(),0);
    }
}
