import { useState, useRef, useEffect } from 'react';

const fruitSteps = [
  'Place Fruit', 'System Init', 'Weight Check', 'YOLOv8 Detect',
  'CNN Analysis', 'Gas Sensing', 'Grad-CAM XAI', 'Feature Fusion',
  'Freshness Score', 'Display Output'
];
const juiceSteps = [
  'Insert Sample', 'Volume Est.', 'pH Probe', 'Brix Probe',
  'Turbidity', 'Fusion Model', 'Quality Label', 'Dashboard Sync'
];

const systemLayers = [
  { label: 'Layer 1: Hardware Support', detail: 'Power Management · Lighting Control · Sensor Interface Board', color: '#a855f7' },
  { label: 'Layer 2: Input Layer', detail: 'Fruit Tray Input / Juice Cubby Input', color: '#ffb700' },
  { label: 'Layer 3: Sensing Layer', detail: 'RGB Camera · Load Cell · Gas Sensor · pH Probe · Brix Probe · Turbidity Sensor', color: '#00e5cc' },
  { label: 'Layer 4: NVIDIA Jetson AI Processing', detail: 'YOLOv8 → CNN Analysis → Grad-CAM · Normalized Sensor Features', color: '#39ff14' },
  { label: 'Layer 5: Fusion & Decision Model', detail: 'Feature Fusion → Ensemble Models → Fused Output', color: '#39ff14' },
  { label: 'Layer 6: UI & Explainability', detail: 'XAI View · LCD Display · Web Dashboard', color: '#ffb700' },
  { label: 'Layer 7: Connectivity & Privacy', detail: 'Local Edge Processing · Optional WiFi Sync', color: '#a855f7' },
];

function Pipeline({ steps, activeStep, color }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: 0, margin: '16px 0' }}>
      {steps.map((s, i) => (
        <div key={i} style={{ display: 'flex', alignItems: 'center' }}>
          <div style={{
            padding: '8px 14px', borderRadius: 24,
            fontFamily: 'DM Mono,monospace', fontSize: '0.72rem',
            background: activeStep >= i
              ? (color === 'green' ? 'rgba(57,255,20,0.15)' : 'rgba(0,229,204,0.15)')
              : 'var(--bg-card)',
            border: `1px solid ${activeStep >= i
              ? (color === 'green' ? 'var(--accent-green)' : 'var(--accent-teal)')
              : 'rgba(57,255,20,0.2)'}`,
            color: activeStep >= i
              ? (color === 'green' ? 'var(--accent-green)' : 'var(--accent-teal)')
              : 'var(--text-muted)',
            boxShadow: activeStep === i
              ? `0 0 16px ${color === 'green' ? 'rgba(57,255,20,0.5)' : 'rgba(0,229,204,0.5)'}`
              : 'none',
            transition: 'all 0.3s ease', whiteSpace: 'nowrap',
            transform: activeStep === i ? 'scale(1.05)' : 'scale(1)',
          }}>
            <span style={{ marginRight: 6, opacity: 0.6, fontSize: '0.65rem' }}>{i + 1}</span>
            {s}
          </div>
          {i < steps.length - 1 && (
            <div style={{
              width: 20, height: 2, margin: '0 2px',
              background: activeStep > i
                ? (color === 'green' ? 'var(--accent-green)' : 'var(--accent-teal)')
                : 'rgba(57,255,20,0.2)',
              position: 'relative', transition: 'background 0.3s',
            }}>
              <span style={{ position: 'absolute', right: -4, top: -6, fontSize: '0.6rem', color: activeStep > i ? (color === 'green' ? 'var(--accent-green)' : 'var(--accent-teal)') : 'rgba(57,255,20,0.3)' }}>›</span>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export default function HowItWorks() {
  const [fruitActive, setFruitActive] = useState(-1);
  const [juiceActive, setJuiceActive] = useState(-1);
  const [fruitRunning, setFruitRunning] = useState(false);
  const [juiceRunning, setJuiceRunning] = useState(false);
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  const runPipeline = (steps, setter, setRunning) => {
    setRunning(true);
    setter(-1);
    steps.forEach((_, i) => {
      setTimeout(() => {
        setter(i);
        if (i === steps.length - 1) setRunning(false);
      }, 700 * i);
    });
  };

  return (
    <section id="how-it-works" ref={ref} style={{ padding: '80px 24px' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">03 — Process Flow</div>
        <h2 className="section-title">HOW IT WORKS</h2>
        <p className="section-sub">Two distinct AI pipelines — fruit freshness and juice quality — powered by sensor fusion on NVIDIA Jetson.</p>

        {/* Fruit Pipeline */}
        <div className="card" style={{ marginBottom: 24, overflowX: 'auto' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16, flexWrap: 'wrap', gap: 12 }}>
            <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: 'var(--accent-green)' }}>🍎 FRUIT MODE PIPELINE</div>
            <button className="btn-primary" style={{ padding: '8px 20px', fontSize: '0.78rem' }}
              onClick={() => !fruitRunning && runPipeline(fruitSteps, setFruitActive, setFruitRunning)}
              disabled={fruitRunning}>
              {fruitRunning ? 'Running...' : '▶ Play Animation'}
            </button>
          </div>
          <Pipeline steps={fruitSteps} activeStep={fruitActive} color="green" />
        </div>

        {/* Juice Pipeline */}
        <div className="card" style={{ marginBottom: 48, overflowX: 'auto' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16, flexWrap: 'wrap', gap: 12 }}>
            <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: 'var(--accent-teal)' }}>🥤 JUICE MODE PIPELINE</div>
            <button className="btn-outline" style={{ padding: '8px 20px', fontSize: '0.78rem', borderColor: 'var(--accent-teal)', color: 'var(--accent-teal)' }}
              onClick={() => !juiceRunning && runPipeline(juiceSteps, setJuiceActive, setJuiceRunning)}
              disabled={juiceRunning}>
              {juiceRunning ? 'Running...' : '▶ Play Animation'}
            </button>
          </div>
          <Pipeline steps={juiceSteps} activeStep={juiceActive} color="teal" />
        </div>

        {/* System Architecture Layers */}
        <div className="section-label" style={{ marginBottom: 20 }}>System Architecture — 7 Layers</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 0, maxWidth: 700 }}>
          {systemLayers.map((layer, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
              <div style={{
                width: '100%', padding: '12px 20px',
                background: 'var(--bg-card)',
                border: `1px solid ${layer.color}40`,
                borderLeft: `3px solid ${layer.color}`,
                borderRadius: 8,
              }}>
                <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.78rem', color: layer.color, marginBottom: 4 }}>
                  {layer.label}
                </div>
                <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.72rem', color: 'var(--text-muted)' }}>
                  {layer.detail}
                </div>
              </div>
              {i < systemLayers.length - 1 && (
                <div style={{ width: 2, height: 16, background: `${layer.color}60` }} />
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
