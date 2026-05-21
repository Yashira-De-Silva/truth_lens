import { Component } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';

interface Feature {
  iconPaths: string[];
  category: string;
  title: string;
  description: string;
  bullets: string[];
  gradient: string;
  accentColor: string;
}

@Component({
  selector: 'app-features',
  standalone: true,
  imports: [NgFor, NgIf],
  templateUrl: './features.html',
  styleUrls: ['./features.scss']
})
export class FeaturesComponent {
  features: Feature[] = [
    { iconPaths: ['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35'], category: 'Core Verification', title: 'AI Claim Verification', description: 'Submit any news claim and get an instant AI-backed verdict with transparent evidence.', bullets: ['REAL / FAKE / UNCERTAIN labels','Confidence score 0–100%','Cited sources from Wikipedia & The Guardian','Gemini-powered grounded reasoning','Entity extraction & keyword analysis'], gradient: 'linear-gradient(135deg, rgba(0,212,255,0.12), rgba(59,130,246,0.08))', accentColor: '#00d4ff' },
    { iconPaths: ['M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z', 'M9 13h.01', 'M15 13h.01'], category: 'AI Assistant', title: 'TruthBot Chat', description: 'An AI news assistant that explains, contextualises, and verifies — in plain language.', bullets: ['Conversational Q&A','News-only instruction set','Real-time topic exploration','Follow-up question support','Source-grounded responses'], gradient: 'linear-gradient(135deg, rgba(124,58,237,0.12), rgba(167,139,250,0.08))', accentColor: '#a78bfa' },
    { iconPaths: ['M19 21V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16', 'M3 21h18', 'M7 9h10', 'M7 13h10', 'M7 17h6'], category: 'News Feed', title: 'Live Guardian Feed', description: 'Real-time headlines from The Guardian with AI summaries and verification badges.', bullets: ['Live article retrieval','Automatic AI summarisation','Bookmark & read-later support','Comment & like articles','Reading history tracking'], gradient: 'linear-gradient(135deg, rgba(16,185,129,0.12), rgba(52,211,153,0.08))', accentColor: '#10b981' },
    { iconPaths: ['M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20'], category: 'Personalisation', title: 'Smart Digest', description: 'Curated daily verified summaries tailored to your reading patterns and interests.', bullets: ['Daily personalised digest','Topic & category preferences','AI-generated summaries','Priority source filtering','Reading streak & analytics'], gradient: 'linear-gradient(135deg, rgba(245,158,11,0.12), rgba(251,191,36,0.08))', accentColor: '#f59e0b' },
    { iconPaths: ['M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2', 'M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M23 21v-2a4 4 0 0 0-3-3.87', 'M16 3.13a4 4 0 0 1 0 7.75'], category: 'Social', title: 'Social Verification Network', description: 'Build a trusted network of fact-checkers, share findings, and collaborate on verification.', bullets: ['Follow / unfollow system','Public & private profiles','Mutual-follow messaging','Comment threads on articles','Social article sharing'], gradient: 'linear-gradient(135deg, rgba(239,68,68,0.12), rgba(252,165,165,0.08))', accentColor: '#ef4444' },
    { iconPaths: ['M6 12h4', 'M8 10v4', 'M15 13h.01', 'M18 11h.01', 'M22 12a10 10 0 0 0-20 0 2 2 0 0 0 2 2h2a2 2 0 0 1 2 2 2 2 0 0 0 2 2h4a2 2 0 0 0 2-2 2 2 0 0 1 2-2h2a2 2 0 0 0 2-2z'], category: 'Gamification', title: 'Media Literacy Games', description: 'Learn to spot misinformation through engaging, competitive challenges.', bullets: ['News Quiz with scoring','Fact vs Fiction challenge mode','Chess between followers','Leaderboards & streaks','Daily challenge missions'], gradient: 'linear-gradient(135deg, rgba(6,182,212,0.12), rgba(99,102,241,0.08))', accentColor: '#06b6d4' }
  ];
}
