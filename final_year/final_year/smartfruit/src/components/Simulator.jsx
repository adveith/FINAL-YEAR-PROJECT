import { useState, useEffect, useRef } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell,
  RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis
} from 'recharts';

// ─── FRUIT CONFIG ──────────────────────────────────────────────────────────
const FRUITS = ['🍎 Apple','🍌 Banana','🍊 Orange','🍇 Grapes','🍑 Peach','🍓 Strawberry','🥭 Mango','🍋 Lemon','🍍 Pineapple','🥝 Kiwi'];
const CONDITIONS = ['Fresh','Slightly Overripe','Spoiled'];

// ─── JUICE CONFIG ──────────────────────────────────────────────────────────
const JUICE_TYPES = ['🍊 Orange Juice','🍎 Apple Juice','🍋 Lemon Juice','🥭 Mango Juice','🍇 Grape Juice','🍓 Strawberry Juice'];
const JUICE_QUALITIES = ['Fresh & Pure','Diluted','Adulterated','Fermented'];

// ─── LOADING STEPS ─────────────────────────────────────────────────────────
const FRUIT_STEPS = ['⚖️ Measuring weight...','📷 Capturing image...','🔍 YOLOv8 detection...','🧠 CNN ripeness analysis...','⚗️ Gas sensor readings...','🔗 Fusion model inference...','✅ Analysis complete!'];
const JUICE_STEPS = ['⚖️ Estimating volume...','⚗️ pH probe reading...','🍬 Brix refractometer...','💧 Turbidity & conductivity...','🔬 Spectroscopy analysis...','🔗 Fusion model inference...','✅ Analysis complete!'];

// ─── FRUIT NUTRITIONAL DATA ────────────────────────────────────────────────
const FRUIT_NUTRITION = {
  '🍎 Apple':      { cal:52,  carb:13.8, fiber:2.4, sugar:10.4, vitC:4.6,  K:107, Ca:6,  antioxidant:72, gi:36, water:85.6 },
  '🍌 Banana':     { cal:89,  carb:22.8, fiber:2.6, sugar:12.2, vitC:8.7,  K:358, Ca:5,  antioxidant:65, gi:51, water:74.9 },
  '🍊 Orange':     { cal:47,  carb:11.8, fiber:2.4, sugar:9.4,  vitC:53.2, K:181, Ca:40, antioxidant:88, gi:43, water:86.7 },
  '🍇 Grapes':     { cal:69,  carb:18.1, fiber:0.9, sugar:15.5, vitC:10.8, K:191, Ca:10, antioxidant:91, gi:59, water:80.5 },
  '🍑 Peach':      { cal:39,  carb:9.5,  fiber:1.5, sugar:8.4,  vitC:6.6,  K:190, Ca:6,  antioxidant:74, gi:42, water:88.9 },
  '🍓 Strawberry': { cal:32,  carb:7.7,  fiber:2.0, sugar:4.9,  vitC:58.8, K:153, Ca:16, antioxidant:93, gi:40, water:91.0 },
  '🥭 Mango':      { cal:60,  carb:15.0, fiber:1.6, sugar:13.7, vitC:36.4, K:168, Ca:11, antioxidant:79, gi:51, water:83.5 },
  '🍋 Lemon':      { cal:29,  carb:9.3,  fiber:2.8, sugar:2.5,  vitC:53.0, K:138, Ca:26, antioxidant:82, gi:20, water:89.0 },
  '🍍 Pineapple':  { cal:50,  carb:13.1, fiber:1.4, sugar:9.9,  vitC:47.8, K:109, Ca:13, antioxidant:78, gi:59, water:86.0 },
  '🥝 Kiwi':       { cal:61,  carb:14.7, fiber:3.0, sugar:9.0,  vitC:92.7, K:312, Ca:34, antioxidant:86, gi:50, water:83.1 },
};

// ─── FRUIT CONDITION DATA ──────────────────────────────────────────────────
const FRUIT_DATA = {
  Fresh:            { status:'Ripe',     score:[84,95], shelf:'3–5 days',     ethylene:[28,58], co2:[360,500], humidity:[58,72], weight:[140,240], badge:'badge-green' },
  'Slightly Overripe': { status:'Overripe', score:[44,58], shelf:'Consume today', ethylene:[80,155], co2:[510,840], humidity:[72,84], weight:[130,230], badge:'badge-amber' },
  Spoiled:          { status:'Spoiled',  score:[7,20],  shelf:'Discard now',  ethylene:[175,420], co2:[860,1400], humidity:[83,96], weight:[110,210], badge:'badge-red'   },
};

