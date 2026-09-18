"""Host economy checks. This is a model, not Spectrum execution evidence."""
import hashlib,json,random,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def plan(pop,grain,land,price,trade,feed,plant):
    fed=min(pop,feed//3)
    acres=land+trade
    left=grain-trade*price-feed-plant
    valid=all(isinstance(x,int) for x in (trade,feed,plant)) and feed>=0 and plant>=0 and acres>=0 and left>=0 and plant<=acres and plant<=2*fed
    return {'fed':fed,'acres':acres,'left':left,'ok':valid}

def resolve(pop,grain,land,price,trade,feed,plant,crop):
    assert 2<=crop<=5
    p=plan(pop,grain,land,price,trade,feed,plant);assert p['ok']
    deaths=pop-p['fed'];newcomers=pop//20 if deaths==0 else 0
    return (p['fed']+newcomers,p['left']+plant*crop,p['acres'],deaths,newcomers)

def choose(pop,grain,land,price,policy='expand'):
    trade=0
    if policy!='hold':
        reserve=3*pop if policy=='reserve' else 0
        trade=max(0,min(2*pop-land,(grain-3*pop-land-reserve)//(price+1)))
        if grain<3*pop+land:
            trade=-min(land,max(0,(3*pop+land-grain+price-1)//price))
    acres=land+trade;available=grain-trade*price
    feed=min(3*pop,available);fed=min(pop,feed//3)
    plant=min(acres,2*fed,available-feed)
    return trade,feed,plant

def main():
    checks=[]
    assert plan(60,360,100,8,0,180,100)=={'fed':60,'acres':100,'left':80,'ok':True};checks.append('initial-ledger')
    assert not plan(60,360,100,8,-101,180,0)['ok'];checks.append('cannot-sell-unowned-land')
    assert not plan(60,360,100,8,0,180,101)['ok'];checks.append('land-limits-planting')
    assert not plan(60,360,100,8,0,0,1)['ok'];checks.append('unfed-people-cannot-work')
    assert not plan(60,360,100,8,10,180,110)['ok'];checks.append('combined-budget')
    assert resolve(60,360,100,8,0,180,100,2)==(63,280,100,0,3);checks.append('poor-harvest')
    assert resolve(60,360,100,8,0,179,100,5)==(59,581,100,1,0);checks.append('partial-ration-and-no-newcomers')
    assert resolve(60,360,100,8,-10,180,90,3)==(63,440,90,0,3);checks.append('sale-accounted-once')
    evidence={}
    for policy in ['hold','reserve','expand']:
        runs=[]
        for seed in range(1000):
            rng=random.Random(seed);pop,grain,land=60,360,100;lost=0
            for yr in range(1,11):
                price=rng.randint(6,10);trade,feed,plant=choose(pop,grain,land,price,policy)
                old=(pop,grain,land)
                pop,grain,land,deaths,newcomers=resolve(pop,grain,land,price,trade,feed,plant,rng.randint(2,5));lost+=deaths
                assert pop>=0 and grain>=0 and land>=0
                assert pop==old[0]-deaths+newcomers
                if not pop:break
            runs.append({'seed':seed,'years':yr,'population':pop,'grain':grain,'land':land,'lost':lost})
        evidence[policy]={'runs':1000,'no_deaths':sum(r['lost']==0 for r in runs),'empty':sum(r['population']==0 for r in runs),'median_population':statistics.median(r['population'] for r in runs),'median_grain':statistics.median(r['grain'] for r in runs),'median_land':statistics.median(r['land'] for r in runs),'example':next(r for r in runs if r['lost']==0)}
    checks.append('3000-seeded-policy-runs-preserve-resources')
    assert evidence['expand']['no_deaths']>evidence['hold']['no_deaths'];checks.append('active-management-can-improve-on-defaults')
    out=ROOT/'verification/evidence/model.json'
    out.write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'yearfall.bas').read_bytes()).hexdigest(),'checks':checks,'policies':evidence,'limits':'Python random trials, not Spectrum random sequences, optimal strategy, player success rates or proof that every run is rescuable.'},indent=2)+'\n')
    print(json.dumps(evidence,indent=2));print('PASS',len(checks),'host model groups')
if __name__=='__main__':main()
