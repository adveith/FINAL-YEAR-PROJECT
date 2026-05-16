import { useState, useEffect, useRef } from 'react';
import { Eye, Wind, Scale, Layers, Droplets, FlaskConical, Activity, Star } from 'lucide-react';

const fruitCards = [
  { icon: Eye, title: 'Computer Vision Analysis', body: 'YOLOv8 detects fruit type and ROI. CNN extracts ripeness cues — color gradients, surface mold, bruising, texture anomalies.', tags: 'YOLOv8 · CNN · OpenCV' },
  { icon: Wind, title: 'Gas & VOC Sensing', body: 'Ethylene and volatile organic compound detection correlates directly with internal fruit ripeness and spoilage stage.', tags: 'MQ-series · Gas Chromatography' },
  { icon: Scale, title: 'Weight & Structural Analysis', body: 'Load cell measurement provides fruit mass data. Density anomalies and weight loss over time indicate internal decay.', tags: 'HX711 · Load Cell' },
  { icon: Layers, title: 'Explainable AI (XAI)', body: 'Grad-CAM heatmaps visually highlight which regions of the fruit image drove the model\'s decision — building user trust.', tags: 'Grad-CAM · Sensor Weight Interpretation' },
];
const juiceCards = [
  { icon: Droplets, title: 'Sugar (Brix) Analysis', body: 'Measures dissolved sugar concentration (°Brix) to assess sweetness, dilution, or adulteration of fruit juices.', tags: 'Brix Probe · NIR principles' },
  { icon: FlaskConical, title: 'pH Level Detection', body: 'Determines juice acidity/alkalinity — a key indicator of freshness, fermentation stage, or chemical adulteration.', tags: 'pH Electrode · ADC' },
  { icon: Activity, title: 'Turbidity & Conductivity', body: 'Optical turbidity sensors measure juice clarity. Conductivity reveals dissolved ion concentrations and dilution levels.', tags: 'Turbidity Sensor · Conductivity Probe' },
  { icon: Star, title: 'Fusion Quality Label', body: 'All probe readings are passed through a fusion model (LightGBM / XGBoost) to generate a categorical juice quality label and health score.', tags: 'LightGBM · XGBoost · Feature Fusion' },
];

function FeatureCard({ card, index, color }) {
  const Icon = card.icon;
  return (
    <div className="card card-hover" style={{
      animation: `fade-in-up 0.5s ease ${index * 0.1}s both`,
      display: 'flex', flexDirection: 'column', gap: 14,
    }}>
      <div style={{
        width: 44, height: 44, borderRadius: 10,
        background: `rgba(${color === 'green' ? '57,255,20' : '0,229,204'}, 0.1)`,
        border: `1px solid rgba(${color === 'green' ? '57,255,20' : '0,229,204'}, 0.3)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon size={20} color={color === 'green' ? 'var(--accent-green)' : 'var(--accent-teal)'} />
      </div>
      <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-primary)' }}>
        {card.title}
      </div>
      <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: 1.7 }}>
        {card.body}
      </div>
      <div style={{
        fontFamily: 'DM Mono,monospace', fontSize: '0.68rem',
        color: color === 'green' ? 'var(--accent-green)' : 'var(--accent-teal)',
        borderTop: `1px solid rgba(${color === 'green' ? '57,255,20' : '0,229,204'}, 0.15)`,
        paddingTop: 10, marginTop: 'auto',
      }}>{card.tags}</div>
    </div>
  );
}

export default function Features() {
  const [mode, setMode] = useState('fruit');
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  const cards = mode === 'fruit' ? fruitCards : juiceCards;
  const color = mode === 'fruit' ? 'green' : 'teal';

  return (
    <section id="features" ref={ref} style={{ padding: '80px 24px', background: 'rgba(12,26,14,0.4)' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">02 — Core Capabilities</div>
        <h2 className="section-title">CORE CAPABILITIES</h2>

        {/* Mode Toggle */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 40 }}>
          <button className={`tab-btn ${mode === 'fruit' ? 'active' : ''}`} onClick={() => setMode('fruit')}>
            🍎 FRUIT MODE
          </button>
          <button className={`tab-btn ${mode === 'juice' ? 'active' : ''}`}
            onClick={() => setMode('juice')}
            style={mode === 'juice' ? { background: 'var(--accent-teal)', color: '#050a06', borderColor: 'var(--accent-teal)' } : {}}>
            🥤 JUICE MODE
          </button>
        </div>

        {/* Cards grid */}
        <div key={mode} style={{
          display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 20,
          animation: 'fade-in-up 0.4s ease',
        }}>
          {cards.map((c, i) => <FeatureCard key={i} card={c} index={i} color={color} />)}
        </div>
      </div>
    </section>
  );
}