// ─── JUICE NUTRITIONAL DATABASE (per juice type) ───────────────────────────
const JUICE_DB = {
  '🍊 Orange Juice': {
    'Fresh & Pure': { brix:[10.5,12.5], ph:3.8, turb:'Low',    health:[88,96], vitC:50,  cal:45,  fiber:0.2, folate:30, K:200, sugar:8.4,  protein:0.7, antioxidant:85, flavonoids:35, badge:'badge-green', label:'Fresh & Pure',   verdict:'Excellent quality — all biomarkers within ideal range.' },
    'Diluted':      { brix:[4.2,6.8],  ph:4.2, turb:'Low',    health:[50,60], vitC:22,  cal:20,  fiber:0.0, folate:12, K:90,  sugar:3.5,  protein:0.3, antioxidant:45, flavonoids:14, badge:'badge-amber', label:'Diluted',         verdict:'Water adulteration detected — Brix below 8°Bx threshold.' },
    'Adulterated':  { brix:[18.5,22],  ph:3.2, turb:'Medium', health:[18,33], vitC:8,   cal:80,  fiber:0.0, folate:5,  K:45,  sugar:18.5, protein:0.1, antioxidant:20, flavonoids:5,  badge:'badge-red',   label:'Adulterated',     verdict:'Added sugars and artificial dyes detected — not safe for consumption.' },
    'Fermented':    { brix:[8.2,10.8], ph:3.0, turb:'High',   health:[22,38], vitC:15,  cal:38,  fiber:0.0, folate:8,  K:120, sugar:5.2,  protein:0.4, antioxidant:35, flavonoids:20, badge:'badge-red',   label:'Fermented',       verdict:'Alcohol and acetic acid present — microbial spoilage confirmed.' },
  },
  '🍎 Apple Juice': {
    'Fresh & Pure': { brix:[11,14],    ph:3.4, turb:'Low',    health:[82,92], vitC:2,   cal:46,  fiber:0.1, folate:1,  K:101, sugar:10.0, protein:0.1, antioxidant:75, flavonoids:25, badge:'badge-green', label:'Fresh & Pure',   verdict:'Cold-pressed quality — polyphenol levels optimal.' },
    'Diluted':      { brix:[4,6.5],    ph:4.0, turb:'Low',    health:[44,55], vitC:1,   cal:18,  fiber:0.0, folate:0,  K:40,  sugar:4.0,  protein:0.0, antioxidant:35, flavonoids:8,  badge:'badge-amber', label:'Diluted',         verdict:'Significant water dilution — Brix less than 50% of standard.' },
    'Adulterated':  { brix:[19,24],    ph:3.0, turb:'Medium', health:[14,28], vitC:1,   cal:85,  fiber:0.0, folate:0,  K:25,  sugar:20.0, protein:0.0, antioxidant:15, flavonoids:4,  badge:'badge-red',   label:'Adulterated',     verdict:'High-fructose corn syrup signature detected — unsafe.' },
    'Fermented':    { brix:[9,13],     ph:2.8, turb:'High',   health:[18,32], vitC:1,   cal:40,  fiber:0.0, folate:0,  K:85,  sugar:8.0,  protein:0.1, antioxidant:30, flavonoids:12, badge:'badge-red',   label:'Fermented',       verdict:'Ethanol concentration exceeds 0.5% — spoilage detected.' },
  },
  '🍋 Lemon Juice': {
    'Fresh & Pure': { brix:[6,8],      ph:2.2, turb:'Low',    health:[86,94], vitC:38,  cal:22,  fiber:0.3, folate:10, K:138, sugar:2.5,  protein:0.4, antioxidant:82, flavonoids:30, badge:'badge-green', label:'Fresh & Pure',   verdict:'Premium cold-pressed — limonene and hesperidin intact.' },
    'Diluted':      { brix:[2,4],      ph:3.0, turb:'Low',    health:[44,55], vitC:15,  cal:9,   fiber:0.0, folate:4,  K:55,  sugar:1.0,  protein:0.1, antioxidant:38, flavonoids:10, badge:'badge-amber', label:'Diluted',         verdict:'Citric acid below 4% — dilution with water confirmed.' },
    'Adulterated':  { brix:[14,18],    ph:2.0, turb:'Medium', health:[14,26], vitC:8,   cal:60,  fiber:0.0, folate:2,  K:30,  sugar:12.0, protein:0.0, antioxidant:18, flavonoids:4,  badge:'badge-red',   label:'Adulterated',     verdict:'Artificial citric acid and colorants detected.' },
    'Fermented':    { brix:[5,7],      ph:2.5, turb:'High',   health:[18,32], vitC:12,  cal:20,  fiber:0.0, folate:3,  K:100, sugar:2.0,  protein:0.2, antioxidant:28, flavonoids:14, badge:'badge-red',   label:'Fermented',       verdict:'Acetic acid > 1% and yeast growth confirmed.' },
  },
  '🥭 Mango Juice': {
    'Fresh & Pure': { brix:[14,18],    ph:3.5, turb:'Low',    health:[87,95], vitC:27,  cal:60,  fiber:0.5, folate:14, K:168, sugar:13.7, protein:0.4, antioxidant:79, flavonoids:28, badge:'badge-green', label:'Fresh & Pure',   verdict:'Alphonso grade — beta-carotene and mangiferin biomarkers excellent.' },
    'Diluted':      { brix:[5.5,9],    ph:4.0, turb:'Low',    health:[46,58], vitC:10,  cal:22,  fiber:0.1, folate:5,  K:65,  sugar:5.0,  protein:0.1, antioxidant:38, flavonoids:10, badge:'badge-amber', label:'Diluted',         verdict:'Brix drops below 10°Bx — fruit content significantly reduced.' },
    'Adulterated':  { brix:[22,28],    ph:3.0, turb:'Medium', health:[16,28], vitC:5,   cal:95,  fiber:0.0, folate:3,  K:40,  sugar:22.0, protein:0.0, antioxidant:18, flavonoids:4,  badge:'badge-red',   label:'Adulterated',     verdict:'Artificial mango flavour and sucrose overload confirmed.' },
    'Fermented':    { brix:[10,14],    ph:2.8, turb:'High',   health:[20,35], vitC:8,   cal:45,  fiber:0.0, folate:5,  K:100, sugar:9.0,  protein:0.2, antioxidant:28, flavonoids:14, badge:'badge-red',   label:'Fermented',       verdict:'Alcoholic fermentation — ethanol and acetaldehyde detected.' },
  },
  '🍇 Grape Juice': {
    'Fresh & Pure': { brix:[15,20],    ph:3.2, turb:'Low',    health:[85,93], vitC:1,   cal:60,  fiber:0.2, folate:7,  K:191, sugar:14.2, protein:0.4, antioxidant:91, flavonoids:48, badge:'badge-green', label:'Fresh & Pure',   verdict:'Resveratrol and anthocyanin levels outstanding.' },
    'Diluted':      { brix:[6,10],     ph:3.8, turb:'Low',    health:[44,56], vitC:0,   cal:24,  fiber:0.0, folate:3,  K:75,  sugar:5.5,  protein:0.1, antioxidant:44, flavonoids:16, badge:'badge-amber', label:'Diluted',         verdict:'Polyphenol count reduced by >50% — heavy dilution confirmed.' },
    'Adulterated':  { brix:[25,32],    ph:2.8, turb:'Medium', health:[14,26], vitC:0,   cal:100, fiber:0.0, folate:2,  K:50,  sugar:24.0, protein:0.0, antioxidant:20, flavonoids:6,  badge:'badge-red',   label:'Adulterated',     verdict:'Synthetic colouring and invert sugar syrup detected.' },
    'Fermented':    { brix:[11,16],    ph:2.5, turb:'High',   health:[17,32], vitC:0,   cal:50,  fiber:0.0, folate:3,  K:120, sugar:10.0, protein:0.2, antioxidant:35, flavonoids:20, badge:'badge-red',   label:'Fermented',       verdict:'Ethanol >2% — significant yeast activity; not fit for sale.' },
  },
  '🍓 Strawberry Juice': {
    'Fresh & Pure': { brix:[8,11],     ph:3.5, turb:'Low',    health:[89,97], vitC:45,  cal:30,  fiber:0.4, folate:20, K:153, sugar:5.0,  protein:0.5, antioxidant:93, flavonoids:42, badge:'badge-green', label:'Fresh & Pure',   verdict:'Ellagic acid and anthocyanin profile — premium extract.' },
    'Diluted':      { brix:[3,5.5],    ph:4.0, turb:'Low',    health:[48,58], vitC:18,  cal:12,  fiber:0.1, folate:8,  K:60,  sugar:2.0,  protein:0.1, antioxidant:45, flavonoids:14, badge:'badge-amber', label:'Diluted',         verdict:'Colour and Brix inconsistent with fresh strawberry standard.' },
    'Adulterated':  { brix:[16,22],    ph:3.0, turb:'Medium', health:[16,28], vitC:6,   cal:70,  fiber:0.0, folate:5,  K:35,  sugar:16.0, protein:0.0, antioxidant:20, flavonoids:6,  badge:'badge-red',   label:'Adulterated',     verdict:'Carmine dye and fructose syrup adulteration detected.' },
    'Fermented':    { brix:[6,9],      ph:3.0, turb:'High',   health:[20,36], vitC:12,  cal:26,  fiber:0.0, folate:6,  K:90,  sugar:3.5,  protein:0.2, antioxidant:30, flavonoids:18, badge:'badge-red',   label:'Fermented',       verdict:'Yeast metabolites and CO₂ pressure indicate fermentation.' },
  },
};

