import { defineConfig } from 'astro/config';

// `site` feeds canonical URLs and social preview links.
export default defineConfig({
  site: 'https://rafeeq-muslim-companion.pages.dev',
  output: 'static',
  trailingSlash: 'never',
  build: { format: 'file' },
  prefetch: { prefetchAll: true, defaultStrategy: 'viewport' },
  image: {
    responsiveStyles: true,
  },
});
