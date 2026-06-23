# Dockerfile for CI preview generation and testing
# Based on the official Playwright image (includes Node.js + Chromium + all deps)
#
# Build:  docker build -t common-ressources-preview docker/
# Run:    docker run --rm -v $PWD:/repo common-ressources-preview npx playwright test
#         docker run --rm -v $PWD:/repo common-ressources-preview node tests/generate-previews.js

FROM mcr.microsoft.com/playwright:v1.61.1-jammy

# Add PHP (for legacy GD-based colortest.php scripts) and jq (for validate.sh)
RUN apt-get update && apt-get install -y \
    php-cli \
    php-gd \
    jq \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /repo

# Install Node dependencies at build time if package.json is present
COPY package.json ./
RUN npm install --prefer-offline 2>/dev/null || true

# Install Playwright browsers (chromium is already in the base image,
# but this ensures the binaries match the installed package version)
RUN npx playwright install chromium

# Default command: run Playwright tests
CMD ["npx", "playwright", "test"]
