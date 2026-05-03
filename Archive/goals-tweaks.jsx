// goals-tweaks.jsx — Tweaks panel for goals.html
const { useEffect } = React;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "displayFont": "Geist",
  "bodyFont": "Inter",
  "monoFont": "JetBrains Mono",
  "theme": "midnight",
  "accent": "#FF4D2E"
}/*EDITMODE-END*/;

const DISPLAY_FONTS = ['Inter','Geist','Manrope','Space Grotesk','IBM Plex Sans','Instrument Serif'];
const BODY_FONTS    = ['Inter Tight','Inter','Geist','Manrope','Space Grotesk','IBM Plex Sans'];
const MONO_FONTS    = ['JetBrains Mono','IBM Plex Mono','ui-monospace'];

const THEMES = {
  midnight: {
    label: 'Midnight',
    vars: {
      '--canvas':'#0E0E10','--canvas-2':'#1A1A1D','--paper':'#16161A',
      '--ink':'#F2F0EA','--ink-2':'#B5B1A6','--ink-3':'#7C7870',
      '--rule':'#26262B','--rule-2':'#33333A',
    }
  },
  paper: {
    label: 'Paper white',
    vars: {
      '--canvas':'#FFFFFF','--canvas-2':'#F4F4F2','--paper':'#FFFFFF',
      '--ink':'#0A0A0A','--ink-2':'#444','--ink-3':'#888',
      '--rule':'#E8E8E5','--rule-2':'#D8D8D3',
    }
  },
  slate: {
    label: 'Cool slate',
    vars: {
      '--canvas':'#F1F3F5','--canvas-2':'#E5E9ED','--paper':'#FFFFFF',
      '--ink':'#11161B','--ink-2':'#3F4A55','--ink-3':'#7A848E',
      '--rule':'#D7DCE1','--rule-2':'#C5CCD3',
    }
  },
  sage: {
    label: 'Sage',
    vars: {
      '--canvas':'#EEF1EA','--canvas-2':'#E2E7DC','--paper':'#FFFFFF',
      '--ink':'#171A14','--ink-2':'#454C3D','--ink-3':'#7E8473',
      '--rule':'#D7DDCD','--rule-2':'#C5CCB9',
    }
  },
  cream: {
    label: 'Original cream',
    vars: {
      '--canvas':'#FAF7F1','--canvas-2':'#F2EEE5','--paper':'#FFFFFF',
      '--ink':'#1A1916','--ink-2':'#4F4A42','--ink-3':'#8B847A',
      '--rule':'#E8E2D5','--rule-2':'#DDD5C4',
    }
  },
};

const ACCENTS = [
  { id:'#FF4D2E', label:'Coral'  },
  { id:'#3B82F6', label:'Blue'   },
  { id:'#7C5BD9', label:'Violet' },
  { id:'#10B981', label:'Mint'   },
  { id:'#EAB308', label:'Amber'  },
];

function applyTweaks(t) {
  const root = document.documentElement;
  const theme = THEMES[t.theme] || THEMES.midnight;
  Object.entries(theme.vars).forEach(([k,v]) => root.style.setProperty(k,v));
  // accent
  root.style.setProperty('--accent', t.accent);
  // derive accent-d (slightly darker) and accent-soft (translucent)
  root.style.setProperty('--accent-d', t.accent);
  root.style.setProperty('--accent-soft', t.accent + '22');
  // fonts
  const wrap = (f) => `'${f}', system-ui, sans-serif`;
  const wrapSerif = (f) => `'${f}', Georgia, serif`;
  const wrapMono  = (f) => `'${f}', ui-monospace, monospace`;
  const isSerif = (f) => /Serif|Garamond|Fraunces|Playfair/i.test(f);
  root.style.setProperty('--font-display', isSerif(t.displayFont) ? wrapSerif(t.displayFont) : wrap(t.displayFont));
  root.style.setProperty('--font-body',    wrap(t.bodyFont));
  root.style.setProperty('--font-mono',    wrapMono(t.monoFont));
  // dark theme adjustments — deep paper, lighter rules
  document.body.dataset.theme = t.theme;
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  useEffect(() => { applyTweaks(t); }, [t]);

  return (
    <TweaksPanel title="Tweaks">
      <TweakSection label="Theme" />
      <TweakSelect label="Palette" value={t.theme}
        options={Object.entries(THEMES).map(([id,v]) => ({ value: id, label: v.label }))}
        onChange={(v) => setTweak('theme', v)} />
      <TweakRow label="Accent">
        <div style={{display:'flex',gap:6}}>
          {ACCENTS.map(a => (
            <button key={a.id} title={a.label}
              onClick={() => setTweak('accent', a.id)}
              style={{
                width:22,height:22,borderRadius:'50%',
                background:a.id,
                border: t.accent === a.id ? '2px solid #fff' : '1px solid rgba(0,0,0,0.15)',
                outline: t.accent === a.id ? '1.5px solid '+a.id : 'none',
                outlineOffset: 1, cursor:'pointer', padding:0,
              }}/>
          ))}
        </div>
      </TweakRow>

      <TweakSection label="Typography" />
      <TweakSelect label="Display (serif)" value={t.displayFont}
        options={DISPLAY_FONTS} onChange={(v) => setTweak('displayFont', v)} />
      <TweakSelect label="Body (sans)" value={t.bodyFont}
        options={BODY_FONTS} onChange={(v) => setTweak('bodyFont', v)} />
      <TweakSelect label="Mono / labels" value={t.monoFont}
        options={MONO_FONTS} onChange={(v) => setTweak('monoFont', v)} />

      <TweakSection label="Reset" />
      <TweakButton label="Restore defaults"
        onClick={() => {
          Object.entries(TWEAK_DEFAULTS).forEach(([k,v]) => setTweak(k, v));
        }}/>
    </TweaksPanel>
  );
}

const root = document.createElement('div');
document.body.appendChild(root);
ReactDOM.createRoot(root).render(<App/>);
