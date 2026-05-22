import { Component } from '@angular/core';
import { NgFor } from '@angular/common';

interface TeamMember {
  initials: string;
  name: string;
  role: string;
  bio: string;
  gradient: string;
}

interface Value {
  iconPaths: string[];
  title: string;
  description: string;
}

@Component({
  selector: 'app-about',
  standalone: true,
  imports: [NgFor],
  templateUrl: './about.html',
  styleUrls: ['./about.scss']
})
export class AboutComponent {
  team: TeamMember[] = [
    { initials: 'YD', name: 'Yashira De Silva', role: 'Full-Stack Developer & ML Engineer', bio: 'Built TruthLens end-to-end as a final year project, integrating Flutter, Laravel, and Python with Google Gemini to fight misinformation.', gradient: 'linear-gradient(135deg, #00d4ff, #7c3aed)' }
  ];

  values: Value[] = [
    { iconPaths: ['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35'], title: 'Radical Transparency', description: 'Every verdict comes with its reasoning and sources. No black boxes. You should always know why TruthLens says REAL or FAKE.' },
    { iconPaths: ['M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z', 'M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z'], title: 'Evidence-First', description: 'We never label a claim without evidence. The pipeline is grounded in Wikipedia and The Guardian — reducing AI hallucinations to near zero.' },
    { iconPaths: ['M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z', 'M2 12h20', 'M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z'], title: 'Open Knowledge', description: 'Built on open-source foundations. We believe the tools to fight misinformation should be accessible to everyone, everywhere.' },
    { iconPaths: ['M6 12h4', 'M8 10v4', 'M15 13h.01', 'M18 11h.01', 'M22 12a10 10 0 0 0-20 0 2 2 0 0 0 2 2h2a2 2 0 0 1 2 2 2 2 0 0 0 2 2h4a2 2 0 0 0 2-2 2 2 0 0 1 2-2h2a2 2 0 0 0 2-2z'], title: 'Learning Through Play', description: 'Fact-checking is a skill. Our games and quizzes make developing media literacy enjoyable and habit-forming.' }
  ];

  timeline = [
    { year: '2024', event: 'Project inception — researching misinformation pipelines and AI verification.' },
    { year: 'Q1 2025', event: 'Flutter mobile app and Laravel backend scaffolded. JWT auth implemented.' },
    { year: 'Q2 2025', event: 'Flask ML service integrated with Gemini. Wikipedia & Guardian APIs connected.' },
    { year: 'Q3 2025', event: 'Social features, chess, quiz games, and premium subscription flow added.' },
    { year: 'Q4 2025', event: 'TruthBot AI chat, smart digest, and voice calls shipped. Deployed on Render.' },
    { year: '2026', event: 'Angular web portal launched. Open beta begins.' }
  ];
}
