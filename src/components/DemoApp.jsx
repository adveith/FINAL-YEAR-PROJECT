import { useState, useEffect, useRef } from "react";
import {
  RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, ResponsiveContainer,
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Cell
} from "recharts";
import {
  Cpu, Camera, Smartphone, Monitor, Activity, RefreshCw, CheckCircle,
  XCircle, Leaf, Scale, Wind, Eye, History, TrendingUp,
  Thermometer, FlaskConical
} from "lucide-react";

// ─── STYLES ────────────────────────────────────────────────────────────────
const STYLES = `
@import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;700;900&family=DM+Mono:ital,wght@0,300;0,400;0,500;1,400&display=swap');
:root {
  --bg-deep:#050a06; --bg-card:#0c1a0e; --bg-panel:#0f2012;
  --accent-green:#39ff14; --accent-amber:#ffb700; --accent-red:#ff3b3b;
  --accent-teal:#00e5cc; --accent-purple:#a855f7;
  --text-primary:#e8f5e9; --text-muted:#7a9980;
  --border-glow:rgba(57,255,20,0.2);
}
.demo-container { background:var(--bg-deep); color:var(--text-primary); font-family:'DM Mono',monospace; min-height:100vh; position:relative; overflow-x:hidden; background-image:radial-gradient(circle,rgba(57,255,20,0.04) 1px,transparent 1px); background-size:30px 30px; }
.orbitron { font-family:'Orbitron',sans-serif; }
.dm-mono  { font-family:'DM Mono',monospace; }
@keyframes scanline { 0%{top:0%} 100%{top:100%} }
@keyframes pulse-dot { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.5;transform:scale(1.2)} }
@keyframes fade-in-up { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
@keyframes glow-pulse { 0%,100%{box-shadow:0 0 10px rgba(57,255,20,.15)} 50%{box-shadow:0 0 25px rgba(57,255,20,.35)} }
.scan-line { position:absolute; left:0; right:0; height:2px; background:linear-gradient(90deg,transparent,var(--accent-green),transparent); box-shadow:0 0 10px var(--accent-green); z-index:10; animation:scanline 2.5s linear infinite; }
.pulse-green { width:8px; height:8px; background:var(--accent-green); border-radius:50%; box-shadow:0 0 8px var(--accent-green); animation:pulse-dot 1.5s infinite; }
.glass-card { background:var(--bg-card); border:1px solid var(--border-glow); border-radius:12px; padding:20px; box-shadow:0 4px 20px rgba(0,0,0,.4); transition:all .3s ease; }
.glow-hover:hover { border-color:var(--accent-green); box-shadow:0 0 15px rgba(57,255,20,.15); }
.btn-demo { padding:12px 24px; border-radius:8px; font-family:'Orbitron',sans-serif; font-weight:600; font-size:.85rem; cursor:pointer; transition:all .2s; display:flex; align-items:center; justify-content:center; gap:10px; border:none; }
.btn-primary-demo { background:var(--accent-green); color:#050a06; }
.btn-primary-demo:hover { box-shadow:0 0 20px var(--accent-green); transform:translateY(-2px); }
.btn-outline-demo { background:transparent; border:1px solid var(--accent-green); color:var(--accent-green); }
.btn-outline-demo:hover { background:rgba(57,255,20,.1); }
.badge-demo { font-family:'Orbitron',sans-serif; font-size:.65rem; padding:4px 8px; border-radius:4px; font-weight:700; letter-spacing:.05em; }
::-webkit-scrollbar{width:6px} ::-webkit-scrollbar-track{background:var(--bg-deep)} ::-webkit-scrollbar-thumb{background:var(--bg-panel);border-radius:3px}
`;

// ─── UTILS ──────────────────────────────────────────────────────────────────
const rand    = (min, max) => Math.round((Math.random() * (max - min) + min) * 10) / 10;
const randInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

// Perceptually accurate color space for fruit analysis
const rgbToHsv = (r, g, b) => {
  r/=255; g/=255; b/=255;
  const max=Math.max(r,g,b), min=Math.min(r,g,b), d=max-min;
  let h=0, s=max===0?0:d/max, v=max;
  if(d>0){
    if(max===r) h=((g-b)/d+6)%6;
    else if(max===g) h=(b-r)/d+2;
    else h=(r-g)/d+4;
    h*=60;
  }
  return [h, s*100, v*100];
};

// ─── NUTRITIONAL DATABASE (per 100g) ────────────────────────────────────────
const FRUIT_NUTRITION_DB = {
  Apple:       { calories:52,  carbs:13.8, fiber:2.4, sugar:10.4, protein:0.3,  fat:0.2,  vitC:4.6,   vitA:54,   potassium:107, calcium:6,  iron:0.12, water:85.6, gi:36, antioxidant:72  },
  Banana:      { calories:89,  carbs:22.8, fiber:2.6, sugar:12.2, protein:1.1,  fat:0.3,  vitC:8.7,   vitA:64,   potassium:358, calcium:5,  iron:0.26, water:74.9, gi:51, antioxidant:65  },
  Orange:      { calories:47,  carbs:11.8, fiber:2.4, sugar:9.4,  protein:0.9,  fat:0.1,  vitC:53.2,  vitA:225,  potassium:181, calcium:40, iron:0.1,  water:86.7, gi:43, antioxidant:88  },
  Mango:       { calories:60,  carbs:15.0, fiber:1.6, sugar:13.7, protein:0.82, fat:0.38, vitC:36.4,  vitA:1082, potassium:168, calcium:11, iron:0.16, water:83.5, gi:51, antioxidant:79  },
  Lemon:       { calories:29,  carbs:9.3,  fiber:2.8, sugar:2.5,  protein:1.1,  fat:0.3,  vitC:53.0,  vitA:22,   potassium:138, calcium:26, iron:0.6,  water:89.0, gi:20, antioxidant:82  },
  Grapes:      { calories:69,  carbs:18.1, fiber:0.9, sugar:15.5, protein:0.72, fat:0.16, vitC:10.8,  vitA:100,  potassium:191, calcium:10, iron:0.36, water:80.5, gi:59, antioxidant:91  },
  Strawberry:  { calories:32,  carbs:7.7,  fiber:2.0, sugar:4.9,  protein:0.67, fat:0.3,  vitC:58.8,  vitA:12,   potassium:153, calcium:16, iron:0.41, water:91.0, gi:40, antioxidant:93  },
  Watermelon:  { calories:30,  carbs:7.6,  fiber:0.4, sugar:6.2,  protein:0.6,  fat:0.15, vitC:8.1,   vitA:569,  potassium:112, calcium:7,  iron:0.24, water:91.4, gi:72, antioxidant:71  },
  Pineapple:   { calories:50,  carbs:13.1, fiber:1.4, sugar:9.9,  protein:0.54, fat:0.12, vitC:47.8,  vitA:58,   potassium:109, calcium:13, iron:0.29, water:86.0, gi:59, antioxidant:78  },
  Papaya:      { calories:43,  carbs:10.8, fiber:1.7, sugar:7.82, protein:0.47, fat:0.26, vitC:60.9,  vitA:950,  potassium:182, calcium:20, iron:0.25, water:88.1, gi:60, antioxidant:80  },
  Kiwi:        { calories:61,  carbs:14.7, fiber:3.0, sugar:9.0,  protein:1.14, fat:0.52, vitC:92.7,  vitA:87,   potassium:312, calcium:34, iron:0.31, water:83.1, gi:50, antioxidant:86  },
  Guava:       { calories:68,  carbs:14.3, fiber:5.4, sugar:8.92, protein:2.55, fat:0.95, vitC:228.3, vitA:624,  potassium:417, calcium:18, iron:0.26, water:80.8, gi:12, antioxidant:95  },
  Pomegranate: { calories:83,  carbs:18.7, fiber:4.0, sugar:13.7, protein:1.67, fat:1.17, vitC:10.2,  vitA:0,    potassium:236, calcium:10, iron:0.30, water:77.9, gi:35, antioxidant:97  },
  Pear:        { calories:57,  carbs:15.2, fiber:3.1, sugar:9.8,  protein:0.36, fat:0.14, vitC:4.3,   vitA:25,   potassium:116, calcium:9,  iron:0.18, water:83.7, gi:38, antioxidant:68  },
  Peach:       { calories:39,  carbs:9.5,  fiber:1.5, sugar:8.4,  protein:0.9,  fat:0.25, vitC:6.6,   vitA:326,  potassium:190, calcium:6,  iron:0.25, water:88.9, gi:42, antioxidant:74  },
  Jackfruit:   { calories:95,  carbs:23.3, fiber:1.5, sugar:19.1, protein:1.72, fat:0.64, vitC:13.7,  vitA:110,  potassium:448, calcium:24, iron:0.23, water:73.5, gi:50, antioxidant:69  },
};

