import { useState, useEffect } from 'react';
import { Zap, Brain } from 'lucide-react';

const deviceTextCycle = ['Analysing...', 'Fruit: Apple ✓', 'Ripe ✓', 'Shelf Life: 3 days', 'Score: 87/100', 'Uploading...'];

function DeviceMockup() {
  const [textIdx, setTextIdx] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setTextIdx(i => (i + 1) % deviceTextCycle.length), 1800);
    return () => clearInterval(t);
  }, []);

  const sensors = [
    { label: '📷 Camera', x: -110, y: -60 },
    { label: '⚗️ VOC Sensor', x: 120, y: -40 },
    { label: '⚖️ Load Cell', x: -120, y: 60 },
    { label: '🔬 pH Probe', x: 110, y: 80 },
  ];

  return (
    <div style={{ position: 'relative', width: 280, height: 420, margin: '0 auto', animation: 'float 4s ease-in-out infinite' }}>
      {/* Sensor bubbles */}
      {sensors.map((s, i) => (
        <div key={i} style={{
          position: 'absolute', top: '50%', left: '50%',
          transform: `translate(calc(-50% + ${s.x}px), calc(-50% + ${s.y}px))`,
          background: 'var(--bg-card)', border: '1px dashed rgba(57,255,20,0.4)',
          borderRadius: 8, padding: '4px 10px',
          fontSize: '0.7rem', fontFamily: 'DM Mono,monospace', color: 'var(--accent-green)',
          whiteSpace: 'nowrap', zIndex: 2,
          animation: `pulse-glow ${2 + i * 0.3}s ease-in-out infinite`,
        }}>{s.label}</div>
      ))}

      {/* Device body */}
      <div style={{
        position: 'absolute', left: '50%', top: '50%',
        transform: 'translate(-50%, -50%)',
        width: 160, height: 260,
        background: 'linear-gradient(160deg, #0c1a0e 0%, #050a06 100%)',
        borderRadius: 20,
        border: '1px solid rgba(57,255,20,0.35)',
        boxShadow: '0 0 30px rgba(57,255,20,0.15), inset 0 0 20px rgba(57,255,20,0.04)',
        display: 'flex', flexDirection: 'column', alignItems: 'center',
      }}>
        {/* LED strip */}
        <div style={{
          width: '80%', height: 6, margin: '14px auto 0',
          background: 'linear-gradient(90deg, transparent, #39ff14, #00e5cc, #39ff14, transparent)',
          borderRadius: 3, boxShadow: '0 0 12px #39ff14',
          animation: 'pulse-glow 1.5s ease-in-out infinite'
        }} />

        {/* LCD Screen */}
        <div style={{
          margin: '16px auto', width: 120, height: 72,
          background: '#020804', borderRadius: 8,
          border: '1px solid rgba(57,255,20,0.3)',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
          boxShadow: 'inset 0 0 12px rgba(57,255,20,0.1)',
          overflow: 'hidden', position: 'relative',
        }}>
          <div style={{
            color: '#39ff14', fontFamily: 'DM Mono,monospace', fontSize: '0.68rem',
            textAlign: 'center', padding: '0 8px',
            animation: 'fade-in-up 0.4s ease', key: textIdx
          }} key={textIdx}>{deviceTextCycle[textIdx]}</div>
          <div style={{
            position: 'absolute', top: 0, left: 0, right: 0, height: '2px',
            background: 'linear-gradient(90deg, transparent, rgba(57,255,20,0.4), transparent)',
            animation: 'scanline 3s linear infinite'
          }} />
        </div>

        {/* Camera lens */}
        <div style={{
          width: 40, height: 40, borderRadius: '50%',
          background: 'radial-gradient(circle, #0a1a0c, #050a06)',
          border: '2px solid rgba(57,255,20,0.4)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 0 10px rgba(57,255,20,0.2)',
          marginBottom: 12,
        }}>
          <div style={{ width: 16, height: 16, borderRadius: '50%', background: '#39ff14', opacity: 0.8 }} />
        </div>

        {/* Juice side compartment */}
        <div style={{
          position: 'absolute', right: -18, top: 80, width: 16, height: 50,
          background: 'var(--bg-panel)', border: '1px solid rgba(0,229,204,0.5)',
          borderRadius: '0 6px 6px 0',
          boxShadow: '0 0 8px rgba(0,229,204,0.3)',
        }} />

        {/* Fruit tray */}
        <div style={{
          position: 'absolute', bottom: -16, left: '50%', transform: 'translateX(-50%)',
          width: 140, height: 24,
          background: 'var(--bg-panel)', border: '1px solid rgba(57,255,20,0.3)',
          borderRadius: '0 0 10px 10px',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          {['🍎', '🍊', '🍌'].map((f, i) => (
            <span key={i} style={{ fontSize: '0.7rem' }}>{f}</span>
          ))}
        </div>
      </div>
    </div>
  );
}

export default function Hero({ onLaunchDemo }) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => { setTimeout(() => setMounted(true), 100); }, []);

  const scrollTo = (id) => document.querySelector(id)?.scrollIntoView({ behavior: 'smooth' });

  return (
    <section id="home" style={{
      minHeight: '100vh', display: 'flex', alignItems: 'center',
      padding: '80px 24px 40px', position: 'relative', overflow: 'hidden',
    }}>
      {/* Diagonal overlay */}
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: 'linear-gradient(135deg, rgba(57,255,20,0.04) 0%, transparent 50%, rgba(255,183,0,0.03) 100%)',
      }} />

      <div style={{
        maxWidth: 1200, margin: '0 auto', width: '100%',
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 64, alignItems: 'center',
        animation: mounted ? 'fade-in-up 0.8s ease forwards' : 'none',
        opacity: mounted ? 1 : 0,
      }} className="hero-grid">
        {/* Left */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          {/* Badge */}
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 8,
            border: '1px solid var(--accent-green)', borderRadius: 6,
            padding: '6px 14px', width: 'fit-content',
            fontFamily: 'DM Mono,monospace', fontSize: '0.72rem',
            color: 'var(--accent-green)',
            animation: 'pulse-glow 2s ease-in-out infinite',
          }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--accent-green)', display: 'inline-block' }} />
            EDGE AI DEVICE
          </div>

          {/* Heading */}
          <div>
            <h1 style={{
              fontFamily: 'Orbitron,monospace', fontSize: 'clamp(2.2rem, 5vw, 3.5rem)',
              fontWeight: 900, lineHeight: 1.1,
              color: 'var(--accent-green)',
              textShadow: '0 0 30px rgba(57,255,20,0.4)',
              animation: 'letter-glow 3s ease-in-out infinite',
            }}>SmartFruit</h1>
            <div style={{
              fontFamily: 'Orbitron,monospace', fontSize: 'clamp(0.9rem, 2vw, 1.2rem)',
              color: 'var(--text-muted)', marginTop: 8, fontWeight: 400,
            }}>Fruit Freshness. Juice Intelligence.</div>
          </div>

          <p style={{
            fontFamily: 'DM Mono,monospace', fontSize: '0.9rem', color: 'var(--text-muted)',
            lineHeight: 1.8, maxWidth: 480,
          }}>
            A multimodal Edge-AI device that fuses computer vision, VOC gas sensing, and chemical probes to deliver real-time fruit ripeness analysis and juice quality assessment — all processed on-device via NVIDIA Jetson.
          </p>

          {/* CTA Buttons */}
          <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
            <button className="btn-primary" onClick={onLaunchDemo} style={{ background: 'var(--accent-amber)', color: 'var(--bg-deep)', display: 'flex', alignItems: 'center', gap: 8 }}>
              <Zap size={16} fill="currentColor" /> Launch Live Demo
            </button>
            <button className="btn-outline" onClick={() => scrollTo('#features')}>
              Explore Tech →
            </button>
          </div>

          {/* Stat pills */}
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginTop: 8 }}>
            {[
              { icon: '⚡', text: 'On-Device Processing' },
              { icon: '🧠', text: 'Explainable AI' },
              { icon: '🍊', text: 'Dual-Mode Analysis' },
            ].map((s, i) => (
              <div key={i} className="chip">
                <span>{s.icon}</span>{s.text}
              </div>
            ))}
          </div>
        </div>

        {/* Right — Device Mockup */}
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          <DeviceMockup />
        </div>
      </div>

      <style>{`
        @media (max-width: 768px) {
          .hero-grid { grid-template-columns: 1fr !important; }
        }
      `}</style>
    </section>
  );
}
