import next from 'eslint-config-next/core-web-vitals';
import nextTypescript from 'eslint-config-next/typescript';

// `eslint-config-next` v16 ships flat config arrays — spread them directly, no FlatCompat.
// The repo root config lints everything else and ignores `apps/web`, which owns its own
// React/Next rules here.
const config = [
  ...next,
  ...nextTypescript,
  { ignores: ['.next/**', 'out/**', 'next-env.d.ts'] },
  {
    rules: {
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
      ],
    },
  },
];

export default config;
