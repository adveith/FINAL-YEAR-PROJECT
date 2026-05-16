import { useState, useEffect } from 'react';
import { Menu, X } from 'lucide-react';

const links = [
  { label: 'Home', href: '#home' },
  { label: 'Features', href: '#features' },
  { label: 'How It Works', href: '#how-it-works' },
  { label: 'Simulator', href: '#simulator' },
  { label: 'Team', href: '#team' },
  { label: 'Research', href: '#research' },
  { label: 'Chat', href: '#chat' },
];

function LeafCircuitLogo() {
  return (
    <svg width={28} height={28} viewBox="0 0 28 28" fill="none">
      <path d="M14 3 C6 3 3 10 4 16 C5 22 10 25 14 25 C18 25 24 22 24 14 C24 8 20 3 14 3Z"
        fill="none" stroke="#39ff14" strokeWidth={1.5} />
      <line x1={14} y1={25} x2={14} y2={28} stroke="#39ff14" strokeWidth={1.5} />
      <line x1={10} y1={14} x2={18} y2={14} stroke="#39ff14" strokeWidth={1} />
      <line x1={14} y1={10} x2={14} y2={18} stroke="#39ff14" strokeWidth={1} />
      <circle cx={10} cy={14} r={1.5} fill="#39ff14" />
      <circle cx={18} cy={14} r={1.5} fill="#39ff14" />
      <circle cx={14} cy={10} r={1.5} fill="#39ff14" />
      <circle cx={14} cy={18} r={1.5} fill="#ffb700" />
    </svg>
  );
}

export default function Navigation({ activeSection }) {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 60);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const scrollTo = (href) => {
    const el = document.querySelector(href);
    if (el) el.scrollIntoView({ behavior: 'smooth' });
    setMenuOpen(false);
  };

  return (
    <>
      <nav style={{
        position: 'fixed', top: 0, left: 0, right: 0, zIndex: 1000,
        height: 56, display: 'flex', alignItems: 'center',
        justifyContent: 'space-between', padding: '0 24px',
        borderBottom: '1px solid rgba(57,255,20,0.2)',
        background: scrolled ? 'rgba(5,10,6,0.85)' : 'rgba(5,10,6,0.6)',
        backdropFilter: scrolled ? 'blur(12px)' : 'none',
        boxShadow: scrolled ? '0 4px 30px rgba(0,0,0,0.4)' : 'none',
        transition: 'all 0.3s ease',
      }}>
        {/* Logo */}
        <button onClick={() => scrollTo('#home')} style={{
          display: 'flex', alignItems: 'center', gap: 10, background: 'none', border: 'none', cursor: 'pointer'
        }}>
          <LeafCircuitLogo />
          <span style={{
            fontFamily: 'Orbitron,monospace', fontWeight: 700, fontSize: '1rem',
            color: 'var(--accent-green)', letterSpacing: '0.05em'
          }}>SmartFruit</span>
        </button>

        {/* Desktop Links */}
        <div style={{ display: 'flex', gap: 28, alignItems: 'center' }} className="hide-mobile">
          {links.map(l => (
            <button key={l.href} onClick={() => scrollTo(l.href)} style={{
              background: 'none', border: 'none', cursor: 'pointer',
              fontFamily: 'DM Mono,monospace', fontSize: '0.82rem',
              color: activeSection === l.href.slice(1) ? 'var(--accent-green)' : 'var(--text-muted)',
              borderBottom: activeSection === l.href.slice(1) ? '1px solid var(--accent-green)' : '1px solid transparent',
              paddingBottom: 2, transition: 'all 0.2s',
              position: 'relative',
            }}
              onMouseEnter={e => { if (activeSection !== l.href.slice(1)) e.target.style.color = 'var(--text-primary)'; }}
              onMouseLeave={e => { if (activeSection !== l.href.slice(1)) e.target.style.color = 'var(--text-muted)'; }}
            >{l.label}</button>
          ))}
        </div>

        {/* Hamburger */}
        <button onClick={() => setMenuOpen(!menuOpen)} style={{
          display: 'none', background: 'none', border: 'none',
          color: 'var(--accent-green)', cursor: 'pointer'
        }} className="show-mobile" id="hamburger-btn">
          {menuOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </nav>

      {/* Mobile Menu */}
      {menuOpen && (
        <div style={{
          position: 'fixed', top: 56, left: 0, right: 0, zIndex: 999,
          background: 'rgba(5,10,6,0.97)', backdropFilter: 'blur(12px)',
          borderBottom: '1px solid var(--border-glow)',
          padding: '16px 24px', display: 'flex', flexDirection: 'column', gap: 4
        }}>
          {links.map(l => (
            <button key={l.href} onClick={() => scrollTo(l.href)} style={{
              background: 'none', border: 'none', cursor: 'pointer',
              fontFamily: 'DM Mono,monospace', fontSize: '0.9rem',
              color: activeSection === l.href.slice(1) ? 'var(--accent-green)' : 'var(--text-muted)',
              padding: '10px 0', textAlign: 'left', borderBottom: '1px solid rgba(57,255,20,0.08)'
            }}>{l.label}</button>
          ))}
        </div>
      )}

      <style>{`
        @media (max-width: 768px) {
          .hide-mobile { display: none !important; }
          #hamburger-btn { display: flex !important; }
        }
      `}</style>
    </>
  );
}
