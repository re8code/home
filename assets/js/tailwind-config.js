// Tailwind Play CDN 설정 — 30개 페이지가 공유하는 디자인 토큰의 정본.
// cdn.tailwindcss.com 스크립트 다음에 동기 로드해야 한다(전역 tailwind가 있어야 하고,
// Tailwind가 DOM을 스캔하기 전에 config가 잡혀야 하기 때문).
tailwind.config = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Pretendard', 'Pretendard Variable', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'SFMono-Regular', 'monospace'],
      },
      colors: {
        brand: {
          50: '#eefdf5',
          100: '#d5f9e4',
          200: '#aef1cd',
          300: '#74e4ad',
          400: '#3ecf8e',
          500: '#18b476',
          600: '#0e9261',
          700: '#0c7550',
          800: '#0d5d42',
          900: '#0c4c38',
          950: '#052b20',
        },
      },
      boxShadow: {
        glow: '0 0 60px -15px rgba(62, 207, 142, 0.45)',
      },
    },
  },
};