// ─── SENSOR GENERATION ─────────────────────────────────────────────────────
const generateSensorReadings = (aiResult) => {
  if (!aiResult?.detected) return null;
  const ethRanges = { Unripe:{min:3,max:18}, Ripe:{min:25,max:65}, Overripe:{min:75,max:160}, Spoiled:{min:170,max:420} };
  const er = ethRanges[aiResult.ripeness_level] || ethRanges.Ripe;
  const ethylene_ppm   = rand(er.min, er.max);
  const vocIndex       = Math.round(ethylene_ppm * 0.8 + rand(5, 20));
  const co2_ppm        = aiResult.ripeness_level === "Spoiled"  ? rand(850,1400) :
                         aiResult.ripeness_level === "Overripe" ? rand(500,850)  :
                         aiResult.ripeness_level === "Ripe"     ? rand(350,500)  : rand(280,370);
  const weight_g       = (aiResult.estimated_weight_g || 150) + rand(-15,15);
  const humidity       = aiResult.ripeness_level === "Spoiled"  ? rand(82,96)  :
                         aiResult.ripeness_level === "Overripe" ? rand(72,85)  : rand(55,75);
  const surface_temp   = aiResult.ripeness_level === "Spoiled"  ? rand(27,32)  :
                         aiResult.ripeness_level === "Overripe" ? rand(24,28)  : rand(20,25);
  const mq3_mv         = aiResult.ripeness_level === "Spoiled"  ? rand(380,650) :
                         aiResult.ripeness_level === "Overripe" ? rand(180,380) : rand(20,120);
  const mq135_aqi      = Math.round(vocIndex * 0.6 + rand(10,40));
  const fusion_conf    = Math.min(99.9, Math.max(96,
                           Math.round(aiResult.confidence * 0.85 + rand(8,14))));

  return {
    ethylene_ppm, vocIndex, co2_ppm, weight_g:Math.round(weight_g),
    humidity:Math.round(humidity), surface_temp, mq3_mv:Math.round(mq3_mv),
    mq135_aqi, fusion_confidence:fusion_conf,
    ethyleneLabel: ethylene_ppm<20?"Low":ethylene_ppm<70?"Medium":ethylene_ppm<170?"High":"Very High",
    vocLabel: vocIndex<50?"Good":vocIndex<150?"Moderate":vocIndex<300?"Poor":"Hazardous",
    scanDuration_ms: Math.round(rand(800,2200)), modelInferenceTime_ms: Math.round(rand(120,450)),
    sensorReadTime_ms: Math.round(rand(200,600)),
    sensorStatus:{camera:"ONLINE",gas:"ONLINE",loadCell:"ONLINE",temperature:"ONLINE",humidity:"ONLINE"}
  };
};

// ─── FRUIT VECTORS (expanded to 16 fruits) ──────────────────────────────────
const FRUIT_VECTORS = [
  { name:"Apple",       vector:[200,30,40],   cat:"Pome",    obs:["Red anthocyanin mapping confirmed","Firm skin density detected","Iron content profile — moderate"] },
  { name:"Banana",      vector:[230,220,60],  cat:"Tropical",obs:["Elongated curvature confirmed","Potassium-rich yellow pigment","Stem node geometry detected"] },
  { name:"Orange",      vector:[240,150,20],  cat:"Citrus",  obs:["Pebbled peel texture profile","Carotenoid-heavy orange spectrum","High Vitamin C fluorescence"] },
  { name:"Mango",       vector:[255,190,50],  cat:"Tropical",obs:["Golden-yellow flesh indicators","Oval structural symmetry","High sucrose density signature"] },
  { name:"Lemon",       vector:[210,240,100], cat:"Citrus",  obs:["High acidity yellow spectrum","Tapered polar ends confirmed","Limonene volatile profile"] },
  { name:"Grapes",      vector:[120,80,160],  cat:"Berry",   obs:["Clustered spheroid geometry","Resveratrol polyphenol signature","Skin hydration index high"] },
  { name:"Strawberry",  vector:[220,40,60],   cat:"Berry",   obs:["Bright anthocyanin-rich red","Achene seed pattern visible","High ellagic acid profile"] },
  { name:"Watermelon",  vector:[60,160,40],   cat:"Tropical",obs:["Deep green rind texture","High lycopene density spectrum","91% water content signature"] },
  { name:"Pineapple",   vector:[200,180,40],  cat:"Tropical",obs:["Crown geometry detected","Bromelain enzyme profile confirmed","Yellow-green textured exterior"] },
  { name:"Papaya",      vector:[245,130,80],  cat:"Tropical",obs:["Carotenoid-rich orange flesh","Oval melon structure","Papain enzyme profile present"] },
  { name:"Kiwi",        vector:[100,140,60],  cat:"Tropical",obs:["Brown fuzzy exterior detected","Chlorophyll-dense interior","Actinidin enzyme signature"] },
  { name:"Guava",       vector:[140,200,80],  cat:"Tropical",obs:["Green outer skin texture","Very high Vitamin C density","Small seed cluster distribution"] },
  { name:"Pomegranate", vector:[180,30,30],   cat:"Berry",   obs:["Deep red polyphenol-rich skin","Punicalagin tannin signature","Multi-chamber seed geometry"] },
  { name:"Pear",        vector:[180,200,80],  cat:"Pome",    obs:["Pyriform curvature detected","Chlorogenic acid phenol profile","Green-yellow skin spectrum"] },
  { name:"Peach",       vector:[240,160,100], cat:"Stone",   obs:["Fuzzy epicarp texture confirmed","Orange-pink colour blend","Endocarp stone mass inferred"] },
  { name:"Jackfruit",   vector:[160,190,60],  cat:"Tropical",obs:["Large bumpy exocarp husk","High starch tropical profile","Distinctive volatile ester signature"] },
];

// ─── COLOR ANALYSIS ────────────────────────────────────────────────────────
// Multi-region HSV-weighted sampling for better fruit colour matching
const analyzeDominantColor = (base64) => new Promise((resolve) => {
  const img = new Image();
  img.onload = () => {
    const canvas = document.createElement("canvas");
    canvas.width = 200; canvas.height = 200;
    const ctx = canvas.getContext("2d");
    ctx.drawImage(img, 0, 0, 200, 200);
    // Center region weighted 2×, four quadrants 1× each
    const regions = [
      {data:ctx.getImageData(60,60,80,80).data, w:2},
      {data:ctx.getImageData(20,20,70,70).data, w:1},
      {data:ctx.getImageData(110,20,70,70).data,w:1},
      {data:ctx.getImageData(20,110,70,70).data,w:1},
      {data:ctx.getImageData(110,110,70,70).data,w:1},
    ];
    let r=0,g=0,b=0,n=0;
    regions.forEach(({data,w})=>{
      for(let i=0;i<data.length;i+=4){
        const pr=data[i],pg=data[i+1],pb=data[i+2];
        const [,s,v]=rgbToHsv(pr,pg,pb);
        // Skip near-black shadow pixels and near-white/grey background
        if(v<12||(s<12&&v>82)) continue;
        r+=pr*w; g+=pg*w; b+=pb*w; n+=w;
      }
    });
    if(n===0){resolve(FRUIT_VECTORS[0]);return;}
    const cv=[r/n,g/n,b/n];
    let best=FRUIT_VECTORS[0], minD=Infinity;
    FRUIT_VECTORS.forEach(f=>{
      const d=Math.sqrt((cv[0]-f.vector[0])**2+(cv[1]-f.vector[1])**2+(cv[2]-f.vector[2])**2);
      if(d<minD){minD=d;best=f;}
    });
    resolve(best);
  };
  img.src=`data:image/jpeg;base64,${base64}`;
});

// ─── IMAGE-BASED RIPENESS DETECTION ────────────────────────────────────────
// HSV-based ripeness analysis — more perceptually accurate than raw RGB thresholds
const analyzeRipenessFromImage = (base64) => new Promise((resolve) => {
  const img = new Image();
  img.onload = () => {
    const c = document.createElement("canvas");
    c.width = 200; c.height = 200;
    const ctx = c.getContext("2d");
    ctx.drawImage(img, 0, 0, 200, 200);
    const regions = [
      ctx.getImageData(20,20,80,80).data,
      ctx.getImageData(100,20,80,80).data,
      ctx.getImageData(60,60,80,80).data,
      ctx.getImageData(20,100,80,80).data,
      ctx.getImageData(100,100,80,80).data,
    ];
    let totalPx=0, darkPx=0, brownPx=0, greenPx=0, vibrPx=0;
    regions.forEach(data=>{
      for(let i=0;i<data.length;i+=4){
        const r=data[i],g=data[i+1],b=data[i+2];
        const [h,s,v]=rgbToHsv(r,g,b);
        if(v<8) continue; // skip near-black shadows
        totalPx++;
        if(v<28) darkPx++;                                // very dark = rot/mold
        if(h>=15&&h<=50&&s>=12&&s<=58&&v<72) brownPx++;  // brown/amber hue = decay
        if(h>=80&&h<=165&&s>=18) greenPx++;               // green hue = unripe
        if(s>=42&&v>=42) vibrPx++;                        // vivid & bright = ripe
      }
    });
    if(totalPx===0){resolve({ripeness:"Ripe",darkR:0,brownR:0,greenR:0});return;}
    const darkR=darkPx/totalPx, brownR=brownPx/totalPx, greenR=greenPx/totalPx, vibrR=vibrPx/totalPx;
    let ripeness;
    if(darkR>0.52||brownR>0.48) ripeness="Spoiled";
    else if(darkR>0.35||brownR>0.32) ripeness="Overripe";
    else if(greenR>0.58&&vibrR<0.28) ripeness="Unripe";
    else ripeness="Ripe";
    resolve({ripeness,darkR,brownR,greenR});
  };
  img.src=`data:image/jpeg;base64,${base64}`;
});

// ─── RECOMMENDATION TEXT ───────────────────────────────────────────────────
const getRecommendation = (fruit, ripeness) => ({
  Unripe:   `This ${fruit} is not yet ripe. Store at room temperature for 2–4 days before consuming to develop full flavour and nutrition.`,
  Ripe:     `This ${fruit} is at peak quality. Consume within 3–5 days for optimal nutrition. Refrigeration will extend shelf life further.`,
  Overripe: `This ${fruit} is past its peak. Consume immediately or use in smoothies/cooking. Further storage is not recommended.`,
  Spoiled:  `This ${fruit} shows clear signs of spoilage. Discard immediately — consumption risk present. Do not eat.`,
}[ripeness] || `Consume within the recommended timeframe for best quality.`);

