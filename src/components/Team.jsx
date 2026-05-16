import { useRef, useEffect, useState } from 'react';

const members = [
  {
    name: 'Adveith Walke',
    prn: '20220802028',
    role: 'Project Lead & CV Engineer',
    tagline: 'Computer Vision · YOLOv8 · Edge Deployment',
    color: 'var(--accent-green)',
    avatar: (color) => (
      <svg width="80" height="80" viewBox="0 0 80 80">
        <circle cx="40" cy="40" r="38" fill="none" stroke={color} strokeWidth="1" strokeDasharray="4 4" />
        <path d="M40 15 L65 40 L40 65 L15 40 Z" fill={color} fillOpacity="0.1" stroke={color} strokeWidth="2" />
        <circle cx="40" cy="40" r="8" fill={color} />
      </svg>
    )
  },
  {
    name: 'Khushi Solanki',
    prn: '20220802108',
    role: 'Sensor Integration & Data Engineer',
    tagline: 'Multimodal Sensing · Feature Engineering · Fusion Model',
    color: 'var(--accent-amber)',
    avatar: (color) => (
      <svg width="80" height="80" viewBox="0 0 80 80">
        <circle cx="40" cy="40" r="38" fill="none" stroke={color} strokeWidth="1" strokeDasharray="2 2" />
        <rect x="25" y="25" width="30" height="30" rx="4" fill={color} fillOpacity="0.1" stroke={color} strokeWidth="2" />
        <path d="M25 40 H55 M40 25 V55" stroke={color} strokeWidth="1.5" />
      </svg>
    )
  },
  {
    name: 'Bhavisha Chauhan',
    prn: '20220802171',
    role: 'Web Dashboard & XAI Engineer',
    tagline: 'Grad-CAM · Flask/FastAPI · Frontend Dashboard',
    color: 'var(--accent-teal)',
    avatar: (color) => (
      <svg width="80" height="80" viewBox="0 0 80 80">
        <circle cx="40" cy="40" r="38" fill="none" stroke={color} strokeWidth="1" />
        <circle cx="40" cy="40" r="20" fill={color} fillOpacity="0.1" stroke={color} strokeWidth="2" />
        <path d="M40 20 A20 20 0 0 1 60 40" fill="none" stroke={color} strokeWidth="3" strokeLinecap="round" />
        <circle cx="40" cy="40" r="4" fill={color} />
      </svg>
    )
  }
];

export default function Team() {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section id="team" ref={ref} style={{ padding: '80px 24px' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">08 — The Minds Behind</div>
        <h2 className="section-title">THE TEAM</h2>
        <p className="section-sub">B.Tech CSE — D Y Patil International University, Akurdi, Pune | A.Y. 2025–2026</p>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: 24, marginBottom: 48 }}>
          {members.map((m, i) => (
            <div key={m.name} className="card card-hover" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 16, animation: visible ? `fade-in-up 0.5s ease ${i * 0.1}s both` : 'none' }}>
              <div style={{ padding: 10 }}>{m.avatar(m.color)}</div>
              <div>
                <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '1.1rem', fontWeight: 700, color: 'var(--text-primary)' }}>{m.name}</div>
                <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: 4 }}>PRN: {m.prn}</div>
              </div>
              <div className="badge badge-green" style={{ background: `${m.color}15`, color: m.color, borderColor: `${m.color}30` }}>{m.role}</div>
              <p style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: 1.6 }}>{m.tagline}</p>
              <button style={{ background: 'none', border: `1px solid ${m.color}40`, color: m.color, padding: '6px 16px', borderRadius: 4, fontSize: '0.75rem', fontFamily: 'DM Mono,monospace', cursor: 'pointer', transition: 'all 0.2s' }} onMouseEnter={e => e.target.style.background = `${m.color}10`} onMouseLeave={e => e.target.style.background = 'none'}>LinkedIn ↗</button>
            </div>
          ))}
        </div>

        {/* Project Guide Card */}
        <div className="card" style={{ maxWidth: 800, margin: '0 auto', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 12, borderLeft: '4px solid var(--accent-purple)', animation: visible ? 'fade-in-up 0.6s ease 0.4s both' : 'none' }}>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.8rem', color: 'var(--accent-purple)', letterSpacing: '0.2em' }}>PROJECT GUIDE</div>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '1.4rem', fontWeight: 700, color: 'var(--text-primary)' }}>Dr. Maheshwari Biradar</div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.9rem', color: 'var(--text-muted)' }}>School of Computer Science, Engineering and Applications</div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.9rem', color: 'var(--text-muted)' }}>D Y Patil International University, Akurdi, Pune</div>
          <p style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.85rem', color: 'var(--accent-purple)', marginTop: 8, fontStyle: 'italic' }}>"Guiding the fusion of hardware sensing and intelligent AI for real-world food quality solutions."</p>
        </div>
      </div>
    </section>
  );
}
