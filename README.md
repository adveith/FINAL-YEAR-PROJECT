# SmartFruit — Edge-AI Fruit Freshness Detection

> Final Year Project · BSc Computer Science  
> On-device multimodal AI for real-time fruit freshness and staleness detection — 100% free, no API key required.

---

## Overview

SmartFruit is a full-stack web application that uses computer vision and simulated IoT sensor fusion to classify the ripeness and staleness of fresh fruit in real time. The entire AI pipeline runs **on-device in the browser** using TensorFlow.js and a hand-calibrated HSV colour-profile engine — no cloud calls, no API keys, no cost.

The system supports **5 fruit types** with **4 ripeness stages** each:

| Fruit | Ripeness Stages |
|-------|----------------|
| 🍌 Banana | Unripe → Ripe → Overripe → Spoiled |
| 🍎 Apple | Unripe → Ripe → Overripe → Spoiled |
| 🥭 Mango | Unripe → Ripe → Overripe → Spoiled |
| 🍇 Grapes | Unripe → Ripe → Overripe → Spoiled |
| 🍊 Orange | Unripe → Ripe → Overripe → Spoiled |

---

## Live Demo

The landing page includes a floating **LAUNCH LIVE DEMO** button (bottom-left) that opens the full detection interface. Three input modes are supported:

- **Phone Camera** — capture via mobile rear camera or upload from gallery
- **Live Webcam** — real-time stream from laptop or external camera
- **Jetson Device** — hardware prototype via NVIDIA Jetson Orin NX local IP

---

## AI Detection Architecture

The detection pipeline runs entirely in the browser with no server or API dependency.

```
Image Input
    │
    ├─► Image Enhancement   (auto brightness/contrast normalisation)
    │
    ├─► MobileNet v2        (fruit type ID via ImageNet labels)
    │       └─► MN_LABEL_MAP auto-built from FRUIT_PROFILES[].mnKeys
    │
    ├─► HSV Colour Analysis (saturation-weighted circular hue mean)
    │       ├─► 6 regions: centre 3×, mid-ring 1.5×, 4 corners 1×
    │       └─► Weighted Euclidean distance in HSV space (hue 3×, sat 2×, val 1×)
    │
    ├─► Ensemble Vote        (4-rule cascade)
    │       ├─ MobileNet ≥ 30%              → trust MobileNet
    │       ├─ Both models agree            → trust agreement
    │       ├─ MobileNet ≥ 12%, HSV < 50%  → MobileNet wins
    │       └─ Otherwise                   → HSV wins
    │
    └─► Ripeness Engine     (profile-based L1 scoring)
            ├─► 6 colour buckets: green / yellow / orange / red / purple / brownDark
            ├─► brownDark = genuinely dark/brown pixels ONLY (not a catch-all)
            ├─► L1 distance to per-fruit per-stage colour-ratio profiles
            ├─► Texture variance modifier (patchy surface → Overripe/Spoiled boost)
            └─► Best-matching stage → final result
```

### Key Design Decisions

**Why HSV instead of RGB?**  
HSV separates colour from brightness. A banana looks yellow whether the lighting is bright or dim — Hue stays stable while Value changes. RGB conflates these, making colour matching unreliable across lighting conditions.

**Why circular hue mean?**  
Hue wraps around at 360°. A naïve average of 5° and 355° gives 180° (green) instead of 0° (red). Hue components are accumulated as sin/cos vectors and recovered via `atan2` for the correct circular mean.

**Why not a catch-all brownDark bucket?**  
Previous versions used `else: brownDark++` — every pixel that was not green/yellow/orange/red/purple fell into brownDark. Gray backgrounds, white walls, and shadows all inflated the brownDark ratio and forced a Spoiled result on every image. The fix: only genuinely dark (`v < 42`) or brownish pixels (`h 10–65, low-mid saturation, v < 70`) count. Ambiguous pixels (teal, magenta, cyan) are skipped entirely so the vector stays clean.

