import { useState, useRef, useEffect } from 'react';

const clusters = [
  {
    id: 1, title: 'Computer Vision & Ripeness Classification',
    color: 'var(--accent-green)', borderColor: 'rgba(57,255,20,0.4)',
    refs: [
      { n:1, title:'Deep Learning for Fruit Ripeness Detection', authors:'Zhang et al.', journal:'IEEE Trans. on Food Science', year:2022, note:'Foundation for CNN-based ripeness classification applied in SmartFruit\'s vision module.' },
      { n:13, title:'YOLOv8-Based Real-Time Fruit Detection', authors:'Li & Chen', journal:'Pattern Recognition Letters', year:2023, note:'Drives SmartFruit\'s fruit-type detection and ROI extraction pipeline.' },
      { n:16, title:'Texture Analysis for Surface Defect Detection in Produce', authors:'Patel et al.', journal:'Computers & Electronics in Agriculture', year:2021, note:'Informs the texture anomaly detection arm of the CNN model.' },
    ],
  },
  {
    id: 2, title: 'Gas Sensing & VOC Detection',
    color: 'var(--accent-amber)', borderColor: 'rgba(255,183,0,0.4)',
    refs: [
      { n:2, title:'Ethylene Detection in Post-Harvest Fruits', authors:'Kumar & Singh', journal:'Postharvest Biology & Technology', year:2020, note:'Directly motivates SmartFruit\'s MQ-series gas sensor integration for ripeness.' },
      { n:3, title:'Electronic Nose Systems for Fruit Quality Assessment', authors:'Hernandez et al.', journal:'Sensors & Actuators B', year:2021, note:'Validates the use of VOC sensor arrays for freshness scoring.' },
      { n:8, title:'VOC Profiling of Tropical Fruits During Ripening', authors:'Osei & Mensah', journal:'Food Chemistry', year:2019, note:'Provides VOC reference profiles used in SmartFruit\'s gas feature engineering.' },
      { n:9, title:'Gas Sensor Array Calibration for Agricultural Use', authors:'Wang et al.', journal:'Journal of Agricultural Engineering', year:2022, note:'Informs sensor calibration methodology for SmartFruit\'s field deployment.' },
      { n:10, title:'Correlation of Ethylene Levels with Fruit Shelf Life', authors:'Desai & Rao', journal:'Postharvest Biology & Technology', year:2020, note:'Provides ethylene-to-shelf-life mapping used in SmartFruit\'s freshness model.' },
      { n:11, title:'Low-Cost MQ Sensor Arrays for Spoilage Detection', authors:'Nair et al.', journal:'IEEE Sensors Journal', year:2023, note:'Validates the MQ-series sensor choice for cost-effective VOC detection.' },
    ],
  },
  {
    id: 3, title: 'Spectroscopy & Juice Quality',
    color: 'var(--accent-teal)', borderColor: 'rgba(0,229,204,0.4)',
    refs: [
      { n:5, title:'NIR Spectroscopy for Brix Estimation in Juices', authors:'Gonzalez et al.', journal:'Journal of Food Engineering', year:2021, note:'Basis for SmartFruit\'s Brix optical probe and sugar concentration analysis.' },
      { n:6, title:'pH-Based Adulteration Detection in Fruit Juices', authors:'Sharma & Verma', journal:'Food Control', year:2022, note:'Motivates pH probe integration for detecting juice adulteration in SmartFruit.' },
      { n:7, title:'Turbidity Measurement for Juice Clarity Assessment', authors:'Ahmed et al.', journal:'LWT - Food Science & Technology', year:2020, note:'Underpins SmartFruit\'s turbidity sensor selection and clarity classification.' },
      { n:12, title:'Multi-Parameter Sensor Fusion for Juice Authentication', authors:'Tanaka & Inoue', journal:'Analytical Chemistry', year:2023, note:'Core inspiration for SmartFruit\'s multi-probe fusion model in juice mode.' },
    ],
  },
  {
    id: 4, title: 'Edge AI & Deployment',
    color: 'var(--accent-purple)', borderColor: 'rgba(168,85,247,0.4)',
    refs: [
      { n:4, title:'Edge AI for Real-Time Inference on Embedded Systems', authors:'Chen et al.', journal:'ACM Computing Surveys', year:2023, note:'Justifies SmartFruit\'s NVIDIA Jetson platform for low-latency on-device inference.' },
      { n:14, title:'TensorRT Optimization for CNN Deployment', authors:'Liu & Park', journal:'NVIDIA Technical Report', year:2022, note:'Guides SmartFruit\'s TensorRT model optimization pipeline.' },
      { n:15, title:'ONNX Runtime for Cross-Platform Model Export', authors:'Onnx Contributors', journal:'arXiv Preprint', year:2022, note:'Enables SmartFruit\'s model portability and cross-device deployment.' },
      { n:17, title:'Explainable AI for Agricultural Decision Support', authors:'Mbeki & Okafor', journal:'Computers & Electronics in Agriculture', year:2023, note:'Supports SmartFruit\'s Grad-CAM XAI layer for farmer-facing explanations.' },
      { n:18, title:'LightGBM for Multi-Modal Sensor Classification', authors:'Huang et al.', journal:'Expert Systems with Applications', year:2023, note:'Directly used in SmartFruit\'s LightGBM fusion model for both modes.' },
    ],
  },
];

