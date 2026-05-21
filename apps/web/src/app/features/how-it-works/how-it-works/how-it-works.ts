import { Component } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';

interface PipelineStep {
  number: string;
  icon: string;
  title: string;
  description: string;
  tech: string[];
  color: string;
}

interface ArchBlock {
  name: string;
  icon: string;
  tech: string;
  description: string;
  color: string;
}

@Component({
  selector: 'app-how-it-works',
  standalone: true,
  imports: [NgFor, NgIf],
  templateUrl: './how-it-works.html',
  styleUrls: ['./how-it-works.scss']
})
export class HowItWorksComponent {
  pipeline: PipelineStep[] = [
    { number: '01', icon: '📝', title: 'Claim Ingestion', description: 'You submit a news headline, statement, or article excerpt through the Flutter mobile app or the web interface. The text is sent to the Laravel API backend.', tech: ['Flutter', 'Laravel API', 'JWT Auth'], color: '#00d4ff' },
    { number: '02', icon: '🔑', title: 'Entity Extraction', description: 'Google Gemini analyses the claim to extract key entities, named individuals, organisations, and search keywords that form the basis for evidence gathering.', tech: ['Google Gemini', 'NLP', 'Entity Recognition'], color: '#7c3aed' },
    { number: '03', icon: '🔎', title: 'Evidence Gathering', description: 'The ML service concurrently queries Wikipedia for encyclopaedic context and The Guardian API for recent news coverage related to the extracted entities.', tech: ['Wikipedia API', 'Guardian API', 'Flask'], color: '#10b981' },
    { number: '04', icon: '🧠', title: 'Grounded Reasoning', description: 'Gemini receives the assembled evidence in a structured prompt and produces grounded reasoning — no hallucinations, only evidence-backed analysis.', tech: ['Gemini (Gemma-3)', 'Structured Prompt', 'RAG'], color: '#f59e0b' },
    { number: '05', icon: '✅', title: 'Verdict Delivery', description: 'The result — REAL, FAKE, or UNCERTAIN — along with a confidence score, human-readable reasoning, and source citations is returned to the user.', tech: ['REST API', 'JSON Response', 'Source Citations'], color: '#06b6d4' }
  ];

  architecture: ArchBlock[] = [
    { name: 'Frontend', icon: '📱', tech: 'Flutter + Dart', description: 'Cross-platform UI with Riverpod state management. Runs on iOS, Android, web, and desktop.', color: '#00d4ff' },
    { name: 'Backend', icon: '⚙️', tech: 'Laravel 12 / PHP 8.2', description: 'RESTful API gateway handling auth (JWT), users, social, chess, chat, and news routing.', color: '#7c3aed' },
    { name: 'ML Service', icon: '🤖', tech: 'Flask / Python 3.10', description: 'Gemini-powered intelligence layer for verification, summarisation, live news, and TruthBot chat.', color: '#10b981' },
    { name: 'Database', icon: '🗄️', tech: 'MySQL / TiDB', description: 'Stores users, articles, bookmarks, comments, conversations, chess games, and activity logs.', color: '#f59e0b' }
  ];
}
