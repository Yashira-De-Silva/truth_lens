const fs = require('fs');

const iconMap = {
  "'🎯'": "['M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z', 'M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M12 12h.01']",
  "'⚡'": "['M13 2L3 14h9l-1 8 10-12h-9l1-8z']",
  "'✅'": "['M22 11.08V12a10 10 0 1 1-5.93-9.14', 'M22 4L12 14.01l-3-3']",
  "'📰'": "['M19 21V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16', 'M3 21h18', 'M7 9h10', 'M7 13h10', 'M7 17h6']",
  "'🔍'": "['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35']",
  "'🤖'": "['M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z', 'M9 13h.01', 'M15 13h.01']",
  "'📚'": "['M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20']",
  "'👥'": "['M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2', 'M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M23 21v-2a4 4 0 0 0-3-3.87', 'M16 3.13a4 4 0 0 1 0 7.75']",
  "'🎮'": "['M6 12h4', 'M8 10v4', 'M15 13h.01', 'M18 11h.01', 'M22 12a10 10 0 0 0-20 0 2 2 0 0 0 2 2h2a2 2 0 0 1 2 2 2 2 0 0 0 2 2h4a2 2 0 0 0 2-2 2 2 0 0 1 2-2h2a2 2 0 0 0 2-2z']",
  "'📝'": "['M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7', 'M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z']",
  "'🔑'": "['M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4']",
  "'🔎'": "['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35']",
  "'🧠'": "['M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z', 'M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z']",
  "'🌍'": "['M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z', 'M2 12h20', 'M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z']",
  "'📱'": "['M5 2h14a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z', 'M12 18h.01']",
  "'⚙️'": "['M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z', 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z']",
  "'🗄️'": "['M12 3c-4.97 0-9 1.79-9 4s4.03 4 9 4 9-1.79 9-4-4.03-4-9-4z', 'M3 17c0 2.21 4.03 4 9 4s9-1.79 9-4', 'M3 12c0 2.21 4.03 4 9 4s9-1.79 9-4', 'M3 7v10', 'M21 7v10']"
};

const components = [
  'landing/landing',
  'features/features',
  'how-it-works/how-it-works',
  'about/about'
];

components.forEach(comp => {
  const tsPath = `src/app/features/${comp.split('/')[0]}/${comp}/${comp.split('/')[1]}.ts`;
  let ts = fs.readFileSync(tsPath, 'utf8');
  
  // Replace icon: string with iconPaths: string[] in interfaces
  ts = ts.replace(/icon:\s*string;/g, 'iconPaths: string[];');
  
  // Replace emojis with paths
  for (const [emoji, path] of Object.entries(iconMap)) {
    ts = ts.split(`icon: ${emoji}`).join(`iconPaths: ${path}`);
  }
  fs.writeFileSync(tsPath, ts);
});

// Now update HTML templates
const svgTpl = `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path *ngFor="let p of ITEM.iconPaths" [attr.d]="p"></path></svg>`;

const htmlReplacements = [
  {
    file: 'src/app/features/landing/landing/landing.html',
    replacements: [
      { from: '{{ s.icon }}', to: svgTpl.replace('ITEM', 's') },
      { from: '{{ f.icon }}', to: svgTpl.replace('ITEM', 'f') },
      { from: '{{ step.icon }}', to: svgTpl.replace('ITEM', 'step') }
    ]
  },
  {
    file: 'src/app/features/features/features/features.html',
    replacements: [
      { from: '{{ feature.icon }}', to: svgTpl.replace('ITEM', 'feature') }
    ]
  },
  {
    file: 'src/app/features/how-it-works/how-it-works/how-it-works.html',
    replacements: [
      { from: '{{ step.icon }}', to: svgTpl.replace('ITEM', 'step') },
      { from: '{{ block.icon }}', to: svgTpl.replace('ITEM', 'block') }
    ]
  },
  {
    file: 'src/app/features/about/about/about.html',
    replacements: [
      { from: '{{ v.icon }}', to: svgTpl.replace('ITEM', 'v') }
    ]
  }
];

htmlReplacements.forEach(hr => {
  let html = fs.readFileSync(hr.file, 'utf8');
  hr.replacements.forEach(r => {
    html = html.split(r.from).join(r.to);
  });
  fs.writeFileSync(hr.file, html);
});
