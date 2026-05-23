// @ts-check
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  testMatch: ['**/*.spec.js'],
  timeout: 30_000,
  retries: 0,
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'tests/report' }]],
  use: {
    headless: true,
    // No baseURL — tests inject content directly
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  // Artifacts stored alongside test files
  outputDir: 'tests/results',
});
