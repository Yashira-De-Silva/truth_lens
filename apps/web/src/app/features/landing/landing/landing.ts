import { Component, OnInit, OnDestroy } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';
import { RouterLink } from '@angular/router';

interface Stat {
  value: string;
  label: string;
  icon: string;
}

interface FeatureCard {
  icon: string;
  title: string;
  description: string;
  badge?: string;
  gradient: string;
}

interface Step {
  number: string;
  title: string;
  description: string;
  icon: string;
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
    { value: '95%', label: 'Verification Accuracy', icon: '🎯' },
    { value: '< 3s', label: 'Response Time',         icon: '⚡' },
    { value: '10K+', label: 'Claims Verified',        icon: '✅' },
    { value: '3',    label: 'Evidence Sources',       icon: '📰' }
  ];

  features: FeatureCard[] = [
    {
      icon: '🔍',
      title: 'AI Claim Verification',
      description: 'Paste any news headline or claim. Our Gemini-powered pipeline cross-references Wikipedia and The Guardian to deliver an instant REAL / FAKE / UNCERTAIN verdict.',
      badge: 'Core Feature',
      gradient: 'linear-gradient(135deg, rgba(0,212,255,0.15), rgba(59,130,246,0.15))'
    },
    {
      icon: '🤖',
      title: 'TruthBot Assistant',
      description: 'Chat with our AI news assistant for in-depth explanations, source breakdowns, and contextual analysis of any story you are following.',
      badge: 'AI Powered',
      gradient: 'linear-gradient(135deg, rgba(124,58,237,0.15), rgba(167,139,250,0.15))'
    },
    {
      icon: '📰',
      title: 'Live News Feed',
      description: 'Browse real-time headlines from The Guardian, enriched with AI-generated summaries and verification badges directly in your feed.',
      gradient: 'linear-gradient(135deg, rgba(16,185,129,0.15), rgba(52,211,153,0.15))'
    },
    {
      icon: '📚',
      title: 'Smart Digest',
      description: 'Get a personalised daily digest of verified, summarised news tailored to your interests — no noise, just signal.',
      gradient: 'linear-gradient(135deg, rgba(245,158,11,0.15), rgba(251,191,36,0.15))'
    },
    {
      icon: '👥',
      title: 'Social Verification',
      description: 'Follow trusted users, share findings, comment on articles, and build a community around verified information.',
      gradient: 'linear-gradient(135deg, rgba(239,68,68,0.15), rgba(252,165,165,0.15))'
    },
    {
      icon: '🎮',
      title: 'Gamified Learning',
      description: 'Level up your media literacy with News Quiz, Fact vs Fiction challenges, and chess — learning truth detection has never been more fun.',
      badge: 'New',
      gradient: 'linear-gradient(135deg, rgba(6,182,212,0.15), rgba(99,102,241,0.15))'
    }
  ];

  steps: Step[] = [
    { number: '01', title: 'Submit a Claim', description: 'Enter any news headline, statement, or article excerpt through the mobile app or web interface.', icon: '📝' },
    { number: '02', title: 'AI Evidence Gathering', description: 'Gemini extracts key entities, then searches Wikipedia and The Guardian for corroborating evidence.', icon: '🔎' },
    { number: '03', title: 'Grounded Reasoning', description: 'Our ML service synthesises the evidence with a structured Gemini prompt, ensuring grounded, non-hallucinated analysis.', icon: '🧠' },
    { number: '04', title: 'Verdict + Sources', description: 'Receive a clear REAL / FAKE / UNCERTAIN label with confidence score, reasoning, and cited sources.', icon: '✅' }
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
