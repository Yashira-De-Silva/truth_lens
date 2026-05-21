import { bootstrapApplication } from '@angular/platform-browser';
import { App } from './app/app';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';

bootstrapApplication(App, {
  providers: [
    provideAnimations(),
    provideHttpClient(),
    provideRouter([
      {
        path: '',
        loadComponent: () =>
          import('./app/features/landing/landing/landing').then(m => m.LandingComponent)
      },
      {
        path: 'features',
        loadComponent: () =>
          import('./app/features/features/features/features').then(m => m.FeaturesComponent)
      },
      {
        path: 'how-it-works',
        loadComponent: () =>
          import('./app/features/how-it-works/how-it-works/how-it-works').then(m => m.HowItWorksComponent)
      },
      {
        path: 'pricing',
        loadComponent: () =>
          import('./app/features/pricing/pricing/pricing').then(m => m.PricingComponent)
      },
      {
        path: 'about',
        loadComponent: () =>
          import('./app/features/about/about/about').then(m => m.AboutComponent)
      },
      { path: '**', redirectTo: '' }
    ])
  ]
}).catch(err => console.error(err));
