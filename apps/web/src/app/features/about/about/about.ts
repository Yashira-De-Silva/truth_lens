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
  icon: string;
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
    { icon: '🔍', title: 'Radical Transparency', description: 'Every verdict comes with its reasoning and sources. No black boxes. You should always know why TruthLens says REAL or FAKE.' },
    { icon: '🧠', title: 'Evidence-First', description: 'We never label a claim without evidence. The pipeline is grounded in Wikipedia and The Guardian — reducing AI hallucinations to near zero.' },
    { icon: '🌍', title: 'Open Knowledge', description: 'Built on open-source foundations. We believe the tools to fight misinformation should be accessible to everyone, everywhere.' },
    { icon: '🎮', title: 'Learning Through Play', description: 'Fact-checking is a skill. Our games and quizzes make developing media literacy enjoyable and habit-forming.' }
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
