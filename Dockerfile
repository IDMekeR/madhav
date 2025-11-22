# ---------- Build stage ----------
FROM node:20-alpine AS build
WORKDIR /app

# Copy only package files first (better layer caching)
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all source code
COPY . .

# Build static files (Vite outputs 'dist', CRA outputs 'build')
RUN npm run build

# ---------- Run stage ----------
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app to nginx html folder
# ⚠️ Adjust 'dist' → 'build' if you use Create React App
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
