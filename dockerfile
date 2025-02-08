# Use official Node.js image for building the app
FROM node:18 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package files first for better caching
COPY package.json package-lock.json ./

# Install dependencies with --legacy-peer-deps to avoid dependency conflicts
RUN npm install --legacy-peer-deps

# Copy the rest of the application files
COPY . .

# Build the Angular application for production
RUN npm run build --configuration=production

# Use a lightweight Nginx image for serving the built application
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default Nginx static files
RUN rm -rf ./*

# Copy built files from the previous stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 8080 (default for OpenShift)
EXPOSE 8080

# Copy a basic Nginx configuration (optional but recommended)
COPY nginx.conf /etc/nginx/nginx.conf

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