function rnd(min,max){return Math.round(min+Math.random()*(max-min));}
function rndF(min,max,dp=1){return parseFloat((min+Math.random()*(max-min)).toFixed(dp));}

// ─── GAUGE METER ────────────────────────────────────────────────────────────
function GaugeMeter({value,max=25,color='#39ff14'}){
  const pct=Math.min(1,value/max), r=50, circ=Math.PI*r;
  return(
    <svg width={130} height={75} viewBox="0 0 130 75">
      <path d="M 10 70 A 55 55 0 0 1 120 70" fill="none" stroke="rgba(57,255,20,0.08)" strokeWidth={9} strokeLinecap="round"/>
      <path d="M 10 70 A 55 55 0 0 1 120 70" fill="none" stroke={color} strokeWidth={9} strokeLinecap="round"
        strokeDasharray={circ} strokeDashoffset={circ*(1-pct)} style={{transition:'stroke-dashoffset 1s ease'}}/>
      <text x={65} y={64} textAnchor="middle" fill={color} style={{fontFamily:'Orbitron,monospace',fontSize:15,fontWeight:700}}>{value}°Bx</text>
    </svg>
  );
}

// ─── CIRCLE PROGRESS ────────────────────────────────────────────────────────
function CircleProgress({value}){
  const r=38, circ=2*Math.PI*r, off=circ-(value/100)*circ;
  return(
    <svg width={95} height={95}>
      <circle cx={47} cy={47} r={r} fill="none" stroke="rgba(57,255,20,.08)" strokeWidth={7}/>
      <circle cx={47} cy={47} r={r} fill="none" stroke={value>70?"#39ff14":value>40?"#ffb700":"#ff3b3b"} strokeWidth={7}
        strokeDasharray={circ} strokeDashoffset={off} strokeLinecap="round" transform="rotate(-90 47 47)"
        style={{transition:'stroke-dashoffset 1s ease'}}/>
      <text x={47} y={52} textAnchor="middle" fill={value>70?"#39ff14":value>40?"#ffb700":"#ff3b3b"}
        style={{fontFamily:'Orbitron,monospace',fontSize:14,fontWeight:700}}>{value}</text>
    </svg>
  );
}