**Why saturation-weighted pixel sampling?**  
Fruit pixels are vivid (high saturation). Background pixels are muted (low saturation). Weighting each pixel by its saturation ensures the fruit colour dominates the hue mean even when most of the frame is background.

---

## Colour-Ratio Profiles (Ripeness Engine)

Each fruit has a calibrated expected colour-ratio vector `[green, yellow, orange, red, purple, brownDark]` for each stage. The engine scores all 4 stages by L1 similarity and picks the best match.

```
Banana  Unripe:   [0.84, 0.06, 0.01, 0.00, 0.00, 0.05]  ← solid green
Banana  Ripe:     [0.02, 0.87, 0.06, 0.01, 0.00, 0.04]  ← solid yellow
Banana  Overripe: [0.02, 0.40, 0.04, 0.00, 0.00, 0.50]  ← yellow + brown patches
Banana  Spoiled:  [0.01, 0.06, 0.01, 0.01, 0.00, 0.88]  ← mostly dark

Apple   Unripe:   [0.80, 0.02, 0.01, 0.10, 0.00, 0.04]  ← green with blush
Apple   Ripe:     [0.04, 0.01, 0.04, 0.80, 0.00, 0.06]  ← vivid red

Orange  Ripe:     [0.02, 0.03, 0.88, 0.02, 0.00, 0.04]  ← vivid orange
Grapes  Ripe:     [0.02, 0.01, 0.01, 0.04, 0.83, 0.08]  ← deep purple
Mango   Ripe:     [0.02, 0.32, 0.55, 0.04, 0.00, 0.04]  ← yellow-orange
```

---

## Per-Scan Output

Every result card includes:

| Field | Description |
|-------|-------------|
| `ripeness_level` | Unripe / Ripe / Overripe / Spoiled |
| `is_stale` | `true` when Overripe or Spoiled |
| `freshness_score` | 0–100 animated gauge |
| `shelf_life_days` | Estimated days remaining |
| `shelf_life_label` | Human-readable storage guidance |
| `visual_observations` | 3 science-backed observations |
| `recommendation` | Specific storage and consumption advice |
| `staleness_reason` | Biochemical explanation of the current stage |
| `ethylene_prediction` | Low / Medium / High / Very High |
| `estimated_weight_g` | Estimated weight in grams |
| `confidence` | Detection confidence % |

Results are displayed as:

- **Staleness banner** — colour-coded (green / amber / red) with safety verdict
- **Freshness gauge** — animated circular score out of 100
- **Radar chart** — 6-axis quality profile (Colour, Surface, Aroma, Weight, Hydration, Freshness)
- **Sensor bar chart** — Ethylene, CO₂, VOC, MQ-3, Humidity
- **Nutritional panel** — per-100g macros and micronutrients
- **GradCAM note** — AI attention region description

---

## Simulated Sensor Fusion

The hardware prototype integrates these sensors (simulated in the web demo using ripeness-stage-calibrated ranges):

| Sensor | Measurement | Unit | Spoiled Range |
|--------|-------------|------|---------------|
| MQ-3 gas cell | Ethylene concentration | ppm | 170–420 |
| MQ-135 gas cell | CO₂ level | ppm | 850–1400 |
| MQ-135 gas cell | VOC index | — | 300+ |
| Load cell | Fruit weight | g | — |
| DS18B20 thermistor | Surface temperature | °C | 27–32 |
| DHT22 | Ambient humidity | % | 82–96 |

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend framework | React | 19 |
| Build tool | Vite | 8 |
| Charts | Recharts | 3 |
| Icons | Lucide React | 1 |
| Computer vision | TensorFlow.js | 4.10.0 (CDN) |
| Fruit type ID | MobileNet | 2.1.1 (CDN) |
| Colour analysis | Custom HSV engine | — |
| Fonts | Orbitron + DM Mono | Google Fonts |
| Hardware | NVIDIA Jetson Orin NX | — |

TensorFlow.js and MobileNet are loaded from jsDelivr CDN in `index.html`. No additional npm packages are required for the AI pipeline.

