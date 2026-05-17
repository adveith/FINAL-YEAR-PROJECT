import { useState, useRef, useEffect } from 'react';
import { Send, AlertTriangle, CheckCircle2 } from 'lucide-react';

const FRUIT_DATABASE = {
  apple: {
    name: "Apple (Malus domestica)",
    image: "https://images.unsplash.com/photo-1560806887-1e4cd0b6bcd6?q=80&w=400&auto=format&fit=crop",
    color: "#ff5555",
    summary: "One of the most widely cultivated tree fruits, known for its high nutritional density and fiber content.",
    benefits: [
      "Heart Health: Rich in soluble fiber (pectin) which helps lower cholesterol.",
      "Blood Sugar: Flavonoids like quercetin may help prevent type 2 diabetes.",
      "Digestion: Acts as a natural prebiotic, supporting beneficial gut bacteria.",
      "Vitamin C: Boosts immunity and skin elasticity."
    ],
    nutrition: { calories: "52 kcal", fiber: "2.4g", sugars: "10g", vitC: "14% DV" },
    weeklyIntake: "3–5 medium apples (approx. 500-800g) per week is optimal for metabolic health.",
    storageTips: "Store in a cool, dark place. Refrigeration can extend life by up to 10x compared to room temperature.",
    shelfLife: {
      room: "5–7 days",
      fridge: "4–6 weeks",
      status: "Watch for soft spots or a mealy texture near the core."
    }
  },
  banana: {
    name: "Banana (Musa sapientum)",
    image: "https://images.unsplash.com/photo-1603833665314-be1ff1e64a9a?q=80&w=400&auto=format&fit=crop",
    color: "#ffb700",
    summary: "A tropical fruit rich in carbohydrates and potassium, essential for muscle and nerve function.",
    benefits: [
      "Energy Boost: High in natural sugars (sucrose, fructose, glucose) for instant energy.",
      "Kidney Health: High potassium content helps manage blood pressure and kidney function.",
      "Digestion: Contains resistant starch (when green) which aids gut health.",
      "Mood Regulation: Contains tryptophan, which the body converts to serotonin."
    ],
    nutrition: { calories: "89 kcal", fiber: "2.6g", sugars: "12g", potassium: "358mg" },
    weeklyIntake: "1 banana daily is safe and beneficial for most active individuals.",
    storageTips: "Store away from other fruits to prevent rapid ripening of neighbors (due to high ethylene).",
    shelfLife: {
      room: "2–5 days (ripe)",
      fridge: "5–7 days (skin will darken, but fruit remains good)",
      status: "Uneatable when fruit becomes liquidy or smells fermented."
    }
  },
  mango: {
    name: "Mango (Mangifera indica)",
    image: "https://images.unsplash.com/photo-1553279768-865429fa0078?q=80&w=400&auto=format&fit=crop",
    color: "#ffb700",
    summary: "The 'King of Fruits', a stone fruit known for its vibrant flavor and high antioxidant content.",
    benefits: [
      "Immune Support: Provides 67% of the DV for Vitamin C in one cup.",
      "Eye Health: Rich in Lutein and Zeaxanthin which protect the retina from blue light.",
      "Skin & Hair: High Vitamin A levels support sebum production and skin repair.",
      "Alkalizing Effect: Tartaric and malic acid help maintain the body's alkali reserve."
    ],
    nutrition: { calories: "60 kcal", fiber: "1.6g", sugars: "14g", vitA: "20% DV" },
    weeklyIntake: "2–3 servings (1 cup each) per week. High in sugar, so monitor intake if diabetic.",
    storageTips: "Ripen at room temperature; move to the fridge once soft to the touch.",
    shelfLife: {
      room: "3–5 days",
      fridge: "5–7 days",
      status: "Discard if skin shows deep black pits or signs of leakage."
    }
  },
  orange: {
    name: "Orange (Citrus sinensis)",
    image: "https://images.unsplash.com/photo-1547514701-42782101795e?q=80&w=400&auto=format&fit=crop",
    color: "#ffb700",
    summary: "A citrus powerhouse famous for its Vitamin C and refreshing acidity.",
    benefits: [
      "Immunity: High concentration of Vitamin C protects cells from oxidative damage.",
      "Skin Health: Helps in collagen production, reducing signs of aging.",
      "Anemia Prevention: Citric acid and Vitamin C improve the absorption of iron.",
      "Cholesterol: Contains hesperidin, which has been linked to lower blood pressure."
    ],
    nutrition: { calories: "47 kcal", fiber: "2.4g", sugars: "9g", vitC: "88% DV" },
    weeklyIntake: "3–4 whole oranges per week. Whole fruit is preferred over juice for the fiber content.",
    storageTips: "Can be kept at room temp but will last significantly longer in the crisper drawer.",
    shelfLife: {
      room: "1 week",
      fridge: "3 weeks",
      status: "Check for white or green mold patches on the skin."
    }
  }
};

