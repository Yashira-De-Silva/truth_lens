import { Component } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';

interface Feature {
  icon: string;
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
    { icon: '🔍', category: 'Core Verification', title: 'AI Claim Verification', description: 'Submit any news claim and get an instant AI-backed verdict with transparent evidence.', bullets: ['REAL / FAKE / UNCERTAIN labels','Confidence score 0–100%','Cited sources from Wikipedia & The Guardian','Gemini-powered grounded reasoning','Entity extraction & keyword analysis'], gradient: 'linear-gradient(135deg, rgba(0,212,255,0.12), rgba(59,130,246,0.08))', accentColor: '#00d4ff' },
    { icon: '🤖', category: 'AI Assistant', title: 'TruthBot Chat', description: 'An AI news assistant that explains, contextualises, and verifies — in plain language.', bullets: ['Conversational Q&A','News-only instruction set','Real-time topic exploration','Follow-up question support','Source-grounded responses'], gradient: 'linear-gradient(135deg, rgba(124,58,237,0.12), rgba(167,139,250,0.08))', accentColor: '#a78bfa' },
    { icon: '📰', category: 'News Feed', title: 'Live Guardian Feed', description: 'Real-time headlines from The Guardian with AI summaries and verification badges.', bullets: ['Live article retrieval','Automatic AI summarisation','Bookmark & read-later support','Comment & like articles','Reading history tracking'], gradient: 'linear-gradient(135deg, rgba(16,185,129,0.12), rgba(52,211,153,0.08))', accentColor: '#10b981' },
    { icon: '📚', category: 'Personalisation', title: 'Smart Digest', description: 'Curated daily verified summaries tailored to your reading patterns and interests.', bullets: ['Daily personalised digest','Topic & category preferences','AI-generated summaries','Priority source filtering','Reading streak & analytics'], gradient: 'linear-gradient(135deg, rgba(245,158,11,0.12), rgba(251,191,36,0.08))', accentColor: '#f59e0b' },
    { icon: '👥', category: 'Social', title: 'Social Verification Network', description: 'Build a trusted network of fact-checkers, share findings, and collaborate on verification.', bullets: ['Follow / unfollow system','Public & private profiles','Mutual-follow messaging','Comment threads on articles','Social article sharing'], gradient: 'linear-gradient(135deg, rgba(239,68,68,0.12), rgba(252,165,165,0.08))', accentColor: '#ef4444' },
    { icon: '🎮', category: 'Gamification', title: 'Media Literacy Games', description: 'Learn to spot misinformation through engaging, competitive challenges.', bullets: ['News Quiz with scoring','Fact vs Fiction challenge mode','Chess between followers','Leaderboards & streaks','Daily challenge missions'], gradient: 'linear-gradient(135deg, rgba(6,182,212,0.12), rgba(99,102,241,0.08))', accentColor: '#06b6d4' }
  ];
}
