import { useRef, useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';

const timelineData = [
  { task: 'Requirements and Design', start: 0, duration: 6, phase: 'Planning', color: '#a855f7' },
  { task: 'Hardware Procurement', start: 7, duration: 6, phase: 'Hardware', color: '#ffb700' },
  { task: 'Sensor & Camera Interfacing', start: 14, duration: 13, phase: 'Hardware', color: '#ffb700' },
  { task: 'Fruit Image Dataset', start: 28, duration: 7, phase: 'Data', color: '#00e5cc' },
  { task: 'Juice Dataset', start: 28, duration: 7, phase: 'Data', color: '#00e5cc' },
  { task: 'YOLOv8 Training', start: 36, duration: 6, phase: 'Model', color: '#39ff14' },
  { task: 'CNN Ripeness Model', start: 36, duration: 13, phase: 'Model', color: '#39ff14' },
  { task: 'GradCAM Integration', start: 43, duration: 13, phase: 'Model', color: '#39ff14' },
  { task: 'Sensor Feature Engineering', start: 43, duration: 13, phase: 'Model', color: '#39ff14' },
  { task: 'Fusion Model Training', start: 57, duration: 13, phase: 'Model', color: '#39ff14' },
  { task: 'Jetson Edge Pipeline', start: 64, duration: 13, phase: 'Deployment', color: '#3b82f6' },
  { task: 'LCD UI Development', start: 71, duration: 13, phase: 'Deployment', color: '#3b82f6' },
  { task: 'Dashboard API & UI', start: 78, duration: 13, phase: 'Deployment', color: '#3b82f6' },
  { task: 'System Integration Testing', start: 92, duration: 13, phase: 'Integration', color: '#ef4444' },
  { task: 'Final Validation & Demo', start: 106, duration: 13, phase: 'Integration', color: '#ef4444' },
  { task: 'Documentation & Report', start: 106, duration: 20, phase: 'Integration', color: '#ef4444' },
];

export default function Timeline() {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true); }, { threshold: 0.1 });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  const CustomTooltip = ({ active, payload }) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <div style={{ background: '#0c1a0e', border: `1px solid ${data.color}`, padding: '8px 12px', borderRadius: 4 }}>
          <div style={{ fontFamily: 'Orbitron,monospace', fontSize: '0.75rem', color: data.color, marginBottom: 4 }}>{data.phase}</div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.8rem', color: '#fff' }}>{data.task}</div>
          <div style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: 4 }}>Duration: {data.duration} days</div>
        </div>
      );
    }
    return null;
  };

  return (
    <section id="timeline" ref={ref} style={{ padding: '80px 24px', background: 'rgba(12,26,14,0.4)' }}>
      <div className={`section ${visible ? 'section-visible' : 'section-hidden'}`} style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="section-label">09 — Project Gantt</div>
        <h2 className="section-title">PROJECT TIMELINE</h2>
        <p className="section-sub">Development roadmap from conceptualization to final deployment (Jan 2025 – May 2025).</p>

        <div className="card" style={{ padding: '40px 20px', overflowX: 'auto' }}>
          <div style={{ minWidth: 800, height: 500 }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={timelineData}
                layout="vertical"
                margin={{ top: 5, right: 30, left: 160, bottom: 20 }}
                barSize={12}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(57,255,20,0.05)" horizontal={false} />
                <XAxis 
                  type="number" 
                  hide 
                  domain={[0, 130]} 
                />
                <YAxis 
                  type="category" 
                  dataKey="task" 
                  stroke="var(--text-muted)"
                  fontSize={10}
                  fontFamily="DM Mono,monospace"
                  width={150}
                />
                <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(57,255,20,0.03)' }} />
                <Bar dataKey="duration" radius={[0, 4, 4, 0]}>
                  {timelineData.map((entry, index) => (
                    <Cell 
                      key={`cell-${index}`} 
                      fill={entry.color} 
                      fillOpacity={0.8}
                      stroke={entry.color}
                      strokeWidth={1}
                      // Simulate start position using stackOffset or just adding start to the value and using a range
                      // But for simplicity in recharts Bar with layout="vertical", we can use stackOffset="sign" or similar
                      // Or just use a custom shape. Let's use a simpler approach: data with [start, end]
                    />
                  ))}
                  {/* Recharts Bar doesn't natively support "floating" bars easily without a transparent base bar. */}
                </Bar>
                {/* Refined approach for Gantt: Two bars, one transparent for the start offset */}
                <Bar dataKey="start" stackId="a" fill="transparent" />
                <Bar dataKey="duration" stackId="a" radius={[0, 4, 4, 0]}>
                   {timelineData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
          
          {/* Phase Legend */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 16, marginTop: 24, justifyContent: 'center' }}>
            {[
              { label: 'Planning', color: '#a855f7' },
              { label: 'Hardware', color: '#ffb700' },
              { label: 'Data', color: '#00e5cc' },
              { label: 'Model', color: '#39ff14' },
              { label: 'Deployment', color: '#3b82f6' },
              { label: 'Integration', color: '#ef4444' },
            ].map(p => (
              <div key={p.label} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ width: 10, height: 10, borderRadius: 2, background: p.color }} />
                <span style={{ fontFamily: 'DM Mono,monospace', fontSize: '0.7rem', color: 'var(--text-muted)' }}>{p.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
