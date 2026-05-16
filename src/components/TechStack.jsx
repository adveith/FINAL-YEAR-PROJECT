import { useRef, useEffect, useState } from 'react';

const techData = {
  'AI & ML': [
    'YOLOv8 (Object Detection)', 'Convolutional Neural Networks', 'Grad-CAM (Explainability)',
    'LightGBM (Ensemble Fusion)', 'XGBoost (Ensemble Fusion)', 'TensorRT (Edge Optimization)',
    'Feature Fusion Architecture',
  ],
  'Hardware': [
    'NVIDIA Jetson (Edge AI)', 'RGB Camera Module', 'VOC / Gas Sensors', 'Load Cell + HX711',
    'pH Electrode Probe', 'Brix Optical Probe', 'Turbidity Sensor',
    'Conductivity Probe', 'LCD Display Module', 'Lighting Control Module',
  ],
  'Software & Deployment': [
    'Python (Core Processing)', 'Flask / FastAPI (Backend)', 'OpenCV (Image Processing)',
    'React.js (Dashboard)', 'TensorRT (Model Optimization)', 'ONNX (Model Export)',
  ],
};

const colColors = {
  'AI & ML': 'var(--accent-green)',
  'Hardware': 'var(--accent-amber)',
  'Software & Deployment': 'var(--accent-teal)',
};

export default function TechStack() {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section id="tech" ref={ref} style={{ padding: '80px 24px' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">06 — Tech Stack</div>
        <h2 className="section-title">TECHNOLOGY STACK</h2>
        <p className="section-sub">A curated stack spanning AI/ML, embedded hardware, and web deployment.</p>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 24, marginBottom: 48 }}>
          {Object.entries(techData).map(([cat, items]) => (
            <div key={cat} className="card" style={{ borderTop: `3px solid ${colColors[cat]}` }}>
              <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.82rem', color: colColors[cat], marginBottom: 20 }}>{cat}</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                {items.map((item, i) => (
                  <div key={item} className="chip" style={{
                    borderColor: `${colColors[cat]}40`, color: colColors[cat],
                    background: `${colColors[cat]}08`,
                    animation: `fade-in-up 0.4s ease ${i * 0.06}s both`,
                  }}>{item}</div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Deployment Architecture */}
        <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.82rem', color: 'var(--text-muted)', marginBottom: 20 }}>
          DEPLOYMENT ARCHITECTURE
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 0, flexWrap: 'wrap', justifyContent: 'center' }}>
          {/* On-device box */}
          <div className="card" style={{ flex: 1, minWidth: 220, maxWidth: 320, borderColor: 'rgba(57,255,20,0.4)' }}>
            <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.78rem', color: 'var(--accent-green)', marginBottom: 12 }}>
              🖥️ ON-DEVICE (Jetson)
            </div>
            {['YOLOv8 Inference', 'CNN Ripeness Model', 'Sensor Fusion Pipeline', 'Grad-CAM Generation', 'LCD Display Output', 'Local Data Store'].map(i => (
              <div key={i} style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.72rem', color: 'var(--text-muted)', padding: '3px 0', borderBottom: '1px solid rgba(57,255,20,0.06)' }}>
                › {i}
              </div>
            ))}
          </div>

          {/* Arrow */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '0 16px', gap: 4 }}>
            <div style={{ fontSize: '1.2rem', color: 'var(--accent-green)', animation: 'pulse-glow 1.5s ease-in-out infinite' }}>⇄</div>
            <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.65rem', color: 'var(--text-muted)' }}>WiFi</div>
          </div>

          {/* Cloud box */}
          <div className="card" style={{ flex: 1, minWidth: 220, maxWidth: 320, borderColor: 'rgba(0,229,204,0.4)' }}>
            <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.78rem', color: 'var(--accent-teal)', marginBottom: 12 }}>
              ☁️ CLOUD / WIFI SYNC
            </div>
            {['Flask / FastAPI Dashboard', 'React Web UI', 'Remote Monitoring', 'Historical Data Sync', 'Alert Notifications', 'Export Reports'].map(i => (
              <div key={i} style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.72rem', color: 'var(--text-muted)', padding: '3px 0', borderBottom: '1px solid rgba(0,229,204,0.06)' }}>
                › {i}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