---

## Project Structure

```
FINAL-YEAR-PROJECT/
├── index.html                  # CDN <script> tags for TF.js + MobileNet
├── package.json
├── vite.config.js
├── eslint.config.js
└── src/
    ├── main.jsx
    ├── App.jsx                 # Root: landing page sections + demo launcher
    └── components/
        ├── DemoApp.jsx         # ★ Full detection UI + entire AI engine
        ├── Hero.jsx            # Landing hero + device mockup animation
        ├── Features.jsx        # Feature highlight cards
        ├── HowItWorks.jsx      # Step-by-step process explainer
        ├── Simulator.jsx       # Interactive ripeness simulator
        ├── TechStack.jsx       # Technology breakdown section
        ├── Research.jsx        # Academic research context
        ├── Team.jsx            # Project team members
        ├── Timeline.jsx        # Gantt chart (Jan–May 2025)
        ├── Chatbot.jsx         # Fruit knowledge chatbot (offline, rule-based)
        ├── Navigation.jsx      # Sticky navigation bar with section tracking
        ├── LoadingScreen.jsx   # Boot animation
        └── Footer.jsx
```

---

## Getting Started

### Prerequisites

- Node.js 18+
- npm 9+

### Install and run locally

```bash
git clone https://github.com/adveith/FINAL-YEAR-PROJECT.git
cd FINAL-YEAR-PROJECT
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

### Build for production

```bash
npm run build   # outputs to dist/
npm run preview # serve production build locally
```

### Lint

```bash
npm run lint    # ESLint — should exit 0 errors
```

---

## Using the Live Demo

1. Open the app and click **LAUNCH LIVE DEMO** (floating amber button, bottom-left)
2. Choose an input mode:
   - **Phone Camera** — tap **TAKE PHOTO** to open the rear camera directly (works on iOS Safari), or **UPLOAD FROM GALLERY** to pick an existing photo from the device
   - **Live Webcam** — allow camera access in your browser, then click **CAPTURE FRAME**
   - **Jetson Device** — streams from the hardware prototype on the local network
3. *(Optional)* Use **Presentation Mode** (amber panel) to manually select a fruit and override auto-detection — useful for demos where you know the fruit type in advance
4. Click **RUN AUTO-ANALYSIS** (or the named fruit button in Presentation Mode)
5. View the full results page: staleness verdict, freshness gauge, radar chart, sensor readings, nutritional data, shelf life, and science-backed observations

### Scan History

Up to 10 recent scans are stored in session memory. Tap **History** in the header to review past results with thumbnails, timestamps, and result badges.

---

## Hardware Prototype

The physical system runs on an **NVIDIA Jetson Orin NX** and interfaces with:

| Component | Purpose |
|-----------|---------|
| IMX219 camera module (8 MP) | Fruit image capture |
| MQ-3 gas sensor | Ethylene and alcohol detection |
| MQ-135 gas sensor | CO₂ and VOC monitoring |
| HX711 + strain gauge load cell | Weight measurement |
| DS18B20 | Surface temperature |
| DHT22 | Ambient humidity |
| 7" LCD touchscreen | On-device UI |

The web dashboard connects to the Jetson over the local network (default `192.168.1.42`).

---

## Development Timeline

| Phase | Period | Key Deliverables |
|-------|--------|-----------------|
| Planning & Design | Jan 2025 | System architecture, requirements spec |
| Hardware | Feb 2025 | Sensor procurement and interfacing |
| Dataset | Mar 2025 | Fruit image dataset, label annotation |
| Model Development | Mar–Apr 2025 | YOLOv8 training, CNN ripeness model, GradCAM integration, sensor feature engineering, fusion model |
| Deployment | Apr–May 2025 | Jetson edge pipeline, LCD UI, web dashboard API |
| Integration & Validation | May 2025 | System testing, final demo, documentation |

---

## License

Academic project — all rights reserved. Not licensed for commercial use.
