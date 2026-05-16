import { useState, useEffect } from 'react';
import LoadingScreen from './components/LoadingScreen';
import Navigation from './components/Navigation';
import Hero from './components/Hero';
import Features from './components/Features';
import HowItWorks from './components/HowItWorks';
import Simulator from './components/Simulator';
import TechStack from './components/TechStack';
import Research from './components/Research';
import Team from './components/Team';
import Timeline from './components/Timeline';
import Chatbot from './components/Chatbot';
import Footer from './components/Footer';
import DemoApp from './components/DemoApp';
import { ChevronUp, Zap } from 'lucide-react';

export default function App() {
  const [loading, setLoading] = useState(true);
  const [showDemo, setShowDemo] = useState(false);
  const [activeSection, setActiveSection] = useState('home');
  const [showScrollTop, setShowScrollTop] = useState(false);

  useEffect(() => {
    if (showDemo) return; // Disable scroll tracking in demo mode

    const handleScroll = () => {
      setShowScrollTop(window.scrollY > 300);

      // Section highlighting logic
      const sections = ['home', 'features', 'how-it-works', 'simulator', 'tech', 'research', 'team', 'timeline', 'chat'];
      for (const section of sections) {
        const el = document.getElementById(section);
        if (el) {
          const rect = el.getBoundingClientRect();
          if (rect.top <= 100 && rect.bottom >= 100) {
            setActiveSection(section);
            break;
          }
        }
      }
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [showDemo]);

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (loading) return <LoadingScreen onDone={() => setLoading(false)} />;

  if (showDemo) {
    return (
      <div style={{ animation: 'fade-in-up 0.5s ease' }}>
        <button 
          onClick={() => setShowDemo(false)}
          style={{
            position: 'fixed',
            top: '20px',
            right: '20px',
            zIndex: 2000,
            background: 'var(--accent-red)',
            color: 'white',
            border: 'none',
            padding: '8px 16px',
            borderRadius: '4px',
            fontFamily: 'Orbitron,monospace',
            fontSize: '0.7rem',
            cursor: 'pointer',
            boxShadow: '0 0 15px rgba(255,59,59,0.3)'
          }}
        >
          [ EXIT DEMO ]
        </button>
        <DemoApp />
      </div>
    );
  }

  return (
    <div style={{ animation: 'fade-in-up 1s ease' }}>
      <Navigation activeSection={activeSection} />
      
      {/* Floating Demo Launcher */}
      <button 
        onClick={() => setShowDemo(true)}
        style={{
          position: 'fixed',
          bottom: '30px',
          left: '30px',
          zIndex: 100,
          background: 'var(--accent-amber)',
          color: 'var(--bg-deep)',
          border: 'none',
          padding: '12px 20px',
          borderRadius: '30px',
          fontFamily: 'Orbitron,monospace',
          fontSize: '0.8rem',
          fontWeight: 800,
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          boxShadow: '0 0 25px rgba(255,183,0,0.4)',
          animation: 'pulse-glow 2s infinite'
        }}
      >
        <Zap size={18} fill="currentColor" /> LAUNCH LIVE DEMO
      </button>

      <Hero onLaunchDemo={() => setShowDemo(true)} />
      <Features />
      <HowItWorks />
      <Simulator />
      <TechStack />
      <Research />
      <Team />
      <Timeline />
      <Chatbot />
      <Footer />

      {/* Back to Top Button */}
      {showScrollTop && (
        <button 
          onClick={scrollToTop}
          style={{
            position: 'fixed',
            bottom: '30px',
            right: '30px',
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            background: 'var(--accent-green)',
            border: 'none',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            boxShadow: '0 0 20px rgba(57,255,20,0.4)',
            zIndex: 100,
            animation: 'fade-in-up 0.3s ease'
          }}
        >
          <ChevronUp color="var(--bg-deep)" size={24} />
        </button>
      )}
    </div>
  );
}