function FruitDetailCard({ fruit }) {
  return (
    <div style={{
      background: 'var(--bg-panel)',
      borderRadius: 12,
      border: `1px solid ${fruit.color}40`,
      borderLeft: `6px solid ${fruit.color}`,
      overflow: 'hidden',
      marginTop: 12,
      animation: 'fade-in-up 0.4s ease',
      boxShadow: `0 10px 30px rgba(0,0,0,0.5), 0 0 20px ${fruit.color}10`
    }}>
      {/* Image with Analysis Overlay */}
      <div style={{ position: 'relative', width: '100%', height: 180, overflow: 'hidden' }}>
        <img src={fruit.image} alt={fruit.name} style={{ width: '100%', height: '100%', objectFit: 'cover', filter: 'contrast(1.1) brightness(0.9)' }} />
        
        {/* Scanning Grids & ROI */}
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(transparent 0%, rgba(0,0,0,0.4) 100%)' }} />
        <div style={{ position: 'absolute', inset: 10, border: `1px dashed ${fruit.color}60`, borderRadius: 4 }} />
        <div style={{ position: 'absolute', top: 20, left: 20, width: 20, height: 20, borderTop: `3px solid ${fruit.color}`, borderLeft: `3px solid ${fruit.color}` }} />
        <div style={{ position: 'absolute', top: 20, right: 20, width: 20, height: 20, borderTop: `3px solid ${fruit.color}`, borderRight: `3px solid ${fruit.color}` }} />
        <div style={{ position: 'absolute', bottom: 20, left: 20, width: 20, height: 20, borderBottom: `3px solid ${fruit.color}`, borderLeft: `3px solid ${fruit.color}` }} />
        <div style={{ position: 'absolute', bottom: 20, right: 20, width: 20, height: 20, borderBottom: `3px solid ${fruit.color}`, borderRight: `3px solid ${fruit.color}` }} />
        
        {/* Moving Scanline */}
        <div style={{ 
          position: 'absolute', top: '-100%', left: 0, right: 0, height: '2px', 
          background: `linear-gradient(90deg, transparent, ${fruit.color}, transparent)`,
          boxShadow: `0 0 15px ${fruit.color}`,
          animation: 'scanline 3s linear infinite'
        }} />

        {/* AI Tag */}
        <div style={{ position: 'absolute', top: 30, left: 30, background: fruit.color, color: '#000', fontSize: '0.6rem', fontWeight: 900, padding: '2px 6px', borderRadius: 2, fontFamily: 'Orbitron,monospace' }}>
          YOLOv8: {fruit.name.split(' ')[0]} [98.2%]
        </div>
      </div>

      <div style={{ padding: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: 12 }}>
          <div>
            <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '1.1rem', color: 'var(--text-primary)', fontWeight: 700 }}>{fruit.name}</div>
            <div style={{ fontSize: '0.7rem', color: fruit.color, opacity: 0.8, fontFamily: 'DM Mono,monospace' }}>SCIENTIFIC CLASSIFICATION ACTIVE</div>
          </div>
          <div style={{ background: 'rgba(57,255,20,0.1)', padding: '4px 8px', borderRadius: 4, border: '1px solid var(--accent-green)' }}>
            <div style={{ fontSize: '0.6rem', color: 'var(--accent-green)', textAlign: 'center' }}>HEALTH SCORE</div>
            <div style={{ fontSize: '0.85rem', color: 'var(--accent-green)', fontWeight: 900, textAlign: 'center' }}>88/100</div>
          </div>
        </div>

        <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: 1.6, marginBottom: 16 }}>{fruit.summary}</p>
        
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8, marginBottom: 20 }}>
          {Object.entries(fruit.nutrition).map(([k, v]) => (
            <div key={k} style={{ background: 'var(--bg-deep)', padding: '8px', borderRadius: 6, border: '1px solid rgba(255,255,255,0.03)' }}>
              <div style={{ fontSize: '0.55rem', color: 'var(--text-muted)', textTransform: 'uppercase', marginBottom: 2 }}>{k}</div>
              <div style={{ fontSize: '0.7rem', color: 'var(--text-primary)', fontFamily: 'DM Mono,monospace', fontWeight: 600 }}>{v}</div>
            </div>
          ))}
        </div>

        <div style={{ marginBottom: 20 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: '0.75rem', color: fruit.color, fontWeight: 700, marginBottom: 10, fontFamily: 'Orbitron,monospace', borderBottom: `1px solid ${fruit.color}20`, paddingBottom: 6 }}>
            <CheckCircle2 size={14} /> NUTRITIONAL BIO-DATA
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {fruit.benefits.map((b, i) => (
              <div key={i} style={{ display: 'flex', gap: 8, fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                <span style={{ color: fruit.color }}>•</span> {b}
              </div>
            ))}
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 12 }}>
          <div style={{ background: 'rgba(255,255,255,0.02)', padding: '12px', borderRadius: 8, border: '1px solid rgba(255,255,255,0.05)' }}>
            <div style={{ fontSize: '0.65rem', color: 'var(--text-muted)', marginBottom: 4 }}>WEEKLY INTAKE</div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-primary)', fontWeight: 600 }}>{fruit.weeklyIntake}</div>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.02)', padding: '12px', borderRadius: 8, border: '1px solid rgba(255,255,255,0.05)' }}>
            <div style={{ fontSize: '0.65rem', color: 'var(--text-muted)', marginBottom: 4 }}>SHELF STABILITY</div>
            <div style={{ fontSize: '0.75rem', color: 'var(--accent-teal)', fontWeight: 600 }}>{fruit.shelfLife.fridge} (FRIDGE)</div>
          </div>
        </div>
        
        <div style={{ background: 'rgba(255,183,0,0.08)', padding: '12px', borderRadius: 8, display: 'flex', gap: 10, alignItems: 'start' }}>
          <AlertTriangle size={16} color="var(--accent-amber)" style={{ marginTop: 2, flexShrink: 0 }} />
          <div>
            <div style={{ fontSize: '0.7rem', color: 'var(--accent-amber)', fontWeight: 800, marginBottom: 2 }}>SENSORY WARNING LOG</div>
            <div style={{ fontSize: '0.7rem', color: 'var(--accent-amber)', opacity: 0.9 }}>{fruit.shelfLife.status}</div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function Chatbot() {
  const [messages, setMessages] = useState([
    { role: 'assistant', content: "Welcome to the SmartFruit Final Year Project Hub. I've updated the database with high-resolution data for your presentation. Ask about any fruit or our project tech below.", timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const chatEndRef = useRef(null);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = (text = input) => {
    const trimmedInput = text.trim();
    if (!trimmedInput || loading) return;

    // Use functional update to ensure we have the latest state and prevent "down" issues
    setMessages(prev => [...prev, { 
      role: 'user', 
      content: trimmedInput, 
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      id: Date.now() 
    }]);
    
    setInput('');
    setLoading(true);

    setTimeout(() => {
      const lowerInput = trimmedInput.toLowerCase();
      let foundFruit = null;

      // 1. Check Fruit Database
      const fruitKey = Object.keys(FRUIT_DATABASE).find(k => lowerInput.includes(k));
      if (fruitKey) {
        foundFruit = FRUIT_DATABASE[fruitKey];
      }

      // 2. Generic responses
      let textResponse = null;
      if (!foundFruit) {
        if (lowerInput.includes('sensor') || lowerInput.includes('hardware')) {
          textResponse = "SmartFruit utilizes a multimodal sensor array: RGB Camera (Vision), MQ-series Ethylene Sensors (Gas), HX711 Load Cell (Weight), pH Electrode, Brix Optical Probe, and Turbidity sensors for dual-mode analysis.";
        } else if (lowerInput.includes('model') || lowerInput.includes('ai')) {
          textResponse = "Our AI pipeline uses YOLOv8 for detection, CNNs for ripeness analysis, and LightGBM for sensor fusion. We prioritize XAI (Explainable AI) using Grad-CAM visualization.";
        } else {
          textResponse = "I've processed your request. You can ask for technical specs or detailed fruit diagnostics (e.g., 'Tell me about Apple' or 'Nutrients in Mango').";
        }
      } else {
        textResponse = `Here is the technical dossier for ${foundFruit.name}:`;
      }

      setMessages(prev => [...prev, { 
        role: 'assistant', 
        content: textResponse, 
        fruitData: foundFruit,
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        id: Date.now() + 1
      }]);
      setLoading(false);
    }, 800);
  };

  return (
    <section id="chat" style={{ padding: '80px 24px' }}>
      <div className="section" style={{ maxWidth: 850, margin: '0 auto' }}>
        <div className="section-label">10 — Final Year Project Module</div>
        <h2 className="section-title">PROJECT KNOWLEDGE HUB</h2>
        <p className="section-sub">A premium, high-density diagnostic engine for fruit intelligence and system architecture.</p>

        <div className="card" style={{ height: 650, display: 'flex', flexDirection: 'column', padding: 0, overflow: 'hidden', border: '1px solid var(--accent-green)' }}>
          <div style={{ padding: '16px 20px', borderBottom: '1px solid var(--border-glow)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'var(--bg-panel)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <CheckCircle2 size={16} color="var(--accent-green)" />
              <span style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.85rem', color: 'var(--text-primary)' }}>SmartAI Diagnostics v3.0</span>
            </div>
            <button onClick={() => setMessages([{ role: 'assistant', content: "Hub re-initialized.", timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }])} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', fontSize: '0.7rem', cursor: 'pointer', fontFamily: 'DM Mono,monospace' }}>[ RESTART SYSTEM ]</button>
          </div>

          <div style={{ flex: 1, overflowY: 'auto', padding: '24px', display: 'flex', flexDirection: 'column', gap: 24 }}>
            {messages.map((m) => (
              <div key={m.id} style={{ alignSelf: m.role === 'user' ? 'flex-end' : 'flex-start', maxWidth: '90%', display: 'flex', flexDirection: 'column', gap: 6 }}>
                <div style={{ 
                  padding: '14px 18px', borderRadius: 12, fontFamily: 'DM Mono,monospace', fontSize: '0.85rem', lineHeight: 1.6,
                  background: m.role === 'user' ? 'var(--accent-green)' : 'var(--bg-panel)',
                  color: m.role === 'user' ? 'var(--bg-deep)' : 'var(--text-primary)',
                  border: m.role === 'user' ? 'none' : '1px solid var(--border-glow)',
                  boxShadow: m.role === 'user' ? '0 4px 15px rgba(57,255,20,0.2)' : 'none',
                  whiteSpace: 'pre-wrap'
                }}>{m.content}</div>
                {m.fruitData && <FruitDetailCard fruit={m.fruitData} />}
                <div style={{ fontSize: '0.65rem', color: 'var(--text-muted)', alignSelf: m.role === 'user' ? 'flex-end' : 'flex-start' }}>{m.timestamp}</div>
              </div>
            ))}
            {loading && <div style={{ alignSelf: 'flex-start', padding: '12px 20px', background: 'var(--bg-panel)', borderRadius: 12, border: '1px solid var(--border-glow)' }}>
              <div style={{ display: 'flex', gap: 5 }}>{[0,1,2].map(i => <div key={i} style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--accent-green)', animation: 'typing-dots 1.4s infinite ease-in-out', animationDelay: `${i*0.15}s` }} />)}</div>
            </div>}
            <div ref={chatEndRef} />
          </div>

          <div style={{ padding: '20px', background: 'var(--bg-panel)', borderTop: '1px solid var(--border-glow)' }}>
            <div style={{ display: 'flex', gap: 12 }}>
              <input type="text" value={input} onChange={e => setInput(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSend()} placeholder="Analyze fruit or project specs..." style={{ flex: 1, background: 'var(--bg-deep)', border: '1px solid var(--border-glow)', borderRadius: 8, padding: '14px 18px', color: 'var(--text-primary)', fontFamily: 'DM Mono,monospace', outline: 'none', fontSize: '0.9rem' }} />
              <button onClick={() => handleSend()} disabled={loading || !input.trim()} style={{ width: 50, height: 50, borderRadius: 8, background: 'var(--accent-green)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Send size={22} color="var(--bg-deep)" />
              </button>
            </div>
            <div style={{ display: 'flex', gap: 10, marginTop: 15, overflowX: 'auto', paddingBottom: 5 }}>
              {['Apple', 'Banana', 'Mango', 'Orange'].map(f => (
                <button key={f} onClick={() => handleSend(`Technical Dossier: ${f}`)} style={{ padding: '6px 14px', borderRadius: 20, background: 'rgba(57,255,20,0.08)', border: '1px solid var(--border-glow)', color: 'var(--accent-green)', fontSize: '0.72rem', cursor: 'pointer', whiteSpace: 'nowrap', fontFamily: 'DM Mono,monospace' }}>{f} Analysis</button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
