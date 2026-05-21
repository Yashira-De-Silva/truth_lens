import { Component, OnInit, OnDestroy } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';
import { RouterLink } from '@angular/router';

interface Stat {
  value: string;
  label: string;
  iconPaths: string[];
}

interface FeatureCard {
  iconPaths: string[];
  title: string;
  description: string;
  badge?: string;
  gradient: string;
}

interface Step {
  number: string;
  title: string;
  description: string;
  iconPaths: string[];
}

interface Testimonial {
  name: string;
  role: string;
  avatar: string;
  text: string;
  rating: number;
}

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [NgFor, NgIf, RouterLink],
  templateUrl: './landing.html',
  styleUrls: ['./landing.scss']
})
export class LandingComponent implements OnInit, OnDestroy {
  private typingInterval: any;
  typedText = '';
  typingIndex = 0;
  charIndex = 0;
  isDeleting = false;

  typingPhrases = [
    'Real or Fake?',
    'Truth or Misinformation?',
    'Fact or Fiction?',
    'Verified or Misleading?'
  ];

  stats: Stat[] = [
    { value: '95%', label: 'Verification Accuracy', iconPaths: ['M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z', 'M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M12 12h.01'] },
    { value: '< 3s', label: 'Response Time',         iconPaths: ['M13 2L3 14h9l-1 8 10-12h-9l1-8z'] },
    { value: '10K+', label: 'Claims Verified',        iconPaths: ['M22 11.08V12a10 10 0 1 1-5.93-9.14', 'M22 4L12 14.01l-3-3'] },
    { value: '3',    label: 'Evidence Sources',       iconPaths: ['M19 21V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16', 'M3 21h18', 'M7 9h10', 'M7 13h10', 'M7 17h6'] }
  ];

  features: FeatureCard[] = [
    {
      iconPaths: ['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35'],
      title: 'AI Claim Verification',
      description: 'Paste any news headline or claim. Our Gemini-powered pipeline cross-references Wikipedia and The Guardian to deliver an instant REAL / FAKE / UNCERTAIN verdict.',
      badge: 'Core Feature',
      gradient: 'linear-gradient(135deg, rgba(0,212,255,0.15), rgba(59,130,246,0.15))'
    },
    {
      iconPaths: ['M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v1a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-1H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z', 'M9 13h.01', 'M15 13h.01'],
      title: 'TruthBot Assistant',
      description: 'Chat with our AI news assistant for in-depth explanations, source breakdowns, and contextual analysis of any story you are following.',
      badge: 'AI Powered',
      gradient: 'linear-gradient(135deg, rgba(124,58,237,0.15), rgba(167,139,250,0.15))'
    },
    {
      iconPaths: ['M19 21V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16', 'M3 21h18', 'M7 9h10', 'M7 13h10', 'M7 17h6'],
      title: 'Live News Feed',
      description: 'Browse real-time headlines from The Guardian, enriched with AI-generated summaries and verification badges directly in your feed.',
      gradient: 'linear-gradient(135deg, rgba(16,185,129,0.15), rgba(52,211,153,0.15))'
    },
    {
      iconPaths: ['M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20'],
      title: 'Smart Digest',
      description: 'Get a personalised daily digest of verified, summarised news tailored to your interests — no noise, just signal.',
      gradient: 'linear-gradient(135deg, rgba(245,158,11,0.15), rgba(251,191,36,0.08))'
    },
    {
      iconPaths: ['M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2', 'M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M23 21v-2a4 4 0 0 0-3-3.87', 'M16 3.13a4 4 0 0 1 0 7.75'],
      title: 'Social Verification',
      description: 'Follow trusted users, share findings, comment on articles, and build a community around verified information.',
      gradient: 'linear-gradient(135deg, rgba(239,68,68,0.15), rgba(252,165,165,0.15))'
    },
    {
      iconPaths: ['M6 12h4', 'M8 10v4', 'M15 13h.01', 'M18 11h.01', 'M22 12a10 10 0 0 0-20 0 2 2 0 0 0 2 2h2a2 2 0 0 1 2 2 2 2 0 0 0 2 2h4a2 2 0 0 0 2-2 2 2 0 0 1 2-2h2a2 2 0 0 0 2-2z'],
      title: 'Gamified Learning',
      description: 'Level up your media literacy with News Quiz, Fact vs Fiction challenges, and chess — learning truth detection has never been more fun.',
      badge: 'New',
      gradient: 'linear-gradient(135deg, rgba(6,182,212,0.15), rgba(99,102,241,0.15))'
    }
  ];

  steps: Step[] = [
    { number: '01', title: 'Submit a Claim', description: 'Enter any news headline, statement, or article excerpt through the mobile app or web interface.', iconPaths: ['M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7', 'M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'] },
    { number: '02', title: 'AI Evidence Gathering', description: 'Gemini extracts key entities, then searches Wikipedia and The Guardian for corroborating evidence.', iconPaths: ['M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z', 'M21 21l-4.35-4.35'] },
    { number: '03', title: 'Grounded Reasoning', description: 'Our ML service synthesises the evidence with a structured Gemini prompt, ensuring grounded, non-hallucinated analysis.', iconPaths: ['M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z', 'M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z'] },
    { number: '04', title: 'Verdict + Sources', description: 'Receive a clear REAL / FAKE / UNCERTAIN label with confidence score, reasoning, and cited sources.', iconPaths: ['M22 11.08V12a10 10 0 1 1-5.93-9.14', 'M22 4L12 14.01l-3-3'] }
  ];

  testimonials: Testimonial[] = [
    { name: 'Sarah K.', role: 'Investigative Journalist', avatar: 'SK', text: 'TruthLens has become an indispensable tool in my daily workflow. The AI verification is remarkably accurate and the source citations save me hours of research.', rating: 5 },
    { name: 'Marcus T.', role: 'Media Literacy Educator', avatar: 'MT', text: 'I use TruthLens in my classroom to teach students how to evaluate news sources. The gamified features make learning engaging and the AI explanations are crystal clear.', rating: 5 },
    { name: 'Priya R.', role: 'Policy Researcher', avatar: 'PR', text: 'The combination of Wikipedia, Guardian, and Gemini creates a verification pipeline I genuinely trust. The confidence scores help me calibrate my level of certainty.', rating: 5 }
  ];

  verificationDemo = {
    claim: 'Scientists have discovered a new species of deep-sea fish off the coast of New Zealand',
    status: 'REAL',
    confidence: 87,
    reason: 'Multiple credible sources including The Guardian and Wikipedia confirm ongoing deep-sea exploration in the New Zealand exclusive economic zone, with NIWA regularly documenting new species discoveries.',
    sources: ['The Guardian', 'Wikipedia', 'NIWA']
  };

  ngOnInit() { this.startTyping(); }
  ngOnDestroy() { clearInterval(this.typingInterval); }

  private startTyping() {
    this.typingInterval = setInterval(() => {
      const phrase = this.typingPhrases[this.typingIndex];
      if (!this.isDeleting) {
        this.typedText = phrase.substring(0, this.charIndex + 1);
        this.charIndex++;
        if (this.charIndex === phrase.length) {
          setTimeout(() => { this.isDeleting = true; }, 2000);
        }
      } else {
        this.typedText = phrase.substring(0, this.charIndex - 1);
        this.charIndex--;
        if (this.charIndex === 0) {
          this.isDeleting = false;
          this.typingIndex = (this.typingIndex + 1) % this.typingPhrases.length;
        }
      }
    }, 100);
  }

  getStars(rating: number): number[] { return Array(rating).fill(0); }
}
