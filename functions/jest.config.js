/** @type {import('jest').Config} */
const base = {
  preset: 'ts-jest',
  testEnvironment: 'node',
};

module.exports = {
  projects: [
    {
      ...base,
      displayName: 'unit',
      testMatch: ['<rootDir>/test/**/*.test.ts'],
      testPathIgnorePatterns: ['<rootDir>/test/rules/'],
    },
    {
      // Braucht den laufenden Firestore-Emulator: `npm run test:rules` im Repo-Root
      // startet ihn über `firebase emulators:exec`.
      ...base,
      displayName: 'rules',
      testMatch: ['<rootDir>/test/rules/**/*.test.ts'],
    },
  ],
};
