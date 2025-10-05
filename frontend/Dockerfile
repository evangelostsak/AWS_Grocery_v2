########## Frontend Multi-Stage Build (React) ##########
# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Leverage build cache for deps
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

# Build-time backend URL injection (pipeline passes ARG)
ARG REACT_APP_BACKEND_SERVER
ENV REACT_APP_BACKEND_SERVER=${REACT_APP_BACKEND_SERVER}

# Copy application source (exclude build if present locally)
COPY . .

# Create React build
RUN npm run build \
 && touch build/BUILD_COMPLETE

# Stage 2: Runtime (nginx serving static files)
FROM nginx:1.27-alpine AS runtime

# Minimal hardening: remove default nginx index
RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/build /usr/share/nginx/html

# Optional: expose marker for any legacy wait logic
RUN test -f /usr/share/nginx/html/BUILD_COMPLETE || touch /usr/share/nginx/html/BUILD_COMPLETE

EXPOSE 80

# Healthcheck (simple static file presence)
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD [ -f /usr/share/nginx/html/BUILD_COMPLETE ] || exit 1

CMD ["nginx","-g","daemon off;"]