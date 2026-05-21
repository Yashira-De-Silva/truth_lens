import { Component } from '@angular/core';
import { NgFor, NgIf, NgClass } from '@angular/common';
import { RouterLink } from '@angular/router';

interface Plan {
  name: string;
  price: string;
  period: string;
  description: string;
  features: string[];
  cta: string;
  highlighted: boolean;
  badge?: string;
  gradient?: string;
}

@Component({
  selector: 'app-pricing',
  standalone: true,
  imports: [NgFor, NgIf, NgClass, RouterLink],
  templateUrl: './pricing.html',
  styleUrls: ['./pricing.scss']
})
export class PricingComponent {
  plans: Plan[] = [
    { name: 'Free', price: '$0', period: 'forever', description: 'Perfect for individuals who want to start verifying news with AI.', features: ['10 verifications / day','Live news feed','TruthBot (5 messages / day)','News quiz & games','Public profile','Bookmark articles'], cta: 'Get Started Free', highlighted: false },
    { name: 'Premium', price: '$9', period: 'per month', description: 'For power users, journalists, and researchers who need unlimited access.', features: ['Unlimited verifications','Full TruthBot access','Smart Digest personalisation','Priority verification speed','Advanced source filtering','Social follow network','Messaging & voice calls','Premium badge on profile','Early access to new features'], cta: 'Start Premium Trial', highlighted: true, badge: 'Most Popular', gradient: 'linear-gradient(135deg, rgba(0,212,255,0.1), rgba(124,58,237,0.1))' },
    { name: 'Enterprise', price: 'Custom', period: 'contact us', description: 'For newsrooms, universities, and organisations deploying TruthLens at scale.', features: ['Everything in Premium','Team management dashboard','API access & webhooks','Custom ML model tuning','SLA & dedicated support','On-premise deployment option','SSO / SAML authentication','Advanced analytics & reporting'], cta: 'Contact Sales', highlighted: false }
  ];

  faqs = [
    { q: 'How accurate is TruthLens?', a: 'Our AI verification pipeline achieves ~95% accuracy on standard misinformation benchmarks, cross-validated against labelled datasets using Gemini, Wikipedia, and Guardian evidence.' },
    { q: 'What happens when evidence is insufficient?', a: 'TruthLens returns an UNCERTAIN verdict with partial reasoning when evidence is inconclusive, rather than making a false determination.' },
    { q: 'Is the mobile app free?', a: 'Yes! The Flutter app is free to download. The free tier gives you 10 verifications per day, with premium plans unlocking unlimited access.' },
    { q: 'Can I cancel my subscription?', a: 'Yes, you can cancel at any time from the Profile → Subscription section in the app. Premium access continues until the end of the billing period.' }
  ];

  openFaq: number | null = null;
  toggleFaq(i: number) { this.openFaq = this.openFaq === i ? null : i; }
}
