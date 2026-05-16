export default function Footer() {
  const scrollTo = (id) => {
    document.querySelector(id)?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <footer style={{ padding: '60px 24px 20px', borderTop: '1px solid var(--border-glow)', background: 'var(--bg-deep)' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto', display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 40, marginBottom: 60 }}>
        {/* Brand */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <svg width={24} height={24} viewBox="0 0 28 28" fill="none">
              <path d="M14 3 C6 3 3 10 4 16 C5 22 10 25 14 25 C18 25 24 22 24 14 C24 8 20 3 14 3Z" fill="none" stroke="#39ff14" strokeWidth={2} />
              <circle cx={14} cy={14} r={4} fill="#39ff14" fillOpacity={0.2} stroke="#39ff14" strokeWidth={1} />
            </svg>
            <span style={{ fontFamily: 'Orbitron,monospace', fontWeight: 700, fontSize: '1.1rem', color: 'var(--accent-green)' }}>SmartFruit</span>
          </div>
          <p style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: 1.6 }}>
            Multimodal Edge-AI platform for real-time fruit freshness and juice quality analysis.
          </p>
        </div>

        {/* Quick Links */}
        <div>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: 'var(--text-primary)', marginBottom: 20 }}>QUICK LINKS</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {['Home', 'Features', 'How It Works', 'Simulator', 'Research', 'Chat'].map(link => (
              <button 
                key={link} 
                onClick={() => scrollTo(`#${link.toLowerCase().replace(/\s+/g, '-')}`)}
                style={{ background: 'none', border: 'none', textAlign: 'left', color: 'var(--text-muted)', fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', cursor: 'pointer', transition: 'color 0.2s' }}
                onMouseEnter={e => e.target.style.color = 'var(--accent-green)'}
                onMouseLeave={e => e.target.style.color = 'var(--text-muted)'}
              >
                {link}
              </button>
            ))}
          </div>
        </div>

        {/* Project Details */}
        <div>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: 'var(--text-primary)', marginBottom: 20 }}>INSTITUTION</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            <div>D Y Patil International University</div>
            <div>School of CS, Engineering & Applications</div>
            <div>Akurdi, Pune</div>
            <div style={{ marginTop: 8, color: 'var(--accent-green)' }}>Academic Year: 2025–2026</div>
          </div>
        </div>

        {/* Contact */}
        <div>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: 'var(--text-primary)', marginBottom: 20 }}>CONTACT</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            <div>Final Year Project Repository</div>
            <div>team@smartfruit.ai</div>
            <div style={{ marginTop: 12, display: 'flex', gap: 12 }}>
              <div style={{ width: 32, height: 32, borderRadius: 4, background: 'var(--bg-panel)', border: '1px solid var(--border-glow)' }} />
              <div style={{ width: 32, height: 32, borderRadius: 4, background: 'var(--bg-panel)', border: '1px solid var(--border-glow)' }} />
              <div style={{ width: 32, height: 32, borderRadius: 4, background: 'var(--bg-panel)', border: '1px solid var(--border-glow)' }} />
            </div>
          </div>
        </div>
      </div>

      <div style={{ borderTop: '1px solid rgba(57,255,20,0.1)', paddingTop: 20, textAlign: 'center' }}>
        <p style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.7rem', color: 'var(--text-muted)' }}>
          Built with ❤️ by Team SmartFruit · D Y Patil International University · 2025–2026
        </p>
        <p style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.6rem', color: 'var(--text-muted)', marginTop: 8, opacity: 0.6 }}>
          Disclaimer: This website is a project showcase for academic purposes.
        </p>
      </div>
    </footer>
  );
}
