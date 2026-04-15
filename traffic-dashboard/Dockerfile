# ============================================================
#  Dockerfile — Intelligent Traffic Management Dashboard
#  Presentation Layer — Node.js + Express
# ============================================================

# Stage 1: Use official lightweight Node.js image
FROM node:20-alpine

# Set working directory inside the container
WORKDIR /app

# Stage 2: Install dependencies
# Copy package files FIRST so Docker can cache this layer.
# If source code changes but package.json doesn't, this layer
# is not rebuilt — saves time on every build.
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Stage 3: Copy application source
# Copy everything else (server.js, views, public, data)
COPY . .

# Stage 4: Expose port & run
# Tell Docker the app listens on port 3002
EXPOSE 3002

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3002

# Start the Express server
CMD ["node", "server.js"]
