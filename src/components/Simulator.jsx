import { useState, useEffect, useRef } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';

const fruits = ['🍎 Apple','🍌 Banana','🍊 Orange','🍇 Grapes','🍑 Peach','🍓 Strawberry','🥭 Mango','🍋 Lemon'];
const fruitConditions = ['Fresh','Slightly Overripe','Spoiled'];
const juiceTypes = ['🍊 Orange Juice','🍎 Apple Juice','🍋 Lemon Juice','🥭 Mango Juice','🍇 Grape Juice','🍓 Strawberry Juice'];
const juiceQualities = ['Fresh & Pure','Diluted','Adulterated','Fermented'];

const fruitLoadSteps = ['⚖️ Measuring weight...','📷 Capturing image...','🔍 YOLOv8 detection complete','🧠 CNN ripeness analysis...','⚗️ Reading gas sensors...','🔗 Running fusion model...','✅ Analysis complete!'];
const juiceLoadSteps = ['⚖️ Estimating volume...','⚗️ pH probe reading...','🍬 Brix probe reading...','💧 Turbidity & conductivity...','🔗 Running fusion model...','✅ Analysis complete!'];

const fruitData = {
  Fresh: { status:'Ripe', score:[82,92], shelf:'3–5 days', bars:[{name:'Visual',v:68},{name:'Gas',v:20},{name:'Weight',v:12}], badge:'badge-green' },
  'Slightly Overripe': { status:'Overripe', score:[47,57], shelf:'Consume today', bars:[{name:'Visual',v:45},{name:'Gas',v:38},{name:'Weight',v:17}], badge:'badge-amber' },
  Spoiled: { status:'Spoiled', score:[9,19], shelf:'Do not consume', bars:[{name:'Visual',v:30},{name:'Gas',v:55},{name:'Weight',v:15}], badge:'badge-red' },
};

const juiceData = {
  'Fresh & Pure': { brix:[11,14], ph:3.8, turb:'Low', label:'Fresh & Pure', health:[88,95], badge:'badge-green', cals:45, vitC:'High' },
  Diluted: { brix:[4,7], ph:4.2, turb:'Low', label:'Diluted', health:[50,60], badge:'badge-amber', cals:20, vitC:'Low' },
  Adulterated: { brix:[18,22], ph:3.2, turb:'Medium', label:'Adulterated', health:[20,35], badge:'badge-red', cals:80, vitC:'Low' },
  Fermented: { brix:[8,11], ph:3.0, turb:'High', label:'Fermented', health:[25,40], badge:'badge-red', cals:38, vitC:'Medium' },
};

function rnd(min, max) { return Math.round(min + Math.random() * (max - min)); }

function GaugeMeter({ value, max = 25, color = '#39ff14' }) {
  const pct = value / max;
  const r = 50, circ = Math.PI * r;
  const offset = circ - pct * circ;
  return (
    <svg width={120} height={70} viewBox="0 0 120 70">
      <path d="M 10 65 A 50 50 0 0 1 110 65" fill="none" stroke="rgba(57,255,20,0.1)" strokeWidth={8} strokeLinecap="round" />
      <path d="M 10 65 A 50 50 0 0 1 110 65" fill="none" stroke={color} strokeWidth={8}
        strokeLinecap="round"
        strokeDasharray={circ} strokeDashoffset={offset}
        style={{ transition: 'stroke-dashoffset 1s ease' }} />
      <text x={60} y={60} textAnchor="middle" fill={color} style={{ fontFamily: 'Orbitron,monospace', fontSize: 14, fontWeight: 700 }}>
        {value}°Bx
      </text>
    </svg>
  );
}

function CircleProgress({ value }) {
  const r = 36, circ = 2 * Math.PI * r;
  const offset = circ - (value / 100) * circ;
  return (
    <svg width={90} height={90}>
      <circle cx={45} cy={45} r={r} fill="none" stroke="rgba(57,255,20,0.1)" strokeWidth={6} />
      <circle cx={45} cy={45} r={r} fill="none" stroke="#39ff14" strokeWidth={6}
        strokeDasharray={circ} strokeDashoffset={offset}
        strokeLinecap="round" transform="rotate(-90 45 45)"
        style={{ transition: 'stroke-dashoffset 1s ease' }} />
      <text x={45} y={49} textAnchor="middle" fill="#39ff14"
        style={{ fontFamily: 'Orbitron,monospace', fontSize: 13, fontWeight: 700 }}>
        {value}
      </text>
    </svg>
  );
}

