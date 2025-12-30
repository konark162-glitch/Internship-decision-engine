# --- Stage 1: Build the React App ---
FROM node:20-alpine as builder

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of your app files
COPY . .

# Receive the API Key from the build arguments
ARG GEMINI_API_KEY

# Write the key to a .env.local file so Vite can use it during build
# We add "VITE_" because Vite ignores variables without it by default
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

# Build the app (creates a 'dist' folder)
RUN npm run build

# --- Stage 2: Serve with Nginx ---
FROM nginx:alpine

# Copy the build output from the previous stage to Nginx's web folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Google Cloud Run expects us to listen on port 8080
EXPOSE 8080

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