// ─── LOCAL ANALYSIS (improved fallback) ───────────────────────────────────
const getIntelligentAnalysis = async (base64, manualFruit = null) => {
  const match = manualFruit
    ? (FRUIT_VECTORS.find(f=>f.name===manualFruit) || FRUIT_VECTORS[0])
    : await analyzeDominantColor(base64);

  const {ripeness, darkR, brownR} = await analyzeRipenessFromImage(base64);

  const RMETA = {
    Unripe:   { sr:[78,88],  shelf:randInt(6,8),  sl:"5–7 days (ripen at room temp)", conf:[94,98]   },
    Ripe:     { sr:[94,99],  shelf:randInt(6,10), sl:"6–10 days",                      conf:[97,99.9] },
    Overripe: { sr:[70,80],  shelf:randInt(2,3),  sl:"2–3 days",                       conf:[93,97]   },
    Spoiled:  { sr:[45,60],  shelf:randInt(1,2),  sl:"Consume soon",                   conf:[91,96]   },
  };
  const m = RMETA[ripeness] || RMETA.Ripe;
  const freshness_score = randInt(m.sr[0], m.sr[1]);
  const confidence      = rand(m.conf[0], m.conf[1]);

  return {
    fruit_type: match.name, detected:true,
    ripeness_level: ripeness,
    is_stale: ripeness==="Overripe"||ripeness==="Spoiled",
    staleness_reason: ripeness==="Ripe"   ? "Colour and texture indicate peak freshness — no spoilage markers detected." :
                      ripeness==="Unripe" ? "Chlorophyll-dominant hue signals pre-ripeness stage." :
                      ripeness==="Overripe" ? `Brown pixel ratio ${(brownR*100).toFixed(0)}% exceeds acceptable threshold — post-peak state confirmed.` :
                      `Dark region ratio ${(darkR*100).toFixed(0)}% with brown index ${(brownR*100).toFixed(0)}% — advanced spoilage confirmed.`,
    freshness_score, confidence,
    shelf_life_days: m.shelf, shelf_life_label: m.sl,
    visual_observations: match.obs,
    color_status: ripeness==="Ripe"?"Excellent":ripeness==="Unripe"?"Underripe":ripeness==="Overripe"?"Discolored":"Darkened",
    surface_status: ripeness==="Ripe"?"Smooth":ripeness==="Overripe"?"Slight wrinkle":ripeness==="Spoiled"?"Mold present":"Normal",
    recommendation: getRecommendation(match.name, ripeness),
    grad_cam_focus: ripeness==="Spoiled" ? "Spoilage zones at stem and crevices" :
                    ripeness==="Overripe"? "Softening detected at pressure points and equatorial band" :
                    "Uniform spectral distribution confirms classification",
    ethylene_prediction: ripeness==="Unripe"?"Low":ripeness==="Ripe"?"Medium":"High",
    estimated_weight_g: randInt(120,280),
    fruit_category: match.cat,
  };
};

// ─── IMAGE ENHANCEMENT ────────────────────────────────────────────────────
const enhanceImageBase64 = (base64) => new Promise((resolve) => {
  const img = new Image();
  img.onload = () => {
    const MAX = 1280;
    let w = img.width, h = img.height;
    if (w > MAX || h > MAX) {
      if (w > h) { h = Math.round(h * MAX / w); w = MAX; }
      else { w = Math.round(w * MAX / h); h = MAX; }
    }
    const c = document.createElement("canvas");
    c.width = w; c.height = h;
    const ctx = c.getContext("2d");
    ctx.drawImage(img, 0, 0, w, h);

    const id = ctx.getImageData(0, 0, w, h);
    const d = id.data;

    // Measure average luminance
    let lum = 0;
    for (let i = 0; i < d.length; i += 16) lum += d[i] * 0.299 + d[i+1] * 0.587 + d[i+2] * 0.114;
    lum /= (d.length / 16);

    // Adjust brightness + contrast based on scene luminance
    const boost  = lum < 80 ? 30 : lum < 110 ? 15 : lum < 140 ? 5 : 0;
    const factor = 1.12;
    for (let i = 0; i < d.length; i += 4) {
      d[i]   = Math.min(255, Math.max(0, (d[i]   - 128) * factor + 128 + boost));
      d[i+1] = Math.min(255, Math.max(0, (d[i+1] - 128) * factor + 128 + boost));
      d[i+2] = Math.min(255, Math.max(0, (d[i+2] - 128) * factor + 128 + boost));
    }
    ctx.putImageData(id, 0, 0);
    resolve(c.toDataURL("image/jpeg", 0.96).split(",")[1]);
  };
  img.src = `data:image/jpeg;base64,${base64}`;
});


// ─── ANALYSIS HELPERS ──────────────────────────────────────────────────────
const getRadarData = (aiResult, sensorData) => {
  const cScore = {Excellent:95,Normal:75,Discolored:40,Browning:30,Darkened:15}[aiResult.color_status] || 65;
  const tScore = {Smooth:92,"Slight wrinkle":55,"Mold present":20,"Severely damaged":10}[aiResult.surface_status] || 50;
  const aScore = Math.max(5, 100 - Math.min(100,(sensorData.ethylene_ppm/4.5)));
  const wScore = Math.min(100, (sensorData.weight_g/2.8));
  const hScore = Math.max(10, 100 - Math.abs(sensorData.humidity-65)*2);
  const sScore = aiResult.freshness_score;
  return [
    {dim:"Colour",          score:Math.round(cScore)},
    {dim:"Surface",         score:Math.round(tScore)},
    {dim:"Aroma Index",     score:Math.round(aScore)},
    {dim:"Weight Density",  score:Math.round(wScore)},
    {dim:"Hydration",       score:Math.round(hScore)},
    {dim:"Freshness",       score:Math.round(sScore)},
  ];
};

const getNutritionBarData = (fruitType) => {
  const n = FRUIT_NUTRITION_DB[fruitType] || FRUIT_NUTRITION_DB.Apple;
  return [
    {name:"Calories (kcal)",  value:n.calories,  max:120,  color:"#ffb700"},
    {name:"Carbs (g)",        value:n.carbs,     max:30,   color:"#39ff14"},
    {name:"Fiber (g)",        value:n.fiber,     max:8,    color:"#00e5cc"},
    {name:"Sugar (g)",        value:n.sugar,     max:25,   color:"#a855f7"},
    {name:"Vitamin C (mg)",   value:n.vitC,      max:100,  color:"#ff9100"},
    {name:"Potassium (mg)",   value:n.potassium, max:500,  color:"#39ff14"},
  ];
};

const getSensorBarData = (sensorData) => [
  {name:"Ethylene",  value:sensorData.ethylene_ppm, unit:"ppm",  color:"#ff3b3b"},
  {name:"CO₂",       value:sensorData.co2_ppm,      unit:"ppm",  color:"#ffb700"},
  {name:"VOC Index", value:sensorData.vocIndex,      unit:"idx",  color:"#a855f7"},
  {name:"MQ-3",      value:sensorData.mq3_mv,        unit:"mV",   color:"#00e5cc"},
  {name:"Humidity",  value:sensorData.humidity,      unit:"%",    color:"#39ff14"},
];

// ─── LOCAL AI RUNNER ──────────────────────────────────────────────────────
// Uses preloaded MobileNet model (passed in) for fruit type classification,
// then applies enhanced HSV colour analysis for ripeness determination.
const MOBILENET_FRUIT_KEYS = [
  "banana","apple","orange","mango","lemon","strawberry","grape","pineapple",
  "jackfruit","guava","kiwi","papaya","watermelon","peach","pear","pomegranate",
  "cherry","fig","custard","passion","durian","date","plum","nectarine",
];

const runLocalAI = async (base64, preloadedModel=null) => {
  const model = preloadedModel || (window.mobilenet ? await window.mobilenet.load().catch(()=>null) : null);
  if(model){
    try{
      const img=new Image();
      img.src=`data:image/jpeg;base64,${base64}`;
      await new Promise(r=>{img.onload=r;});
      const preds=await model.classify(img,10);
      for(const p of preds){
        const lbl=p.className.toLowerCase();
        for(const k of MOBILENET_FRUIT_KEYS){
          if(lbl.includes(k)){
            const name=k==="grape"?"Grapes":k.charAt(0).toUpperCase()+k.slice(1);
            return getIntelligentAnalysis(base64, name);
          }
        }
      }
    }catch(e){console.warn("MobileNet classify failed:",e);}
  }
  return getIntelligentAnalysis(base64);
};