// ─── LOADING STEPS ─────────────────────────────────────────────────────────
function LoadingSteps({steps,onDone}){
  const [cur,setCur]=useState(0);
  useEffect(()=>{
    if(cur<steps.length-1){const t=setTimeout(()=>setCur(c=>c+1),550);return()=>clearTimeout(t);}
    else{const t=setTimeout(onDone,400);return()=>clearTimeout(t);}
  },[cur,steps.length,onDone]);
  return(
    <div style={{display:'flex',flexDirection:'column',gap:10,padding:'18px 0'}}>
      {steps.slice(0,cur+1).map((s,i)=>(
        <div key={i} style={{display:'flex',alignItems:'center',gap:10,animation:'fade-in-up .3s ease'}}>
          <div style={{width:7,height:7,borderRadius:'50%',background:i===cur?'var(--accent-green)':'rgba(57,255,20,.35)',flexShrink:0,boxShadow:i===cur?'0 0 8px #39ff14':'none'}}/>
          <span style={{fontFamily:'DM Mono,monospace',fontSize:'.8rem',color:i===cur?'var(--text-primary)':'var(--text-muted)'}}>{s}</span>
        </div>
      ))}
    </div>
  );
}

// ─── FRUIT SIMULATOR ────────────────────────────────────────────────────────
function FruitSim(){
  const [fruit,setFruit]=useState('🍎 Apple');
  const [cond,setCond]=useState('Fresh');
  const [phase,setPhase]=useState('idle');
  const [result,setResult]=useState(null);

  const run=()=>{setPhase('loading');setResult(null);};
  const onDone=()=>{
    const d=FRUIT_DATA[cond];
    const n=FRUIT_NUTRITION[fruit];
    const sensors={
      ethylene:rnd(d.ethylene[0],d.ethylene[1]),
      co2:rnd(d.co2[0],d.co2[1]),
      humidity:rnd(d.humidity[0],d.humidity[1]),
      weight:rnd(d.weight[0],d.weight[1]),
    };
    setResult({...d,score:rnd(d.score[0],d.score[1]),sensors,nutrition:n,
      bars:[
        {name:'Vision',    v:cond==='Fresh'?rnd(62,72):cond==='Slightly Overripe'?rnd(38,50):rnd(24,35)},
        {name:'Gas',       v:cond==='Fresh'?rnd(16,24):cond==='Slightly Overripe'?rnd(34,44):rnd(50,60)},
        {name:'Weight',    v:rnd(10,16)},
      ]
    });
    setPhase('result');
  };

  const radarData=result?[
    {dim:'Colour',    score:cond==='Fresh'?rnd(85,96):cond==='Slightly Overripe'?rnd(45,60):rnd(15,30)},
    {dim:'Texture',   score:cond==='Fresh'?rnd(88,95):cond==='Slightly Overripe'?rnd(40,58):rnd(10,25)},
    {dim:'Aroma',     score:cond==='Fresh'?rnd(80,92):cond==='Slightly Overripe'?rnd(35,52):rnd(8,22)},
    {dim:'Weight',    score:cond==='Fresh'?rnd(78,90):cond==='Slightly Overripe'?rnd(60,75):rnd(40,58)},
    {dim:'Freshness', score:result.score},
    {dim:'Safety',    score:cond==='Fresh'?rnd(90,99):cond==='Slightly Overripe'?rnd(55,70):rnd(5,20)},
  ]:[];

  return(
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:24}} className="sim-grid">
      {/* Left */}
      <div className="card" style={{display:'flex',flexDirection:'column',gap:18}}>
        <div style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--accent-green)'}}>SELECT FRUIT</div>
        <div style={{display:'grid',gridTemplateColumns:'repeat(5,1fr)',gap:6}}>
          {FRUITS.map(f=>(
            <button key={f} onClick={()=>setFruit(f)} style={{
              padding:'7px 3px',borderRadius:7,border:`1px solid ${fruit===f?'var(--accent-green)':'var(--border-glow)'}`,
              background:fruit===f?'rgba(57,255,20,.12)':'var(--bg-panel)',
              color:fruit===f?'var(--accent-green)':'var(--text-muted)',
              cursor:'pointer',fontSize:'.7rem',fontFamily:'DM Mono,monospace',transition:'all .2s',textAlign:'center',
            }}>{f}</button>
          ))}
        </div>
        <div style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--accent-green)'}}>FRESHNESS CONDITION</div>
        <div style={{display:'flex',gap:8}}>
          {CONDITIONS.map(c=>(
            <button key={c} onClick={()=>setCond(c)} style={{
              flex:1,padding:'8px 4px',borderRadius:7,cursor:'pointer',fontSize:'.7rem',
              fontFamily:'DM Mono,monospace',transition:'all .2s',
              border:`1px solid ${cond===c?'var(--accent-green)':'var(--border-glow)'}`,
              background:cond===c?'rgba(57,255,20,.12)':'var(--bg-panel)',
              color:cond===c?'var(--accent-green)':'var(--text-muted)',
            }}>{c}</button>
          ))}
        </div>
        <button className="btn-primary" style={{width:'100%'}} onClick={run} disabled={phase==='loading'}>
          {phase==='loading'?'Analysing…':'▶  Run Analysis'}
        </button>
        {result&&(
          <div style={{background:'var(--bg-panel)',borderRadius:8,padding:14}}>
            <div style={{fontFamily:'Orbitron,monospace',fontSize:'.68rem',color:'var(--accent-green)',marginBottom:10}}>
              NUTRITIONAL PROFILE — per 100g
            </div>
            {[
              ['Calories',  `${result.nutrition.cal} kcal`,'#ffb700'],
              ['Carbs',     `${result.nutrition.carb} g`,  '#39ff14'],
              ['Fiber',     `${result.nutrition.fiber} g`, '#00e5cc'],
              ['Vitamin C', `${result.nutrition.vitC} mg`, '#ff9100'],
              ['Potassium', `${result.nutrition.K} mg`,    '#a855f7'],
              ['GI Index',  `${result.nutrition.gi}`,      '#7a9980'],
            ].map(([k,v,c])=>(
              <div key={k} style={{display:'flex',justifyContent:'space-between',fontSize:'.68rem',borderBottom:'1px solid rgba(57,255,20,.06)',padding:'5px 0'}}>
                <span style={{color:'var(--text-muted)'}}>{k}</span>
                <span style={{color:c||'var(--text-primary)',fontFamily:'Orbitron,monospace'}}>{v}</span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Right */}
      <div className="card" style={{minHeight:320}}>
        {phase==='idle'&&(
          <div style={{display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',height:'100%',gap:12,color:'var(--text-muted)',fontFamily:'DM Mono,monospace',fontSize:'.82rem'}}>
            <span style={{fontSize:'2rem'}}>🍎</span>Select a fruit and condition, then run analysis
          </div>
        )}
        {phase==='loading'&&<LoadingSteps steps={FRUIT_STEPS} onDone={onDone}/>}
        {phase==='result'&&result&&(
          <div style={{display:'flex',flexDirection:'column',gap:14}}>
            <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
              <span style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--accent-green)'}}>ANALYSIS RESULT</span>
              <button onClick={()=>setPhase('idle')} style={{background:'none',border:'none',color:'var(--text-muted)',cursor:'pointer',fontSize:'.78rem'}}>↺ Reset</button>
            </div>

            <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
              {[
                {l:'Fruit',          v:fruit},
                {l:'Ripeness',       v:result.status, badge:result.badge},
                {l:'Freshness Score',v:`${result.score}/100`},
                {l:'Shelf Life',     v:result.shelf},
              ].map(({l,v,badge})=>(
                <div key={l} style={{background:'var(--bg-panel)',borderRadius:7,padding:'9px 11px'}}>
                  <div style={{fontSize:'.62rem',color:'var(--text-muted)',fontFamily:'DM Mono,monospace',marginBottom:4}}>{l}</div>
                  {badge?<span className={`badge ${badge}`}>{v}</span>
                       :<div style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--text-primary)'}}>{v}</div>}
                </div>
              ))}
            </div>

            {/* Sensor readings */}
            <div style={{display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8}}>
              {[
                {l:'Ethylene',  v:`${result.sensors.ethylene}ppm`, c:result.sensors.ethylene>80?'var(--accent-red)':'var(--accent-green)'},
                {l:'CO₂',       v:`${result.sensors.co2}ppm`,      c:result.sensors.co2>600?'var(--accent-red)':'var(--accent-green)'},
                {l:'Humidity',  v:`${result.sensors.humidity}%`,   c:result.sensors.humidity>82?'var(--accent-amber)':'var(--accent-green)'},
                {l:'Weight',    v:`${result.sensors.weight}g`,     c:'var(--accent-teal)'},
              ].map(({l,v,c})=>(
                <div key={l} style={{background:'var(--bg-panel)',borderRadius:7,padding:'8px',textAlign:'center'}}>
                  <div style={{fontSize:'.56rem',color:'var(--text-muted)',marginBottom:3}}>{l}</div>
                  <div style={{fontFamily:'Orbitron,monospace',fontSize:'.72rem',color:c}}>{v}</div>
                </div>
              ))}
            </div>

            {/* Signal weight chart */}
            <div style={{fontFamily:'Orbitron,monospace',fontSize:'.68rem',color:'var(--text-muted)'}}>SENSOR SIGNAL WEIGHTS</div>
            <ResponsiveContainer width="100%" height={90}>
              <BarChart data={result.bars} layout="vertical" margin={{left:0,right:8,top:0,bottom:0}}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(57,255,20,.07)"/>
                <XAxis type="number" tick={{fill:'#7a9980',fontSize:10}} domain={[0,100]}/>
                <YAxis dataKey="name" type="category" tick={{fill:'#7a9980',fontSize:10}} width={48}/>
                <Tooltip contentStyle={{background:'#0c1a0e',border:'1px solid #39ff1440',fontFamily:'DM Mono,monospace',fontSize:11}}/>
                <Bar dataKey="v" radius={4}>
                  {result.bars.map((_,i)=><Cell key={i} fill={['#39ff14','#ffb700','#00e5cc'][i]}/>)}
                </Bar>
              </BarChart>
            </ResponsiveContainer>

            {/* Quality Radar */}
            <div style={{fontFamily:'Orbitron,monospace',fontSize:'.68rem',color:'var(--text-muted)'}}>QUALITY RADAR — 6 DIMENSIONS</div>
            <ResponsiveContainer width="100%" height={200}>
              <RadarChart data={radarData} margin={{top:5,right:20,bottom:5,left:20}}>
                <PolarGrid stroke="rgba(57,255,20,.15)"/>
                <PolarAngleAxis dataKey="dim" tick={{fill:'#7a9980',fontSize:9,fontFamily:'DM Mono'}}/>
                <PolarRadiusAxis domain={[0,100]} tick={{fill:'#4a6650',fontSize:7}} axisLine={false}/>
                <Radar name="Quality" dataKey="score" stroke="var(--accent-green)" fill="var(--accent-green)" fillOpacity={0.2} strokeWidth={1.5}/>
              </RadarChart>
            </ResponsiveContainer>

            {/* Grad-CAM strip */}
            <div style={{borderRadius:7,overflow:'hidden',position:'relative',height:44}}>
              <div style={{position:'absolute',inset:0,background:`linear-gradient(90deg,${cond==='Fresh'?'rgba(57,255,20,.5) 0%,rgba(57,255,20,.7) 50%,rgba(255,183,0,.4) 100%':'rgba(255,183,0,.5) 0%,rgba(255,59,59,.8) 45%,rgba(255,59,59,.4) 100%'})`}}/>
              <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',fontFamily:'DM Mono,monospace',fontSize:'.68rem',color:'#fff',textShadow:'0 1px 3px #000'}}>
                🔥 Grad-CAM: {cond==='Fresh'?'Uniform colour distribution — no anomalies':cond==='Slightly Overripe'?'Softening near equatorial band detected':'Spoilage zones at stem and crevice regions'}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── JUICE SIMULATOR ────────────────────────────────────────────────────────
function JuiceSim(){
  const [juice,setJuice]=useState('🍊 Orange Juice');
  const [quality,setQuality]=useState('Fresh & Pure');
  const [phase,setPhase]=useState('idle');
  const [result,setResult]=useState(null);

  const run=()=>{setPhase('loading');setResult(null);};
  const onDone=()=>{
    const db=JUICE_DB[juice]?.[quality]||JUICE_DB['🍊 Orange Juice']['Fresh & Pure'];
    setResult({...db,brixVal:rndF(db.brix[0],db.brix[1]),healthVal:rnd(db.health[0],db.health[1])});
    setPhase('result');
  };

  const phColor=(ph)=>ph<3.5?'#ff5555':ph>7?'#00e5cc':'#39ff14';
  const phLabel=(ph)=>ph<3.5?'Acidic':ph>7?'Alkaline':'Neutral';

  const getJuiceRadar=(r,q)=>{
    if(!r)return[];
    const purity={'Fresh & Pure':92,'Diluted':48,'Adulterated':14,'Fermented':28}[q]||50;
    return[
      {dim:'Brix Score',    score:Math.round((r.brixVal/25)*100)},
      {dim:'Vitamin C',     score:Math.min(100,r.vitC*1.8)},
      {dim:'Purity',        score:purity},
      {dim:'Antioxidants',  score:r.antioxidant},
      {dim:'pH Balance',    score:r.ph>=3.0&&r.ph<=4.5?78:42},
      {dim:'Health Score',  score:r.healthVal},
    ];
  };

  const radarData=getJuiceRadar(result,quality);

  return(
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:24}} className="sim-grid">
      {/* Left */}
      <div className="card" style={{display:'flex',flexDirection:'column',gap:18}}>
        <div style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--accent-teal)'}}>SELECT JUICE TYPE</div>
        <div style={{display:'grid',gridTemplateColumns:'repeat(2,1fr)',gap:8}}>
          {JUICE_TYPES.map(j=>(
            <button key={j} onClick={()=>setJuice(j)} style={{
              padding:'8px',borderRadius:7,cursor:'pointer',fontSize:'.72rem',
              fontFamily:'DM Mono,monospace',transition:'all .2s',
              border:`1px solid ${juice===j?'var(--accent-teal)':'var(--border-glow)'}`,
              background:juice===j?'rgba(0,229,204,.12)':'var(--bg-panel)',
              color:juice===j?'var(--accent-teal)':'var(--text-muted)',
            }}>{j}</button>
          ))}
        </div>
        <div style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--accent-teal)'}}>SAMPLE QUALITY</div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
          {JUICE_QUALITIES.map(q=>(
            <button key={q} onClick={()=>setQuality(q)} style={{
              padding:'8px',borderRadius:7,cursor:'pointer',fontSize:'.7rem',
              fontFamily:'DM Mono,monospace',transition:'all .2s',
              border:`1px solid ${quality===q?'var(--accent-teal)':'var(--border-glow)'}`,
              background:quality===q?'rgba(0,229,204,.12)':'var(--bg-panel)',
              color:quality===q?'var(--accent-teal)':'var(--text-muted)',
            }}>{q}</button>
          ))}
        </div>
        <button className="btn-outline" style={{width:'100%',borderColor:'var(--accent-teal)',color:'var(--accent-teal)'}}
          onClick={run} disabled={phase==='loading'}>
          {phase==='loading'?'Analysing…':'▶  Run Juice Analysis'}
        </button>

        {result&&(
          <div style={{background:'var(--bg-panel)',borderRadius:8,padding:14}}>
            <div style={{fontFamily:'Orbitron,monospace',fontSize:'.68rem',color:'var(--accent-teal)',marginBottom:10}}>
              DETAILED COMPOSITION
            </div>
            {[
              ['Calories / 100ml', `${result.cal} kcal`,    '#ffb700'],
              ['Vitamin C',        `${result.vitC} mg`,      '#ff9100'],
              ['Potassium',        `${result.K} mg`,         '#39ff14'],
              ['Antioxidant Score',`${result.antioxidant}%`, '#a855f7'],
              ['Flavonoids',       `${result.flavonoids} mg`,'#00e5cc'],
              ['Folate',           `${result.folate} µg`,    '#7a9980'],
              ['Total Sugar',      `${result.sugar} g`,      '#ffb700'],
              ['Protein',          `${result.protein} g`,    '#39ff14'],
            ].map(([k,v,c])=>(
              <div key={k} style={{display:'flex',justifyContent:'space-between',fontSize:'.66rem',borderBottom:'1px solid rgba(0,229,204,.06)',padding:'5px 0'}}>
                <span style={{color:'var(--text-muted)'}}>{k}</span>
                <span style={{color:c,fontFamily:'Orbitron,monospace'}}>{v}</span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Right */}
      <div className="card" style={{minHeight:320}}>
        {phase==='idle'&&(
          <div style={{display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',height:'100%',gap:12,color:'var(--text-muted)',fontFamily:'DM Mono,monospace',fontSize:'.82rem'}}>
            <span style={{fontSize:'2rem'}}>🥤</span>Select juice type and quality, then run analysis
          </div>
        )}
        {phase==='loading'&&<LoadingSteps steps={JUICE_STEPS} onDone={onDone}/>}
        {phase==='result'&&result&&(
          <div style={{display:'flex',flexDirection:'column',gap:14}}>
            <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
              <span style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:'var(--accent-teal)'}}>JUICE RESULT</span>
              <button onClick={()=>setPhase('idle')} style={{background:'none',border:'none',color:'var(--text-muted)',cursor:'pointer',fontSize:'.78rem'}}>↺ Reset</button>
            </div>

            {/* Verdict banner */}
            <div style={{background:result.badge==='badge-green'?'rgba(57,255,20,.08)':result.badge==='badge-amber'?'rgba(255,183,0,.08)':'rgba(255,59,59,.08)',border:`1px solid ${result.badge==='badge-green'?'var(--accent-green)':result.badge==='badge-amber'?'var(--accent-amber)':'var(--accent-red)'}`,borderRadius:8,padding:'10px 14px'}}>
              <div style={{fontFamily:'DM Mono,monospace',fontSize:'.72rem',color:'var(--text-muted)'}}>{juice}</div>
              <div style={{fontFamily:'DM Mono,monospace',fontSize:'.74rem',color:'var(--text-primary)',marginTop:4,lineHeight:1.5}}>{result.verdict}</div>
            </div>

            {/* Gauge + pH + Turbidity + Health */}
            <div style={{display:'flex',gap:14,alignItems:'center',flexWrap:'wrap'}}>
              <div>
                <div style={{fontSize:'.62rem',color:'var(--text-muted)',fontFamily:'DM Mono,monospace',marginBottom:4}}>Brix (Sugar Density)</div>
                <GaugeMeter value={result.brixVal} max={28} color="var(--accent-teal)"/>
              </div>
              <div style={{display:'flex',flexDirection:'column',gap:8}}>
                <div style={{background:'var(--bg-panel)',borderRadius:7,padding:'8px 12px'}}>
                  <div style={{fontSize:'.62rem',color:'var(--text-muted)',fontFamily:'DM Mono,monospace'}}>pH Level</div>
                  <div style={{display:'flex',alignItems:'center',gap:8,marginTop:4}}>
                    <span style={{fontFamily:'Orbitron,monospace',fontSize:'.85rem',color:phColor(result.ph)}}>{result.ph}</span>
                    <span className="badge" style={{background:`${phColor(result.ph)}20`,color:phColor(result.ph),border:`1px solid ${phColor(result.ph)}40`}}>{phLabel(result.ph)}</span>
                  </div>
                </div>
                <div style={{background:'var(--bg-panel)',borderRadius:7,padding:'8px 12px'}}>
                  <div style={{fontSize:'.62rem',color:'var(--text-muted)',fontFamily:'DM Mono,monospace'}}>Turbidity</div>
                  <span className={`badge ${result.turb==='Low'?'badge-green':result.turb==='Medium'?'badge-amber':'badge-red'}`} style={{marginTop:4,display:'inline-block'}}>{result.turb}</span>
                </div>
              </div>
              <div style={{display:'flex',flexDirection:'column',alignItems:'center',gap:4}}>
                <div style={{fontSize:'.62rem',color:'var(--text-muted)',fontFamily:'DM Mono,monospace'}}>Health Score</div>
                <CircleProgress value={result.healthVal}/>
              </div>
            </div>

            {/* Quality label */}
            <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',background:'var(--bg-panel)',borderRadius:7,padding:'10px 14px'}}>
              <span style={{fontSize:'.7rem',color:'var(--text-muted)',fontFamily:'DM Mono,monospace'}}>Quality Classification</span>
              <span className={`badge ${result.badge}`}>{result.label}</span>
            </div>

            {/* Juice Radar Chart */}
            <div style={{fontFamily:'Orbitron,monospace',fontSize:'.68rem',color:'var(--text-muted)'}}>QUALITY RADAR — 6 DIMENSIONS</div>
            <ResponsiveContainer width="100%" height={200}>
              <RadarChart data={radarData} margin={{top:5,right:20,bottom:5,left:20}}>
                <PolarGrid stroke="rgba(0,229,204,.15)"/>
                <PolarAngleAxis dataKey="dim" tick={{fill:'#7a9980',fontSize:9,fontFamily:'DM Mono'}}/>
                <PolarRadiusAxis domain={[0,100]} tick={{fill:'#4a6650',fontSize:7}} axisLine={false}/>
                <Radar name="Quality" dataKey="score" stroke="var(--accent-teal)" fill="var(--accent-teal)" fillOpacity={0.18} strokeWidth={1.5}/>
              </RadarChart>
            </ResponsiveContainer>

            {/* Radar dimension scores */}
            <div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:6}}>
              {radarData.map(d=>(
                <div key={d.dim} style={{textAlign:'center',background:'var(--bg-panel)',borderRadius:6,padding:'6px 4px'}}>
                  <div style={{fontSize:'.55rem',color:'var(--text-muted)'}}>{d.dim}</div>
                  <div style={{fontFamily:'Orbitron,monospace',fontSize:'.78rem',color:d.score>70?'var(--accent-teal)':d.score>40?'var(--accent-amber)':'var(--accent-red)'}}>{d.score}</div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── MAIN EXPORT ────────────────────────────────────────────────────────────
export default function Simulator(){
  const [tab,setTab]=useState('fruit');
  const ref=useRef(null);
  const [visible,setVisible]=useState(false);
  useEffect(()=>{
    const obs=new IntersectionObserver(([e])=>{if(e.isIntersecting)setVisible(true);},{threshold:.1});
    if(ref.current)obs.observe(ref.current);
    return()=>obs.disconnect();
  },[]);

  return(
    <section id="simulator" ref={ref} style={{padding:'80px 24px',background:'rgba(12,26,14,.4)'}}>
      <div className={`section ${visible?'section-visible':'section-hidden'}`} style={{maxWidth:1200,margin:'0 auto'}}>
        <div className="section-label">05 — Interactive Demo</div>
        <h2 className="section-title">INTERACTIVE SIMULATOR</h2>
        <p className="section-sub">Simulate a SmartFruit analysis session — no hardware required.</p>

        <div style={{display:'flex',gap:12,marginBottom:32}}>
          <button className={`tab-btn ${tab==='fruit'?'active':''}`} onClick={()=>setTab('fruit')}>🍎 Fruit Simulator</button>
          <button className={`tab-btn ${tab==='juice'?'active':''}`} onClick={()=>setTab('juice')}
            style={tab==='juice'?{background:'var(--accent-teal)',color:'#050a06',borderColor:'var(--accent-teal)'}:{}}>
            🥤 Juice Simulator
          </button>
        </div>

        <div key={tab} style={{animation:'fade-in-up .3s ease'}}>
          {tab==='fruit'?<FruitSim/>:<JuiceSim/>}
        </div>
      </div>
      <style>{`
        @media(max-width:768px){.sim-grid{grid-template-columns:1fr!important}}
      `}</style>
    </section>
  );
}
