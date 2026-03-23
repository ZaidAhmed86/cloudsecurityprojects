# Use an explicit version tag, never 'latest'
# node:20-alpine is a minimal Linux image with Node.js 20
FROM node:20-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package files first, before copying source code
# This allows Docker to cache the npm install layer
# If only source code changes, Docker skips npm install on rebuild
COPY package*.json ./

# Install only production dependencies
# --omit=dev skips devDependencies like nodemon
RUN npm install --omit=dev

# Copy the rest of the application source code
COPY . .

# Document which port the app listens on
# This is informational - it does not actually publish the port
EXPOSE 3000

# Run the container as a non-root user
# By default Docker runs as root which is a security risk
# node:alpine images include a built-in 'node' user for this purpose
USER node

# Start the application
CMD ["node", "index.js"]