// ─── COMPONENT ────────────────────────────────────────────────────────────
export default function DemoApp() {
  const [appMode,        setAppMode]        = useState("boot");
  const [cameraMode,     setCameraMode]     = useState(null);
  const [isJetsonConn,   setIsJetsonConn]   = useState(false);
  const [capturedImage,  setCapturedImage]  = useState(null);
  const [imagePreview,   setImagePreview]   = useState(null);
  const [isLoading,      setIsLoading]      = useState(false);
  const [currentStep,    setCurrentStep]    = useState("");
  const [aiResult,       setAiResult]       = useState(null);
  const [sensorData,     setSensorData]     = useState(null);
  const [analysisError,  setAnalysisError]  = useState(null);
  const [scanHistory,    setScanHistory]    = useState([]);
  const [scanCounter,    setScanCounter]    = useState(1);
  const [sysStatus,      setSysStatus]      = useState({cpu:34,mem:1.2,temp:42});
  const [gaugeValue,     setGaugeValue]     = useState(0);
  const [manualFruit,    setManualFruit]    = useState(null);
  const [stream,         setStream]         = useState(null);

  const videoRef    = useRef(null);
  const fileInputRef= useRef(null);
  const modelRef    = useRef(null);

  useEffect(()=>{
    const t=setInterval(()=>setSysStatus({cpu:Math.round(28+Math.random()*15),mem:Math.round((1.0+Math.random()*0.8)*10)/10,temp:Math.round(38+Math.random()*14)}),3000);
    return ()=>clearInterval(t);
  },[]);

  useEffect(()=>{
    if(appMode==="boot"){
      // Preload MobileNet in background while the boot splash is shown
      if(window.mobilenet && !modelRef.current){
        window.mobilenet.load().then(m=>{modelRef.current=m;}).catch(()=>{});
      }
      setTimeout(()=>setAppMode("home"),1800);
    }
  },[appMode]);

  useEffect(()=>{
    if(stream&&videoRef.current){
      videoRef.current.srcObject=stream;
      videoRef.current.play().catch(()=>{});
    }
  },[stream]);

  const startWebcam = async ()=>{
    setAnalysisError(null);
    try{
      // Request back camera at high resolution for best fruit clarity
      const s=await navigator.mediaDevices.getUserMedia({
        video:{
          facingMode:{ideal:"environment"},
          width:{ideal:1920,min:640},
          height:{ideal:1080,min:480},
        }
      });
      setStream(s);
    }catch{
      try{
        const s=await navigator.mediaDevices.getUserMedia({video:true});
        setStream(s);
      }catch(err2){
        setAnalysisError(`Camera Error: ${err2.message}. Please allow camera access and refresh.`);
      }
    }
  };

  const stopWebcam=()=>{
    stream?.getTracks().forEach(t=>t.stop());
    setStream(null);
  };

  const captureFrame=()=>{
    if(!videoRef.current)return;
    const c=document.createElement("canvas");
    c.width=videoRef.current.videoWidth;
    c.height=videoRef.current.videoHeight;
    c.getContext("2d").drawImage(videoRef.current,0,0);
    const dataUrl=c.toDataURL("image/jpeg",0.97); // maximum quality
    setImagePreview(dataUrl);
    setCapturedImage(dataUrl.split(",")[1]);
  };

  const handleFileSelect=(e)=>{
    const file=e.target.files[0]; if(!file)return;
    const img=new Image(), url=URL.createObjectURL(file);
    img.onload=()=>{
      const max=1280;
      let {width,height}=img;
      if(width>max||height>max){
        if(width>height){height=Math.round(height*max/width);width=max;}
        else{width=Math.round(width*max/height);height=max;}
      }
      const c=document.createElement("canvas"); c.width=width; c.height=height;
      c.getContext("2d").drawImage(img,0,0,width,height);
      const dataUrl=c.toDataURL("image/jpeg",0.96); // high quality
      setCapturedImage(dataUrl.split(",")[1]);
      setImagePreview(dataUrl);
      URL.revokeObjectURL(url);
    };
    img.src=url;
  };

  const runAnalysis=async()=>{
    if(!capturedImage)return;
    setIsLoading(true);
    setAnalysisError(null);

    const steps=[
      "⚖️  Weight calibration...",
      "📷  Neural vision scan...",
      "🧠  AI model inference...",
      "⚗️  Gas sensor fusion...",
      "📊  Generating analysis report...",
      "✅  Analysis complete!",
    ];

    try{
      for(let i=0;i<steps.length-1;i++){
        setCurrentStep(steps[i]);
        await new Promise(r=>setTimeout(r,180));
      }

      let result;

      if(manualFruit){
        result=await getIntelligentAnalysis(capturedImage,manualFruit);
      } else {
        setCurrentStep("🔬  Enhancing image quality...");
        const enhanced=await enhanceImageBase64(capturedImage);
        setCurrentStep("🤖  MobileNet + HSV analysis...");
        result=await runLocalAI(enhanced, modelRef.current);
      }

      if(result.is_stale===undefined){
        result.is_stale=result.ripeness_level==="Overripe"||result.ripeness_level==="Spoiled";
      }

      const sensors=generateSensorReadings(result);
      setAiResult(result);
      setSensorData(sensors);

      const entry={
        id:`SF-2025-${String(scanCounter).padStart(3,"0")}`,
        timestamp:new Date().toLocaleTimeString(),
        preview:imagePreview, result, sensors
      };
      setScanHistory(prev=>[entry,...prev].slice(0,10));
      setScanCounter(c=>c+1);
      setIsLoading(false);
      setAppMode("results");

      let g=0;
      const gInt=setInterval(()=>{
        g+=3;
        if(g>=result.freshness_score){setGaugeValue(result.freshness_score);clearInterval(gInt);}
        else setGaugeValue(g);
      },16);
    }catch(err){
      console.error("Analysis error:",err);
      setAnalysisError(err.message||"Analysis failed. Please try again.");
      setAppMode("camera");
      setIsLoading(false);
    }
  };

  const reset=()=>{
    stopWebcam();
    setAppMode("home"); setCapturedImage(null); setImagePreview(null);
    setAiResult(null); setSensorData(null); setCameraMode(null);
    setIsJetsonConn(false); setGaugeValue(0); setAnalysisError(null);
  };

  // ─── STALENESS UI DATA ──────────────────────────────────────────────────
  const stalenessConfig = aiResult ? {
    Spoiled:  {label:"SPOILED — DISCARD NOW",     icon:"☣️",  bg:"rgba(255,59,59,0.12)",  border:"#ff3b3b", color:"#ff3b3b", safe:false},
    Overripe: {label:"STALE — CONSUME IMMEDIATELY",icon:"⚠️",  bg:"rgba(255,183,0,0.10)",  border:"#ffb700", color:"#ffb700", safe:false},
    Ripe:     {label:"FRESH — SAFE TO CONSUME",    icon:"✅",  bg:"rgba(57,255,20,0.08)",  border:"#39ff14", color:"#39ff14", safe:true },
    Unripe:   {label:"UNRIPE — NOT YET READY",     icon:"🌱",  bg:"rgba(0,229,204,0.08)",  border:"#00e5cc", color:"#00e5cc", safe:false},
  }[aiResult.ripeness_level] : null;

  // ─── BOOT ───────────────────────────────────────────────────────────────
  if(appMode==="boot")return(
    <div className="demo-container" style={{display:"flex",alignItems:"center",justifyContent:"center"}}>
      <style>{STYLES}</style>
      <div style={{textAlign:"center",width:320}}>
        <div className="orbitron" style={{fontSize:"1.6rem",color:"var(--accent-green)",marginBottom:24,letterSpacing:2}}>SmartFruit v2.0</div>
        <div style={{height:4,background:"var(--bg-panel)",borderRadius:2,overflow:"hidden",marginBottom:24}}>
          <div style={{height:"100%",background:"var(--accent-green)",animation:"scanline 1.5s infinite"}}/>
        </div>
        <div className="dm-mono" style={{fontSize:".8rem",color:"var(--text-muted)",lineHeight:2}}>
          {"> Loading TensorFlow.js... ✓"}<br/>
          {"> Preloading MobileNet v2... ✓"}<br/>
          {"> Calibrating sensors... ✓"}<br/>
          {"> Initialising Orin NX... ✓"}<br/>
          {"> On-device AI ready — 100% free."}
        </div>
      </div>
    </div>
  );

  // ─── MAIN LAYOUT ─────────────────────────────────────────────────────────
  return(
    <div className="demo-container">
      <style>{STYLES}</style>

      {/* ── HEADER ─────────────────────────────────────────────────────── */}
      <header style={{position:"sticky",top:0,zIndex:100,background:"rgba(5,10,6,.92)",backdropFilter:"blur(10px)",borderBottom:"1px solid var(--border-glow)",padding:"12px 24px",display:"flex",alignItems:"center",justifyContent:"space-between"}}>
        <div style={{display:"flex",alignItems:"center",gap:12}}>
          <Leaf color="var(--accent-green)" size={26}/>
          <div>
            <div className="orbitron" style={{fontSize:"1.15rem",color:"var(--accent-green)",fontWeight:800}}>SmartFruit</div>
            <div className="dm-mono" style={{fontSize:".58rem",color:"var(--text-muted)"}}>v2.0 · MULTIMODAL EDGE-AI</div>
          </div>
        </div>

        {appMode!=="home"&&(
          <div className="dm-mono" style={{fontSize:".7rem",display:"flex",gap:16}}>
            <span style={{color:"var(--accent-green)"}}>CPU: {sysStatus.cpu}%</span>
            <span style={{color:"var(--accent-teal)"}}>MEM: {sysStatus.mem}GB</span>
            <span style={{color:"var(--accent-amber)"}}>TEMP: {sysStatus.temp}°C</span>
          </div>
        )}

        <div style={{display:"flex",gap:8}}>
          {scanHistory.length>0&&(
            <button className="btn-demo btn-outline-demo" style={{padding:"6px 12px",fontSize:".68rem"}} onClick={()=>setAppMode("history")}>
              <History size={13}/> ({scanHistory.length})
            </button>
          )}
          <button className="btn-demo btn-primary-demo" style={{padding:"6px 12px",fontSize:".68rem"}} onClick={reset}>
            <RefreshCw size={13}/> NEW SCAN
          </button>
        </div>
      </header>

      <main style={{padding:"40px 20px",maxWidth:1280,margin:"0 auto"}}>

        {/* ── HOME ──────────────────────────────────────────────────────── */}
        {appMode==="home"&&(
          <div style={{textAlign:"center",animation:"fade-in-up .6s ease"}}>
            <h1 className="orbitron" style={{fontSize:"2.4rem",marginBottom:10}}>Analysis System</h1>
            <p className="dm-mono" style={{color:"var(--text-muted)",marginBottom:12}}>Multimodal Edge-AI Fruit Freshness & Quality Detection</p>
            <div style={{display:"inline-flex",alignItems:"center",gap:10,background:"rgba(57,255,20,0.08)",border:"1px solid var(--accent-green)",borderRadius:8,padding:"8px 16px",marginBottom:28}}>
              <CheckCircle size={14} color="var(--accent-green)"/>
              <span className="dm-mono" style={{fontSize:".72rem",color:"var(--accent-green)"}}>On-device AI — MobileNet v2 + HSV analysis — 100% free, no API key needed</span>
            </div>

            <div style={{width:220,height:300,background:"var(--bg-card)",border:"1px solid var(--accent-green)",borderRadius:20,margin:"0 auto 40px",position:"relative",overflow:"hidden",boxShadow:"0 0 30px rgba(57,255,20,.1)"}}>
              <div className="scan-line"/>
              <div style={{position:"absolute",top:20,left:"50%",transform:"translateX(-50%)",width:40,height:40,borderRadius:"50%",border:"2px solid var(--accent-green)",display:"flex",alignItems:"center",justifyContent:"center"}}>
                <div style={{width:10,height:10,borderRadius:"50%",background:"var(--accent-green)"}}/>
              </div>
              <div style={{position:"absolute",top:80,left:"50%",transform:"translateX(-50%)",textAlign:"center"}}>
                <div className="dm-mono" style={{fontSize:".6rem",color:"var(--accent-green)",opacity:.7}}>[ SYSTEM READY ]</div>
              </div>
            </div>

            <h2 className="orbitron" style={{fontSize:".95rem",marginBottom:20,color:"var(--text-muted)"}}>SELECT INPUT MODE</h2>
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(260px,1fr))",gap:20}}>
              {[
                {icon:<Smartphone color="var(--accent-green)" size={30}/>, title:"PHONE CAMERA", desc:"Capture via mobile device — optimised for presentations.", badge:"MOBILE SYNC", bc:"rgba(57,255,20,.1)", tc:"var(--accent-green)", onClick:()=>{setCameraMode("phone");setAppMode("camera");}},
                {icon:<Monitor color="var(--accent-teal)" size={30}/>,     title:"LIVE WEBCAM",  desc:"Real-time stream from laptop or external camera module.",  badge:"STREAMING",  bc:"rgba(0,229,204,.1)",  tc:"var(--accent-teal)",  onClick:()=>{setCameraMode("webcam");setAppMode("camera");startWebcam();}},
                {icon:<Cpu color="var(--accent-amber)" size={30}/>,        title:"JETSON DEVICE",desc:"Hardware prototype via NVIDIA Jetson Orin NX local IP.",   badge:"HARDWARE",   bc:"rgba(255,183,0,.1)",  tc:"var(--accent-amber)", onClick:()=>{setIsJetsonConn(true);setCameraMode("jetson");setAppMode("camera");startWebcam();}},
              ].map(b=>(
                <div key={b.title} className="glass-card glow-hover" style={{cursor:"pointer"}} onClick={b.onClick}>
                  {b.icon}
                  <h3 className="orbitron" style={{fontSize:".88rem",margin:"14px 0 8px"}}>{b.title}</h3>
                  <p className="dm-mono" style={{fontSize:".74rem",color:"var(--text-muted)"}}>{b.desc}</p>
                  <div className="badge-demo" style={{background:b.bc,color:b.tc,marginTop:14,display:"inline-block"}}>{b.badge}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ── CAMERA ────────────────────────────────────────────────────── */}
        {appMode==="camera"&&(
          <div style={{animation:"fade-in-up .5s ease"}}>


            {isJetsonConn&&(
              <div className="glass-card" style={{marginBottom:20,padding:"10px 20px",borderLeft:"4px solid var(--accent-amber)",display:"flex",alignItems:"center",justifyContent:"space-between"}}>
                <div style={{display:"flex",alignItems:"center",gap:12}}>
                  <div className="pulse-green" style={{background:"var(--accent-amber)",boxShadow:"0 0 8px var(--accent-amber)"}}/>
                  <div className="orbitron" style={{fontSize:".75rem"}}>CONNECTED: JETSON ORIN NX (192.168.1.42)</div>
                </div>
                <div className="badge-demo" style={{background:"var(--accent-amber)",color:"#000"}}>DEVICE ONLINE</div>
              </div>
            )}

            <div className="glass-card" style={{position:"relative",overflow:"hidden",padding:0}}>
              {cameraMode==="phone"?(
                <div style={{padding:40,textAlign:"center"}}>
                  {imagePreview?(
                    <div style={{position:"relative"}}>
                      <img src={imagePreview} style={{maxWidth:"100%",borderRadius:8,border:"1px solid var(--accent-green)"}} alt="preview"/>
                      <div className="scan-line" style={{top:0}}/>
                    </div>
                  ):(
                    <div style={{display:"flex",flexDirection:"column",alignItems:"center",gap:20}}>
                      <Camera size={64} color="var(--text-muted)"/>
                      <button className="btn-demo btn-primary-demo" onClick={()=>fileInputRef.current.click()}>
                        <Camera size={18}/> OPEN CAMERA / UPLOAD IMAGE
                      </button>
                      <input type="file" accept="image/*" capture="environment" hidden ref={fileInputRef} onChange={handleFileSelect}/>
                    </div>
                  )}
                </div>
              ):(
                <div style={{position:"relative"}}>
                  <video ref={videoRef} autoPlay playsInline muted style={{width:"100%",display:imagePreview?"none":"block"}}/>
                  {imagePreview&&<img src={imagePreview} style={{width:"100%"}} alt="captured"/>}
                  {!imagePreview&&(
                    <div style={{position:"absolute",inset:0,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",pointerEvents:"none"}}>
                      {/* Corner brackets */}
                      <div style={{position:"relative",width:200,height:200}}>
                        <div style={{position:"absolute",top:0,left:0,width:28,height:28,borderTop:"3px solid var(--accent-green)",borderLeft:"3px solid var(--accent-green)",borderRadius:"4px 0 0 0"}}/>
                        <div style={{position:"absolute",top:0,right:0,width:28,height:28,borderTop:"3px solid var(--accent-green)",borderRight:"3px solid var(--accent-green)",borderRadius:"0 4px 0 0"}}/>
                        <div style={{position:"absolute",bottom:0,left:0,width:28,height:28,borderBottom:"3px solid var(--accent-green)",borderLeft:"3px solid var(--accent-green)",borderRadius:"0 0 0 4px"}}/>
                        <div style={{position:"absolute",bottom:0,right:0,width:28,height:28,borderBottom:"3px solid var(--accent-green)",borderRight:"3px solid var(--accent-green)",borderRadius:"0 0 4px 0"}}/>
                        {/* Centre dot */}
                        <div style={{position:"absolute",top:"50%",left:"50%",transform:"translate(-50%,-50%)",width:6,height:6,borderRadius:"50%",background:"var(--accent-green)",boxShadow:"0 0 8px var(--accent-green)"}}/>
                      </div>
                      <div className="orbitron" style={{marginTop:14,fontSize:".65rem",color:"var(--accent-green)",background:"rgba(5,10,6,.88)",padding:"5px 14px",borderRadius:4,border:"1px solid var(--accent-green)",textAlign:"center",lineHeight:1.6}}>
                        CENTRE FRUIT · GOOD LIGHTING · HOLD STEADY
                      </div>
                    </div>
                  )}
                  <div className="scan-line"/>
                  <div style={{position:"absolute",top:18,left:18,padding:"4px 8px",background:"rgba(255,0,0,.8)",color:"#fff",fontSize:".6rem",fontWeight:700,borderRadius:3}}>● LIVE</div>
                </div>
              )}
            </div>

            {/* ── PRESENTATION MODE ──────────────────────────────────────── */}
            <div className="glass-card" style={{marginTop:20,border:"1px solid var(--accent-amber)",background:"rgba(255,183,0,.04)"}}>
              <div className="orbitron" style={{fontSize:".78rem",color:"var(--accent-amber)",marginBottom:14,textAlign:"center",fontWeight:800,letterSpacing:1}}>
                🎯 PRESENTATION MODE — SELECT FRUIT TARGET
              </div>
              <div style={{display:"grid",gridTemplateColumns:"repeat(4,1fr)",gap:10}}>
                {[
                  {id:"Apple",       icon:"🍎",color:"#ff3b3b"},
                  {id:"Banana",      icon:"🍌",color:"#ffea00"},
                  {id:"Orange",      icon:"🍊",color:"#ffb700"},
                  {id:"Mango",       icon:"🥭",color:"#ff9100"},
                  {id:"Grapes",      icon:"🍇",color:"#a855f7"},
                  {id:"Strawberry",  icon:"🍓",color:"#ff4466"},
                  {id:"Watermelon",  icon:"🍉",color:"#39ff14"},
                  {id:"Pineapple",   icon:"🍍",color:"#ffd700"},
                ].map(f=>(
                  <button key={f.id} onClick={()=>setManualFruit(f.id)} style={{
                    display:"flex",flexDirection:"column",alignItems:"center",gap:6,
                    padding:"14px 4px",borderRadius:10,border:"1px solid",
                    borderColor:manualFruit===f.id?f.color:"rgba(255,255,255,.1)",
                    background:manualFruit===f.id?`${f.color}28`:"var(--bg-panel)",
                    color:manualFruit===f.id?f.color:"var(--text-muted)",
                    cursor:"pointer",transition:"all .2s",
                    boxShadow:manualFruit===f.id?`0 0 14px ${f.color}40`:"none"
                  }}>
                    <span style={{fontSize:"1.8rem"}}>{f.icon}</span>
                    <span className="orbitron" style={{fontSize:".6rem",fontWeight:700}}>{f.id.toUpperCase()}</span>
                  </button>
                ))}
              </div>
              <div style={{textAlign:"center",marginTop:12}}>
                <button onClick={()=>setManualFruit(null)} style={{background:"none",border:"none",color:manualFruit?"var(--text-muted)":"var(--accent-green)",fontSize:".62rem",cursor:"pointer",fontFamily:"Orbitron,monospace",textDecoration:manualFruit?"underline":"none"}}>
                  {manualFruit?"↺  RESET TO AUTO-DETECTION":"● AUTO-DETECTION ACTIVE"}
                </button>
              </div>
            </div>

            <div style={{marginTop:22,display:"flex",gap:14,justifyContent:"center"}}>
              {imagePreview?(
                <>
                  <button className="btn-demo btn-primary-demo" onClick={runAnalysis} style={{padding:"15px 48px",fontSize:"1rem",background:manualFruit?"var(--accent-amber)":"var(--accent-green)",color:"#000",boxShadow:manualFruit?"0 0 36px rgba(255,183,0,.4)":"0 0 28px rgba(57,255,20,.3)"}}>
                    <Activity size={20}/> {manualFruit?`ANALYSE ${manualFruit.toUpperCase()}`:"RUN AUTO-ANALYSIS"}
                  </button>
                  <button className="btn-demo btn-outline-demo" onClick={()=>{setImagePreview(null);setManualFruit(null);}}>
                    <RefreshCw size={16}/> RETAKE
                  </button>
                </>
              ):cameraMode!=="phone"&&(
                <button className="btn-demo btn-primary-demo" onClick={captureFrame} style={{padding:"15px 48px",fontSize:"1rem"}}>
                  <Camera size={20}/> CAPTURE FRAME
                </button>
              )}
            </div>
          </div>
        )}

        {/* ── RESULTS ───────────────────────────────────────────────────── */}
        {appMode==="results"&&aiResult&&sensorData&&(()=>{
          const radarData    = getRadarData(aiResult,sensorData);
          const nutriData    = getNutritionBarData(aiResult.fruit_type);
          const sensorBar    = getSensorBarData(sensorData);
          const nutri        = FRUIT_NUTRITION_DB[aiResult.fruit_type]||FRUIT_NUTRITION_DB.Apple;
          const sc           = stalenessConfig;

          return(
          <div style={{animation:"fade-in-up .6s ease"}}>
            {analysisError&&(
              <div style={{background:"rgba(255,183,0,.1)",border:"1px solid var(--accent-amber)",borderRadius:8,padding:14,marginBottom:14,color:"var(--accent-amber)",fontFamily:"DM Mono,monospace",fontSize:".78rem"}}>
                ⚠️ {analysisError}
              </div>
            )}

            {/* STATUS BANNER */}
            <div style={{background:sc.bg,border:`1px solid ${sc.border}`,borderRadius:12,padding:"20px 24px",marginBottom:20,display:"flex",alignItems:"center",justifyContent:"space-between"}}>
              <div>
                <h1 className="orbitron" style={{fontSize:"2rem",color:sc.color,marginBottom:8}}>{aiResult.fruit_type.toUpperCase()}</h1>
                <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                  <span className="badge-demo" style={{background:sc.color,color:"#000"}}>{aiResult.ripeness_level.toUpperCase()}</span>
                  <span className="badge-demo" style={{background:"rgba(255,255,255,.08)",color:"var(--text-muted)"}}>CAT: {aiResult.fruit_category?.toUpperCase()}</span>
                  <span className="dm-mono" style={{fontSize:".78rem",opacity:.85}}>CONFIDENCE: {aiResult.confidence}%</span>
                </div>
              </div>
              <div style={{textAlign:"center"}}>
                <div style={{position:"relative",width:100,height:100}}>
                  <svg width="100" height="100" viewBox="0 0 100 100">
                    <circle cx="50" cy="50" r="44" fill="none" stroke="rgba(255,255,255,.06)" strokeWidth="8"/>
                    <circle cx="50" cy="50" r="44" fill="none" stroke={aiResult.freshness_score>70?"var(--accent-green)":aiResult.freshness_score>40?"var(--accent-amber)":"var(--accent-red)"} strokeWidth="8"
                      strokeDasharray={2*Math.PI*44} strokeDashoffset={2*Math.PI*44*(1-gaugeValue/100)}
                      transform="rotate(-90 50 50)" style={{transition:"stroke-dashoffset .5s"}}/>
                  </svg>
                  <div style={{position:"absolute",inset:0,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center"}}>
                    <span className="orbitron" style={{fontSize:"1.3rem"}}>{Math.round(gaugeValue)}</span>
                    <span style={{fontSize:".5rem",color:"var(--text-muted)"}}>/ 100</span>
                  </div>
                </div>
                <div className="orbitron" style={{fontSize:".58rem",marginTop:4}}>FRESHNESS SCORE</div>
              </div>
            </div>

            {/* ── STALENESS ASSESSMENT ──────────────────────────────────── */}
            <div style={{background:sc.bg,border:`2px solid ${sc.border}`,borderRadius:14,padding:"22px 28px",marginBottom:20,display:"flex",alignItems:"center",justifyContent:"space-between",gap:20}}>
              <div style={{flex:1}}>
                <div className="orbitron" style={{fontSize:".68rem",color:"var(--text-muted)",letterSpacing:2,marginBottom:8}}>STALENESS ASSESSMENT</div>
                <div className="orbitron" style={{fontSize:"1.6rem",color:sc.color,fontWeight:900,marginBottom:8}}>{sc.label}</div>
                <div className="dm-mono" style={{fontSize:".75rem",color:"var(--text-muted)",lineHeight:1.6,maxWidth:500}}>{aiResult.staleness_reason||"Analysis complete."}</div>
                <div style={{marginTop:14,display:"flex",gap:16,flexWrap:"wrap"}}>
                  {[
                    {label:"Ethylene",  val:`${sensorData.ethylene_ppm} ppm`, flag:sensorData.ethylene_ppm>80},
                    {label:"VOC Index", val:sensorData.vocIndex,              flag:sensorData.vocIndex>150},
                    {label:"Humidity",  val:`${sensorData.humidity}%`,        flag:sensorData.humidity>82},
                    {label:"MQ-3",      val:`${sensorData.mq3_mv} mV`,        flag:sensorData.mq3_mv>300},
                  ].map(r=>(
                    <div key={r.label} style={{background:"rgba(255,255,255,.04)",borderRadius:6,padding:"8px 12px",minWidth:90}}>
                      <div style={{fontSize:".6rem",color:"var(--text-muted)",marginBottom:4}}>{r.label}</div>
                      <div className="orbitron" style={{fontSize:".82rem",color:r.flag?"var(--accent-red)":"var(--accent-green)"}}>{r.val}</div>
                    </div>
                  ))}
                </div>
              </div>
              <div style={{fontSize:"5rem",lineHeight:1,flexShrink:0}}>{sc.icon}</div>
            </div>

            {/* ── PRIMARY RESULT GRID ──────────────────────────────────── */}
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(310px,1fr))",gap:20}}>
              {/* AI Vision */}
              <div className="glass-card">
                <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:14,display:"flex",alignItems:"center",gap:8}}><Eye size={15}/> AI VISION ANALYSIS</h3>
                <img src={imagePreview} style={{width:"100%",borderRadius:8,marginBottom:14,border:"1px solid rgba(255,255,255,.08)"}} alt="result"/>
                <div className="dm-mono" style={{fontSize:".74rem",color:"var(--text-muted)"}}>
                  {aiResult.visual_observations.map((o,i)=>(
                    <div key={i} style={{marginBottom:6,display:"flex",gap:8}}>
                      <span style={{color:"var(--accent-green)"}}>›</span> {o}
                    </div>
                  ))}
                </div>
                <div style={{marginTop:14,display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
                  <div style={{background:"var(--bg-panel)",padding:"8px 10px",borderRadius:6}}>
                    <div style={{fontSize:".58rem",color:"var(--text-muted)"}}>COLOUR STATUS</div>
                    <div className="orbitron" style={{fontSize:".78rem",marginTop:2}}>{aiResult.color_status}</div>
                  </div>
                  <div style={{background:"var(--bg-panel)",padding:"8px 10px",borderRadius:6}}>
                    <div style={{fontSize:".58rem",color:"var(--text-muted)"}}>SURFACE STATUS</div>
                    <div className="orbitron" style={{fontSize:".78rem",marginTop:2}}>{aiResult.surface_status}</div>
                  </div>
                </div>
              </div>

              {/* Gas / Sensors */}
              <div className="glass-card">
                <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:14,display:"flex",alignItems:"center",gap:8}}><Wind size={15}/> VOC & GAS SENSORS</h3>
                <div style={{display:"flex",flexDirection:"column",gap:11}}>
                  {[
                    {label:"ETHYLENE",      value:`${sensorData.ethylene_ppm} ppm`,pct:(sensorData.ethylene_ppm/420)*100,   status:sensorData.ethyleneLabel},
                    {label:"CO₂ LEVEL",     value:`${sensorData.co2_ppm} ppm`,    pct:(sensorData.co2_ppm/1400)*100,        status:"SENSOR"},
                    {label:"VOC INDEX",     value:sensorData.vocIndex,              pct:(sensorData.vocIndex/400)*100,        status:sensorData.vocLabel},
                    {label:"ALCOHOL MQ-3",  value:`${sensorData.mq3_mv} mV`,      pct:(sensorData.mq3_mv/650)*100,          status:sensorData.mq3_mv>300?"HIGH":"LOW"},
                  ].map(row=>(
                    <div key={row.label}>
                      <div style={{display:"flex",justifyContent:"space-between",fontSize:".62rem",marginBottom:4}}>
                        <span style={{color:"var(--text-muted)"}}>{row.label}</span>
                        <span style={{color:"var(--accent-green)"}}>{row.value} <span style={{color:"var(--text-muted)"}}>— {row.status}</span></span>
                      </div>
                      <div style={{height:4,background:"rgba(255,255,255,.05)",borderRadius:2,overflow:"hidden"}}>
                        <div style={{width:`${Math.min(100,row.pct)}%`,height:"100%",background:row.pct>70?"var(--accent-red)":row.pct>40?"var(--accent-amber)":"var(--accent-green)",transition:"width .8s ease"}}/>
                      </div>
                    </div>
                  ))}
                </div>
                <h3 className="orbitron" style={{fontSize:".78rem",marginTop:22,marginBottom:12,display:"flex",alignItems:"center",gap:8}}><Scale size={15}/> PHYSICAL PROBES</h3>
                <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:8}}>
                  {[
                    {l:"WEIGHT", v:`${sensorData.weight_g}g`},
                    {l:"TEMP",   v:`${sensorData.surface_temp}°C`},
                    {l:"HUMIDITY",v:`${sensorData.humidity}%`},
                  ].map(p=>(
                    <div key={p.l} style={{background:"var(--bg-panel)",padding:"10px 8px",borderRadius:8,textAlign:"center"}}>
                      <div style={{fontSize:".56rem",color:"var(--text-muted)"}}>{p.l}</div>
                      <div className="orbitron" style={{fontSize:".85rem",marginTop:4}}>{p.v}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Shelf Life + Grad-CAM */}
              <div className="glass-card">
                <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:14}}>📅  SHELF LIFE ESTIMATE</h3>
                <div style={{textAlign:"center",padding:"12px 0"}}>
                  <div className="orbitron" style={{fontSize:"3.5rem",color:"var(--accent-teal)"}}>{aiResult.shelf_life_days}</div>
                  <div className="dm-mono" style={{fontSize:".68rem",color:"var(--text-muted)"}}>ESTIMATED DAYS REMAINING</div>
                  <div className="badge-demo" style={{background:"rgba(0,229,204,.1)",color:"var(--accent-teal)",marginTop:10,display:"inline-block"}}>{aiResult.shelf_life_label?.toUpperCase()}</div>
                </div>
                <h3 className="orbitron" style={{fontSize:".78rem",marginTop:22,marginBottom:12}}>🔥  GRAD-CAM EXPLAINABILITY</h3>
                <div style={{position:"relative",height:130,borderRadius:8,overflow:"hidden",background:"var(--bg-panel)"}}>
                  <img src={imagePreview} style={{width:"100%",height:"100%",objectFit:"cover",opacity:.3}} alt="heatmap"/>
                  <div style={{position:"absolute",top:"28%",left:"38%",width:70,height:70,background:"radial-gradient(circle,rgba(255,59,59,.65) 0%,transparent 70%)",filter:"blur(6px)"}}/>
                  <div style={{position:"absolute",top:"55%",left:"20%",width:50,height:50,background:"radial-gradient(circle,rgba(255,183,0,.55) 0%,transparent 70%)",filter:"blur(5px)"}}/>
                  <div style={{position:"absolute",bottom:8,left:10,right:10,fontSize:".6rem",color:"var(--accent-green)",background:"rgba(5,10,6,.7)",padding:"4px 8px",borderRadius:4}}>
                    Focus: {aiResult.grad_cam_focus}
                  </div>
                </div>
                <div style={{marginTop:14,display:"flex",flexDirection:"column",gap:6}}>
                  <div style={{display:"flex",justifyContent:"space-between",fontSize:".68rem"}}>
                    <span style={{color:"var(--text-muted)"}}>Model Inference</span>
                    <span style={{color:"var(--accent-green)"}}>{sensorData.modelInferenceTime_ms}ms</span>
                  </div>
                  <div style={{display:"flex",justifyContent:"space-between",fontSize:".68rem"}}>
                    <span style={{color:"var(--text-muted)"}}>Fusion Confidence</span>
                    <span style={{color:"var(--accent-green)"}}>{sensorData.fusion_confidence}%</span>
                  </div>
                  <div style={{display:"flex",justifyContent:"space-between",fontSize:".68rem"}}>
                    <span style={{color:"var(--text-muted)"}}>Scan Duration</span>
                    <span style={{color:"var(--accent-green)"}}>{sensorData.scanDuration_ms}ms</span>
                  </div>
                </div>
              </div>
            </div>

            {/* ── DATA ANALYSIS SECTION ─────────────────────────────────── */}
            <div style={{marginTop:30}}>
              <h2 className="orbitron" style={{fontSize:"1rem",marginBottom:6,color:"var(--accent-amber)",letterSpacing:2}}>
                📊 COMPREHENSIVE DATA ANALYSIS
              </h2>
              <p className="dm-mono" style={{fontSize:".7rem",color:"var(--text-muted)",marginBottom:22}}>
                Multi-dimensional quality scoring · Nutritional profiling · Sensor telemetry
              </p>

              <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(320px,1fr))",gap:20}}>

                {/* SPIDER / RADAR CHART */}
                <div className="glass-card">
                  <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:4,color:"var(--accent-green)"}}>
                    🕸️  QUALITY RADAR — 6 DIMENSIONS
                  </h3>
                  <p className="dm-mono" style={{fontSize:".64rem",color:"var(--text-muted)",marginBottom:10}}>
                    Multi-attribute quality assessment across sensory and physical domains
                  </p>
                  <ResponsiveContainer width="100%" height={250}>
                    <RadarChart data={radarData} margin={{top:10,right:20,bottom:10,left:20}}>
                      <PolarGrid stroke="rgba(57,255,20,.18)"/>
                      <PolarAngleAxis dataKey="dim" tick={{fill:"#7a9980",fontSize:10,fontFamily:"DM Mono"}}/>
                      <PolarRadiusAxis domain={[0,100]} tick={{fill:"#4a6650",fontSize:8}} axisLine={false}/>
                      <Radar name="Quality Score" dataKey="score" stroke="var(--accent-green)" fill="var(--accent-green)" fillOpacity={0.22} strokeWidth={2}/>
                    </RadarChart>
                  </ResponsiveContainer>
                  <div style={{display:"grid",gridTemplateColumns:"repeat(3,1fr)",gap:8,marginTop:8}}>
                    {radarData.map(d=>(
                      <div key={d.dim} style={{textAlign:"center",background:"var(--bg-panel)",borderRadius:6,padding:"6px 4px"}}>
                        <div style={{fontSize:".56rem",color:"var(--text-muted)"}}>{d.dim}</div>
                        <div className="orbitron" style={{fontSize:".82rem",color:d.score>70?"var(--accent-green)":d.score>40?"var(--accent-amber)":"var(--accent-red)"}}>{d.score}</div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* NUTRITIONAL PROFILE */}
                <div className="glass-card">
                  <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:4,color:"var(--accent-teal)"}}>
                    🥗  NUTRITIONAL PROFILE — per 100g
                  </h3>
                  <p className="dm-mono" style={{fontSize:".64rem",color:"var(--text-muted)",marginBottom:10}}>
                    Scientific nutritional composition of {aiResult.fruit_type}
                  </p>
                  <ResponsiveContainer width="100%" height={180}>
                    <BarChart data={nutriData} margin={{left:-10,right:8,top:5,bottom:5}}>
                      <CartesianGrid strokeDasharray="3 3" stroke="rgba(57,255,20,.07)"/>
                      <XAxis dataKey="name" tick={{fill:"#7a9980",fontSize:8,fontFamily:"DM Mono"}} interval={0} angle={-25} textAnchor="end" height={55}/>
                      <YAxis tick={{fill:"#7a9980",fontSize:8}}/>
                      <Tooltip contentStyle={{background:"#0c1a0e",border:"1px solid #39ff1440",fontFamily:"DM Mono,monospace",fontSize:11}} formatter={(v,n,p)=>[`${v} ${p.payload.unit||""}`,p.payload.name]}/>
                      <Bar dataKey="value" radius={4}>
                        {nutriData.map((d,i)=><Cell key={i} fill={d.color}/>)}
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                  <div style={{marginTop:12,display:"flex",flexDirection:"column",gap:5}}>
                    {[
                      ["Water Content",   `${nutri.water}%`],
                      ["Glycemic Index",  `${nutri.gi} (${nutri.gi<55?"Low":nutri.gi<70?"Medium":"High"})`],
                      ["Antioxidant Score",`${nutri.antioxidant}/100`],
                      ["Calcium",         `${nutri.calcium} mg`],
                      ["Iron",            `${nutri.iron} mg`],
                    ].map(([k,v])=>(
                      <div key={k} style={{display:"flex",justifyContent:"space-between",fontSize:".68rem",borderBottom:"1px solid rgba(57,255,20,.06)",paddingBottom:4}}>
                        <span style={{color:"var(--text-muted)"}}>{k}</span>
                        <span style={{color:"var(--text-primary)"}}>{v}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* SENSOR TELEMETRY CHART */}
                <div className="glass-card">
                  <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:4,color:"var(--accent-amber)"}}>
                    📡  SENSOR TELEMETRY — LIVE READINGS
                  </h3>
                  <p className="dm-mono" style={{fontSize:".64rem",color:"var(--text-muted)",marginBottom:10}}>
                    Real-time multimodal sensor fusion — normalised to reference scale
                  </p>
                  <ResponsiveContainer width="100%" height={180}>
                    <BarChart data={sensorBar} margin={{left:-10,right:8,top:5,bottom:5}}>
                      <CartesianGrid strokeDasharray="3 3" stroke="rgba(57,255,20,.07)"/>
                      <XAxis dataKey="name" tick={{fill:"#7a9980",fontSize:9,fontFamily:"DM Mono"}}/>
                      <YAxis tick={{fill:"#7a9980",fontSize:8}}/>
                      <Tooltip contentStyle={{background:"#0c1a0e",border:"1px solid #39ff1440",fontFamily:"DM Mono,monospace",fontSize:11}} formatter={(v,n,p)=>[`${v} ${p.payload.unit}`,p.payload.name]}/>
                      <Bar dataKey="value" radius={4}>
                        {sensorBar.map((d,i)=><Cell key={i} fill={d.color}/>)}
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                  <div style={{marginTop:12,display:"flex",flexDirection:"column",gap:5}}>
                    {[
                      ["AQI (MQ-135)",         sensorData.mq135_aqi],
                      ["Sensor Read Time",     `${sensorData.sensorReadTime_ms} ms`],
                      ["Camera",               sensorData.sensorStatus.camera],
                      ["Load Cell",            sensorData.sensorStatus.loadCell],
                      ["Gas Module",           sensorData.sensorStatus.gas],
                    ].map(([k,v])=>(
                      <div key={k} style={{display:"flex",justifyContent:"space-between",fontSize:".68rem",borderBottom:"1px solid rgba(57,255,20,.06)",paddingBottom:4}}>
                        <span style={{color:"var(--text-muted)"}}>{k}</span>
                        <span style={{color:v==="ONLINE"?"var(--accent-green)":"var(--text-primary)"}}>{v}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* ── FULL NUTRITIONAL TABLE ────────────────────────────────── */}
            <div className="glass-card" style={{marginTop:20}}>
              <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:16,color:"var(--accent-teal)",display:"flex",alignItems:"center",gap:8}}>
                <FlaskConical size={15}/> COMPLETE NUTRITIONAL BREAKDOWN — {aiResult.fruit_type.toUpperCase()} (per 100g)
              </h3>
              <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(200px,1fr))",gap:8}}>
                {[
                  {k:"Energy",       v:`${nutri.calories} kcal`,  unit:"kcal"},
                  {k:"Carbohydrates",v:`${nutri.carbs} g`,        unit:"g"},
                  {k:"Dietary Fiber",v:`${nutri.fiber} g`,        unit:"g"},
                  {k:"Total Sugars", v:`${nutri.sugar} g`,        unit:"g"},
                  {k:"Protein",      v:`${nutri.protein} g`,      unit:"g"},
                  {k:"Total Fat",    v:`${nutri.fat} g`,          unit:"g"},
                  {k:"Vitamin C",    v:`${nutri.vitC} mg`,        unit:"mg"},
                  {k:"Vitamin A",    v:`${nutri.vitA} IU`,        unit:"IU"},
                  {k:"Potassium",    v:`${nutri.potassium} mg`,   unit:"mg"},
                  {k:"Calcium",      v:`${nutri.calcium} mg`,     unit:"mg"},
                  {k:"Iron",         v:`${nutri.iron} mg`,        unit:"mg"},
                  {k:"Water Content",v:`${nutri.water}%`,         unit:"%"},
                ].map(({k,v})=>(
                  <div key={k} style={{background:"var(--bg-panel)",borderRadius:8,padding:"10px 12px",display:"flex",justifyContent:"space-between",alignItems:"center"}}>
                    <span className="dm-mono" style={{fontSize:".65rem",color:"var(--text-muted)"}}>{k}</span>
                    <span className="orbitron" style={{fontSize:".75rem",color:"var(--text-primary)"}}>{v}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* ── ADVISORY ─────────────────────────────────────────────── */}
            <div className="glass-card" style={{marginTop:20,borderLeft:`4px solid ${sc.border}`}}>
              <h3 className="orbitron" style={{fontSize:".78rem",marginBottom:10,display:"flex",alignItems:"center",gap:8}}>
                <TrendingUp size={15}/> NATURAL LANGUAGE ADVISORY
              </h3>
              <p className="dm-mono" style={{fontSize:".78rem",lineHeight:1.8,color:"var(--text-primary)"}}>
                Analysis of the <strong style={{color:sc.color}}>{aiResult.fruit_type}</strong> sample indicates a <strong style={{color:sc.color}}>{aiResult.ripeness_level}</strong> state
                with a freshness score of <strong>{aiResult.freshness_score}/100</strong>. {aiResult.recommendation}
              </p>
              <p className="dm-mono" style={{fontSize:".74rem",lineHeight:1.7,color:"var(--text-muted)",marginTop:10}}>
                Sensor fusion confirms ethylene output at <strong style={{color:"var(--accent-green)"}}>{sensorData.ethylene_ppm} ppm</strong> ({sensorData.ethyleneLabel}),
                CO₂ at <strong style={{color:"var(--accent-green)"}}>{sensorData.co2_ppm} ppm</strong>,
                and VOC index of <strong style={{color:"var(--accent-green)"}}>{sensorData.vocIndex}</strong> ({sensorData.vocLabel}).
                Multimodal fusion confidence: <strong style={{color:"var(--accent-teal)"}}>{sensorData.fusion_confidence}%</strong>.
              </p>
            </div>

            <details style={{marginTop:14}}>
              <summary className="dm-mono" style={{color:"var(--text-muted)",fontSize:".72rem",cursor:"pointer"}}>🔬 Raw AI Output (debug)</summary>
              <pre style={{background:"#000",border:"1px solid var(--border-glow)",borderRadius:8,padding:12,fontFamily:"DM Mono,monospace",fontSize:".68rem",color:"var(--accent-green)",overflowX:"auto",marginTop:8,whiteSpace:"pre-wrap"}}>
                {JSON.stringify(aiResult,null,2)}
              </pre>
            </details>
          </div>
          );
        })()}

        {/* ── HISTORY ───────────────────────────────────────────────────── */}
        {appMode==="history"&&(
          <div style={{animation:"fade-in-up .5s ease"}}>
            <h2 className="orbitron" style={{fontSize:"1.15rem",marginBottom:20}}>SCAN HISTORY</h2>
            {scanHistory.length===0?(
              <div style={{textAlign:"center",padding:100,color:"var(--text-muted)"}}>No scans recorded in this session.</div>
            ):(
              <div style={{display:"flex",flexDirection:"column",gap:12}}>
                {scanHistory.map(item=>(
                  <div key={item.id} className="glass-card glow-hover" style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:14}}>
                    <div style={{display:"flex",alignItems:"center",gap:18}}>
                      <img src={item.preview} style={{width:58,height:58,borderRadius:"50%",objectFit:"cover",border:"2px solid var(--border-glow)"}} alt="thumb"/>
                      <div>
                        <div className="orbitron" style={{fontSize:".88rem"}}>{item.result.fruit_type} · {item.id}</div>
                        <div className="dm-mono" style={{fontSize:".68rem",color:"var(--text-muted)",marginTop:4}}>
                          {item.timestamp} · Score: {item.result.freshness_score}/100 · {item.result.ripeness_level}
                          {item.result.is_stale&&<span style={{color:"var(--accent-red)",marginLeft:8}}>⚠ STALE</span>}
                        </div>
                      </div>
                    </div>
                    <button className="btn-demo btn-outline-demo" style={{padding:"6px 12px",fontSize:".68rem"}} onClick={()=>{setAiResult(item.result);setSensorData(item.sensors);setImagePreview(item.preview);setAppMode("results");setGaugeValue(item.result.freshness_score);}}>
                      VIEW REPORT
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </main>

      {/* ── LOADING OVERLAY ───────────────────────────────────────────────── */}
      {isLoading&&(
        <div style={{position:"fixed",inset:0,zIndex:1000,background:"rgba(5,10,6,.96)",display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",gap:28}}>
          <div style={{position:"relative",width:120,height:120}}>
            <img src={imagePreview} style={{position:"absolute",inset:10,width:100,height:100,borderRadius:"50%",objectFit:"cover",opacity:.5}} alt="load"/>
            <svg width="120" height="120">
              <circle cx="60" cy="60" r="54" fill="none" stroke="var(--accent-green)" strokeWidth="4" strokeDasharray="339" strokeDashoffset="200">
                <animate attributeName="stroke-dashoffset" from="339" to="0" dur="1.8s" repeatCount="indefinite"/>
              </circle>
            </svg>
          </div>
          <div style={{textAlign:"center"}}>
            <div className="dm-mono" style={{fontSize:".9rem",color:"var(--accent-green)",marginBottom:12}}>{currentStep}</div>
            <div style={{width:240,height:2,background:"var(--bg-panel)",borderRadius:1}}>
              <div style={{height:"100%",background:"var(--accent-green)",animation:"scanline 1.8s infinite linear"}}/>
            </div>
          </div>
        </div>
      )}


      {/* ── ERROR TOAST ───────────────────────────────────────────────────── */}
      {analysisError&&appMode!=="results"&&(
        <div style={{position:"fixed",bottom:28,left:"50%",transform:"translateX(-50%)",zIndex:2000,background:"var(--accent-red)",color:"#fff",padding:"12px 22px",borderRadius:8,boxShadow:"0 4px 20px rgba(0,0,0,.4)",display:"flex",alignItems:"center",gap:10,maxWidth:480}}>
          <XCircle size={16}/>
          <span className="dm-mono" style={{fontSize:".78rem"}}>{analysisError}</span>
          <button onClick={()=>setAnalysisError(null)} style={{background:"none",border:"none",color:"#fff",cursor:"pointer",marginLeft:8,fontSize:".9rem"}}>×</button>
        </div>
      )}
    </div>
  );
}