function RefCard({ r, color, borderColor }) {
  const [open, setOpen] = useState(false);
  return (
    <div onClick={() => setOpen(o => !o)} style={{
      background: 'var(--bg-panel)', borderRadius: 8, padding: '12px 16px',
      borderLeft: `3px solid ${borderColor}`, cursor: 'pointer',
      transition: 'all 0.2s', marginBottom: 8,
    }}
      onMouseEnter={e => e.currentTarget.style.background = '#0f2012'}
      onMouseLeave={e => e.currentTarget.style.background = 'var(--bg-panel)'}
    >
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        <span style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.72rem', color, flexShrink: 0, marginTop: 2 }}>[{r.n}]</span>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-primary)', marginBottom: 4 }}>{r.title}</div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.7rem', color: 'var(--text-muted)' }}>
            {r.authors} · <em>{r.journal}</em> · {r.year}
          </div>
          {open && (
            <div style={{ marginTop: 8, fontFamily: 'DM Mono,monospace', fontSize: '0.72rem', color, lineHeight: 1.6, animation: 'fade-in-up 0.2s ease' }}>
              → {r.note}
            </div>
          )}
        </div>
        <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem', transition: 'transform 0.2s', transform: open ? 'rotate(180deg)' : 'none' }}>▾</span>
      </div>
    </div>
  );
}

function Cluster({ c }) {
  const [open, setOpen] = useState(true);
  return (
    <div className="card" style={{ marginBottom: 20, borderLeft: `3px solid ${c.color}` }}>
      <div onClick={() => setOpen(o => !o)} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer', marginBottom: open ? 16 : 0 }}>
        <div>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: c.color }}>{c.title}</div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.72rem', color: 'var(--text-muted)', marginTop: 4 }}>{c.refs.length} references</div>
        </div>
        <span style={{ color: c.color, fontSize: '1rem', transition: 'transform 0.2s', transform: open ? 'rotate(180deg)' : 'none' }}>▾</span>
      </div>
      {open && (
        <div style={{ animation: 'fade-in-up 0.3s ease' }}>
          {c.refs.map(r => <RefCard key={r.n} r={r} color={c.color} borderColor={c.borderColor} />)}
        </div>
      )}
    </div>
  );
}

export default function Research() {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section id="research" ref={ref} style={{ padding: '80px 24px', background: 'rgba(12,26,14,0.4)' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">07 — Research Foundation</div>
        <h2 className="section-title">RESEARCH FOUNDATION</h2>
        <p className="section-sub">SmartFruit is grounded in peer-reviewed literature across multimodal sensing, edge AI, and food quality assessment.</p>

        {/* Research gap banner */}
        <div style={{
          background: 'rgba(57,255,20,0.05)', border: '1px solid rgba(57,255,20,0.3)',
          borderRadius: 12, padding: '20px 24px', marginBottom: 40,
          borderLeft: '4px solid var(--accent-green)',
        }}>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.78rem', color: 'var(--accent-green)', marginBottom: 8 }}>
            RESEARCH GAP — WHY SMARTFRUIT?
          </div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.85rem', color: 'var(--text-muted)', lineHeight: 1.8 }}>
            Existing solutions are either <strong style={{ color: 'var(--text-primary)' }}>single-parameter tools</strong> (e.g., handheld refractometers measuring only Brix) or <strong style={{ color: 'var(--text-primary)' }}>expensive lab-grade instruments</strong>. SmartFruit bridges this gap with a <strong style={{ color: 'var(--accent-green)' }}>multimodal, consumer-affordable, explainable, dual-mode device</strong>.
          </div>
        </div>

        {clusters.map(c => <Cluster key={c.id} c={c} />)}
      </div>
    </section>
  );
}
