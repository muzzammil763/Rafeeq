import { site } from './site';

// Lines for the scroll companion. Each step attaches to the first element
// matching `anchor`; the companion glides beside it and says `text` when
// that element is the one nearest the reading line. `side` puts it next to
// the section's picture rather than its text, so the bubble never hides copy.
export type Mood = 'neutral' | 'happy' | 'surprised' | 'wink' | 'love' | 'curious';

export interface CompanionAction {
  label: string;
  href: string;
  primary?: boolean;
}

export interface CompanionStep {
  anchor: string;
  /** Side of the page to sit on; defaults to alternating right/left. */
  side?: 'left' | 'right';
  text: string;
  mood?: Mood;
  actions?: CompanionAction[];
}

export interface CompanionScript {
  name: string;
  steps: CompanionStep[];
  exit: { text: string; actions: CompanionAction[] };
  idle: string;
  dismissKey: string;
}

export const companion: CompanionScript = {
  name: 'Rafeeq helper',
  dismissKey: 'rafeeq-companion-hidden',
  idle: 'Zzz… scroll a little and I’ll wake up.',
  steps: [
    {
      anchor: '.hero-copy',
      side: 'right',
      mood: 'happy',
      text: 'Assalamu alaikum! 👋 I’m Rafeeq’s little companion. Shall I show you around?',
      actions: [
        { label: 'Show me', href: '#features', primary: true },
        { label: 'Get the app', href: site.playStoreUrl },
      ],
    },
    {
      anchor: '#f-home',
      side: 'left',
      mood: 'curious',
      text: 'This is your home screen: the Hijri date and a live countdown to the next prayer.',
    },
    {
      anchor: '#quran',
      side: 'right',
      mood: 'love',
      text: 'Read every surah with translation, and listen to beautiful recitations. 📖',
    },
    {
      anchor: '#f-prayer',
      side: 'left',
      mood: 'happy',
      text: 'Adhan reminders for every prayer, so you never miss a salah.',
    },
    {
      anchor: '#f-qibla',
      side: 'right',
      mood: 'wink',
      text: 'Lost your direction? I always know which way the Kaaba is. 🕋',
    },
    {
      anchor: '#f-namaz',
      side: 'left',
      mood: 'neutral',
      text: 'New to salah, or teaching your kids? Learn it step by step.',
    },
    {
      anchor: '#f-ayah',
      side: 'right',
      mood: 'love',
      text: 'Turn an ayah into a picture and share it with someone you love. 💚',
    },
    {
      anchor: '#more',
      side: 'left',
      mood: 'surprised',
      text: 'And there’s so much more in one app!',
    },
    {
      anchor: '.theme-grid',
      side: 'right',
      mood: 'happy',
      text: 'اردو بھی! Fully in Urdu with Nastaleeq, in light or dark.',
    },
    {
      anchor: '#open-source',
      side: 'right',
      mood: 'love',
      text: 'Built by two brothers, for the Ummah. Will you give us a ⭐ on GitHub?',
      actions: [{ label: 'Open GitHub', href: site.githubUrl, primary: true }],
    },
    {
      anchor: '#faq',
      side: 'left',
      mood: 'curious',
      text: 'Got a question? Tap one, I’ll wait. 🙂',
    },
    {
      anchor: '.final',
      side: 'right',
      mood: 'happy',
      text: 'Ready? Rafeeq is free for everyone, In Sha Allah.',
      actions: [{ label: 'Get it on Google Play', href: site.playStoreUrl, primary: true }],
    },
  ],
  exit: {
    text: 'Wait! Rafeeq is free and takes seconds to install. 🤲',
    actions: [{ label: 'Okay, get Rafeeq', href: site.playStoreUrl, primary: true }],
  },
};
