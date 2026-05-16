import { useState, useEffect } from 'react';

const steps = ['Initializing sensors...', 'Loading AI models...', 'Calibrating probes...', 'Ready.'];

export default function LoadingScreen({ onDone }) {
  const [step, setStep] = useState(0);
  const [progress, setProgress] = useState(0);
  const [fading, setFading] = useState(false);

  useEffect(() => {
    let p = 0;
    const interval = setInterval(() => {
      p += 2;
      setProgress(Math.min(p, 100));
      setStep(Math.floor((p / 100) * (steps.length - 1)));
      if (p >= 100) {
        clearInterval(interval);
        setTimeout(() => { setFading(true); setTimeout(onDone, 600); }, 300);
      }
    }, 25);
    return () => clearInterval(interval);
  }, [onDone]);

  const r = 45, circ = 2 * Math.PI * r;
  const dashOffset = circ - (progress / 100) * circ;

  return (
    <div style={{
      position: 'fixed', inset: 0, zIndex: 9999,
      background: 'var(--bg-deep)',
      display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', gap: 32,
      transition: 'opacity 0.6s ease',
      opacity: fading ? 0 : 1, pointerEvents: fading ? 'none' : 'all'
    }}>
      {/* SVG Ring */}
      <svg width={120} height={120} style={{ filter: 'drop-shadow(0 0 12px #39ff14)' }}>
        <circle cx={60} cy={60} r={r} fill="none" stroke="rgba(57,255,20,0.1)" strokeWidth={4} />
        <circle cx={60} cy={60} r={r} fill="none" stroke="#39ff14" strokeWidth={4}
          strokeDasharray={circ} strokeDashoffset={dashOffset}
          strokeLinecap="round" transform="rotate(-90 60 60)"
          style={{ transition: 'stroke-dashoffset 0.1s linear' }} />
        <text x={60} y={65} textAnchor="middle" fill="#39ff14"
          style={{ fontFamily: 'Orbitron,monospace', fontSize: 16, fontWeight: 700 }}>
          {progress}%
        </text>
      </svg>

      {/* Logo */}
      <div style={{ textAlign: 'center' }}>
        <div style={{
          fontFamily: 'Orbitron,monospace', fontSize: '2.2rem', fontWeight: 900,
          color: 'var(--accent-green)', letterSpacing: '0.05em',
          animation: 'letter-glow 2s ease-in-out infinite'
        }}>SmartFruit</div>
        <div style={{ color: 'var(--text-muted)', fontSize: '0.8rem', marginTop: 4, fontFamily: 'DM Mono,monospace' }}>
          Edge-AI Fruit Intelligence Platform
        </div>
      </div>

      {/* Step text */}
      <div style={{
        color: 'var(--accent-green)', fontFamily: 'DM Mono,monospace',
        fontSize: '0.85rem', minHeight: 24,
        animation: 'fade-in-up 0.4s ease'
      }} key={step}>
        {steps[step]}
      </div>

      {/* Progress bar */}
      <div style={{ width: 280, height: 2, background: 'rgba(57,255,20,0.1)', borderRadius: 1 }}>
        <div style={{
          height: '100%', background: 'var(--accent-green)',
          width: `${progress}%`, borderRadius: 1,
          boxShadow: '0 0 8px var(--accent-green)',
          transition: 'width 0.1s linear'
        }} />
      </div>
    </div>
  );
}