function LoadingSteps({ steps, onDone }) {
  const [current, setCurrent] = useState(0);
  useEffect(() => {
    if (current < steps.length - 1) {
      const t = setTimeout(() => setCurrent(c => c + 1), 600);
      return () => clearTimeout(t);
    } else {
      const t = setTimeout(onDone, 500);
      return () => clearTimeout(t);
    }
  }, [current, steps.length, onDone]);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10, padding: '20px 0' }}>
      {steps.slice(0, current + 1).map((s, i) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, animation: 'fade-in-up 0.3s ease' }}>
          <div style={{ width: 8, height: 8, borderRadius: '50%', background: i === current ? 'var(--accent-green)' : 'rgba(57,255,20,0.4)', flexShrink: 0, boxShadow: i === current ? '0 0 8px #39ff14' : 'none' }} />
          <span style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.82rem', color: i === current ? 'var(--text-primary)' : 'var(--text-muted)' }}>{s}</span>
        </div>
      ))}
    </div>
  );
}

/* ─── FRUIT SIMULATOR ─── */
function FruitSim() {
  const [selFruit, setSelFruit] = useState('🍎 Apple');
  const [condition, setCondition] = useState('Fresh');
  const [phase, setPhase] = useState('idle'); // idle | loading | result
  const [result, setResult] = useState(null);

  const runAnalysis = () => {
    setPhase('loading');
    setResult(null);
  };
  const onLoadDone = () => {
    const d = fruitData[condition];
    setResult({ ...d, score: rnd(d.score[0], d.score[1]) });
    setPhase('result');
  };

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 24 }} className="sim-grid">
      {/* Left panel */}
      <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-green)' }}>SELECT FRUIT</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
          {fruits.map(f => (
            <button key={f} onClick={() => setSelFruit(f)} style={{
              padding: '8px 4px', borderRadius: 8, border: `1px solid ${selFruit === f ? 'var(--accent-green)' : 'var(--border-glow)'}`,
              background: selFruit === f ? 'rgba(57,255,20,0.12)' : 'var(--bg-panel)',
              color: selFruit === f ? 'var(--accent-green)' : 'var(--text-muted)',
              cursor: 'pointer', fontSize: '0.75rem', fontFamily: 'DM Mono,monospace',
              transition: 'all 0.2s', textAlign: 'center',
            }}>{f}</button>
          ))}
        </div>

        <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-green)' }}>FRESHNESS CONDITION</div>
        <div style={{ display: 'flex', gap: 8 }}>
          {fruitConditions.map(c => (
            <button key={c} onClick={() => setCondition(c)} style={{
              flex: 1, padding: '8px 4px', borderRadius: 8, cursor: 'pointer', fontSize: '0.72rem',
              fontFamily: 'DM Mono,monospace', transition: 'all 0.2s',
              border: `1px solid ${condition === c ? 'var(--accent-green)' : 'var(--border-glow)'}`,
              background: condition === c ? 'rgba(57,255,20,0.12)' : 'var(--bg-panel)',
              color: condition === c ? 'var(--accent-green)' : 'var(--text-muted)',
            }}>{c}</button>
          ))}
        </div>

        <button className="btn-primary" style={{ width: '100%' }} onClick={runAnalysis} disabled={phase === 'loading'}>
          {phase === 'loading' ? 'Analysing...' : '▶ Run Analysis'}
        </button>
      </div>

      {/* Right panel */}
      <div className="card" style={{ minHeight: 300 }}>
        {phase === 'idle' && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', gap: 12, color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace', fontSize: '0.82rem' }}>
            <span style={{ fontSize: '2rem' }}>🍎</span>
            Select a fruit and run analysis
          </div>
        )}
        {phase === 'loading' && <LoadingSteps steps={fruitLoadSteps} onDone={onLoadDone} />}
        {phase === 'result' && result && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-green)' }}>ANALYSIS RESULT</span>
              <button onClick={() => setPhase('idle')} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '0.8rem' }}>↺ Reset</button>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              {[
                { label: 'Detected Fruit', val: selFruit },
                { label: 'Ripeness Status', val: result.status, badge: result.badge },
                { label: 'Freshness Score', val: `${result.score}/100` },
                { label: 'Shelf Life', val: result.shelf },
              ].map(item => (
                <div key={item.label} style={{ background: 'var(--bg-panel)', borderRadius: 8, padding: '10px 12px' }}>
                  <div style={{ fontSize: '0.68rem', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace', marginBottom: 4 }}>{item.label}</div>
                  {item.badge
                    ? <span className={`badge ${item.badge}`}>{item.val}</span>
                    : <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--text-primary)' }}>{item.val}</div>}
                </div>
              ))}
            </div>

            <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.72rem', color: 'var(--text-muted)', marginTop: 4 }}>SENSOR SIGNAL WEIGHTS</div>
            <ResponsiveContainer width="100%" height={100}>
              <BarChart data={result.bars} layout="vertical" margin={{ left: 0, right: 8, top: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(57,255,20,0.08)" />
                <XAxis type="number" tick={{ fill: '#7a9980', fontSize: 10 }} domain={[0, 100]} />
                <YAxis dataKey="name" type="category" tick={{ fill: '#7a9980', fontSize: 10 }} width={50} />
                <Tooltip contentStyle={{ background: '#0c1a0e', border: '1px solid #39ff1440', fontFamily: 'DM Mono,monospace', fontSize: 11 }} />
                <Bar dataKey="v" radius={4}>
                  {result.bars.map((_, i) => <Cell key={i} fill={['#39ff14','#ffb700','#00e5cc'][i]} />)}
                </Bar>
              </BarChart>
            </ResponsiveContainer>

            {/* Grad-CAM placeholder */}
            <div style={{ borderRadius: 8, overflow: 'hidden', position: 'relative', height: 48 }}>
              <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(90deg, rgba(57,255,20,0.6) 0%, rgba(255,183,0,0.8) 30%, rgba(255,50,50,0.9) 60%, rgba(255,50,50,0.4) 100%)' }} />
              <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'DM Mono,monospace', fontSize: '0.7rem', color: '#fff', textShadow: '0 1px 3px #000' }}>
                🔥 Grad-CAM: Spoilage regions flagged near stem area
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

/* ─── JUICE SIMULATOR ─── */
function JuiceSim() {
  const [selJuice, setSelJuice] = useState('🍊 Orange Juice');
  const [quality, setQuality] = useState('Fresh & Pure');
  const [phase, setPhase] = useState('idle');
  const [result, setResult] = useState(null);

  const runAnalysis = () => { setPhase('loading'); setResult(null); };
  const onLoadDone = () => {
    const d = juiceData[quality];
    setResult({ ...d, brixVal: rnd(d.brix[0], d.brix[1]), healthVal: rnd(d.health[0], d.health[1]) });
    setPhase('result');
  };

  const phColors = { acidic: '#ff5555', neutral: '#39ff14', alkaline: '#00e5cc' };
  const getPh = (ph) => ph < 3.5 ? 'acidic' : ph > 7 ? 'alkaline' : 'neutral';

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 24 }} className="sim-grid">
      {/* Left */}
      <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-teal)' }}>SELECT JUICE</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
          {juiceTypes.map(j => (
            <button key={j} onClick={() => setSelJuice(j)} style={{
              padding: '8px', borderRadius: 8, cursor: 'pointer', fontSize: '0.75rem',
              fontFamily: 'DM Mono,monospace', transition: 'all 0.2s',
              border: `1px solid ${selJuice === j ? 'var(--accent-teal)' : 'var(--border-glow)'}`,
              background: selJuice === j ? 'rgba(0,229,204,0.12)' : 'var(--bg-panel)',
              color: selJuice === j ? 'var(--accent-teal)' : 'var(--text-muted)',
            }}>{j}</button>
          ))}
        </div>

        <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-teal)' }}>SAMPLE QUALITY</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          {juiceQualities.map(q => (
            <button key={q} onClick={() => setQuality(q)} style={{
              padding: '8px', borderRadius: 8, cursor: 'pointer', fontSize: '0.72rem',
              fontFamily: 'DM Mono,monospace', transition: 'all 0.2s',
              border: `1px solid ${quality === q ? 'var(--accent-teal)' : 'var(--border-glow)'}`,
              background: quality === q ? 'rgba(0,229,204,0.12)' : 'var(--bg-panel)',
              color: quality === q ? 'var(--accent-teal)' : 'var(--text-muted)',
            }}>{q}</button>
          ))}
        </div>

        <button className="btn-outline" style={{ width: '100%', borderColor: 'var(--accent-teal)', color: 'var(--accent-teal)' }}
          onClick={runAnalysis} disabled={phase === 'loading'}>
          {phase === 'loading' ? 'Analysing...' : '▶ Run Juice Analysis'}
        </button>
      </div>

      {/* Right */}
      <div className="card" style={{ minHeight: 300 }}>
        {phase === 'idle' && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', gap: 12, color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace', fontSize: '0.82rem' }}>
            <span style={{ fontSize: '2rem' }}>🥤</span>Insert juice sample and run analysis
          </div>
        )}
        {phase === 'loading' && <LoadingSteps steps={juiceLoadSteps} onDone={onLoadDone} />}
        {phase === 'result' && result && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-teal)' }}>JUICE RESULT</span>
              <button onClick={() => setPhase('idle')} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '0.8rem' }}>↺ Reset</button>
            </div>

            <div style={{ display: 'flex', gap: 16, alignItems: 'center', flexWrap: 'wrap' }}>
              <div>
                <div style={{ fontSize: '0.68rem', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace', marginBottom: 4 }}>Brix (Sugar)</div>
                <GaugeMeter value={result.brixVal} color="var(--accent-teal)" />
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                <div style={{ background: 'var(--bg-panel)', borderRadius: 8, padding: '8px 12px' }}>
                  <div style={{ fontSize: '0.68rem', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace' }}>pH Level</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4 }}>
                    <span style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: phColors[getPh(result.ph)] }}>{result.ph}</span>
                    <span className="badge" style={{ background: `${phColors[getPh(result.ph)]}20`, color: phColors[getPh(result.ph)], border: `1px solid ${phColors[getPh(result.ph)]}40` }}>{getPh(result.ph)}</span>
                  </div>
                </div>
                <div style={{ background: 'var(--bg-panel)', borderRadius: 8, padding: '8px 12px' }}>
                  <div style={{ fontSize: '0.68rem', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace' }}>Turbidity</div>
                  <span className={`badge ${result.turb === 'Low' ? 'badge-green' : result.turb === 'Medium' ? 'badge-amber' : 'badge-red'}`} style={{ marginTop: 4, display: 'inline-block' }}>{result.turb}</span>
                </div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                <div style={{ fontSize: '0.68rem', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace' }}>Health Score</div>
                <CircleProgress value={result.healthVal} />
              </div>
            </div>

            <div style={{ background: 'var(--bg-panel)', borderRadius: 8, padding: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                <span style={{ fontSize: '0.72rem', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace' }}>Quality Label</span>
                <span className={`badge ${result.badge}`}>{result.label}</span>
              </div>
              <table style={{ width: '100%', fontFamily: 'DM Mono,monospace', fontSize: '0.72rem', borderCollapse: 'collapse' }}>
                {[
                  ['Est. Calories / 100ml', `${result.cals} kcal`],
                  ['Vitamin C Presence', result.vitC],
                  ['Sample', selJuice],
                ].map(([k, v]) => (
                  <tr key={k} style={{ borderBottom: '1px solid rgba(57,255,20,0.06)' }}>
                    <td style={{ padding: '4px 0', color: 'var(--text-muted)' }}>{k}</td>
                    <td style={{ padding: '4px 0', color: 'var(--text-primary)', textAlign: 'right' }}>{v}</td>
                  </tr>
                ))}
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

/* ─── MAIN EXPORT ─── */
export default function Simulator() {
  const [tab, setTab] = useState('fruit');
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section id="simulator" ref={ref} style={{ padding: '80px 24px', background: 'rgba(12,26,14,0.4)' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">05 — Interactive Demo</div>
        <h2 className="section-title">INTERACTIVE SIMULATOR</h2>
        <p className="section-sub">Simulate a SmartFruit analysis session — no hardware needed.</p>

        <div style={{ display: 'flex', gap: 12, marginBottom: 32 }}>
          <button className={`tab-btn ${tab === 'fruit' ? 'active' : ''}`} onClick={() => setTab('fruit')}>Fruit Simulator</button>
          <button className={`tab-btn ${tab === 'juice' ? 'active' : ''}`}
            onClick={() => setTab('juice')}
            style={tab === 'juice' ? { background: 'var(--accent-teal)', color: '#050a06', borderColor: 'var(--accent-teal)' } : {}}>
            Juice Simulator
          </button>
        </div>

        <div key={tab} style={{ animation: 'fade-in-up 0.3s ease' }}>
          {tab === 'fruit' ? <FruitSim /> : <JuiceSim />}
        </div>
      </div>
      <style>{`
        @media (max-width: 768px) { .sim-grid { grid-template-columns: 1fr !important; } }
      `}</style>
    </section>
  );
}
