import { Component } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';

interface PipelineStep {
  number: string;
  iconPaths: string[];
  title: string;
  description: string;
  tech: string[];
  color: string;
}

interface ArchBlock {
  name: string;
  iconPaths: string[];
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
    { number: '01', iconPaths: ['M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7', 'M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'], title: 'Claim Ingestion', description: 'You submit a news headline, statement, or article excerpt through the Flutter mobile app or the web interface. The text is sent to the Laravel API backend.', tech: ['Flutter', 'Laravel API', 'JWT Auth'], color: '#00d4ff' },
    { number: '02', iconPaths: ['M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4'], title: 'Entity Extraction', description: 'Google Gemini analyses the claim to extract key entities, named individuals, organisations, and search keywords that form the basis for evidence gathering.', tech: ['Google Gemini', 'NLP', 'Entity Recognition'], color: '#7c3aed' },
    { number: '03', iconPaths: ['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35'], title: 'Evidence Gathering', description: 'The ML service concurrently queries Wikipedia for encyclopaedic context and The Guardian API for recent news coverage related to the extracted entities.', tech: ['Wikipedia API', 'Guardian API', 'Flask'], color: '#10b981' },
    { number: '04', iconPaths: ['M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z', 'M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z'], title: 'Grounded Reasoning', description: 'Gemini receives the assembled evidence in a structured prompt and produces grounded reasoning — no hallucinations, only evidence-backed analysis.', tech: ['Gemini (Gemma-3)', 'Structured Prompt', 'RAG'], color: '#f59e0b' },
    { number: '05', iconPaths: ['M22 11.08V12a10 10 0 1 1-5.93-9.14', 'M22 4L12 14.01l-3-3'], title: 'Verdict Delivery', description: 'The result — REAL, FAKE, or UNCERTAIN — along with a confidence score, human-readable reasoning, and source citations is returned to the user.', tech: ['REST API', 'JSON Response', 'Source Citations'], color: '#06b6d4' }
  ];

  architecture: ArchBlock[] = [
    { name: 'Frontend', iconPaths: ['M5 2h14a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z', 'M12 18h.01'], tech: 'Flutter + Dart', description: 'Cross-platform UI with Riverpod state management. Runs on iOS, Android, web, and desktop.', color: '#00d4ff' },
    { name: 'Backend', iconPaths: ['M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z', 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z'], tech: 'Laravel 12 / PHP 8.2', description: 'RESTful API gateway handling auth (JWT), users, social, chess, chat, and news routing.', color: '#7c3aed' },
    { name: 'ML Service', iconPaths: ['M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z', 'M9 13h.01', 'M15 13h.01'], tech: 'Flask / Python 3.10', description: 'Gemini-powered intelligence layer for verification, summarisation, live news, and TruthBot chat.', color: '#10b981' },
    { name: 'Database', iconPaths: ['M12 3c-4.97 0-9 1.79-9 4s4.03 4 9 4 9-1.79 9-4-4.03-4-9-4z', 'M3 17c0 2.21 4.03 4 9 4s9-1.79 9-4', 'M3 12c0 2.21 4.03 4 9 4s9-1.79 9-4', 'M3 7v10', 'M21 7v10'], tech: 'MySQL / TiDB', description: 'Stores users, articles, bookmarks, comments, conversations, chess games, and activity logs.', color: '#f59e0b' }
  ];
}
