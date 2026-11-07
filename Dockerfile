# Build all three Revyme frontends and serve them as static assets.
FROM node:22-alpine AS build

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

ARG VITE_SANDBOX_URL=https://builder-canvas.giobadillo.dev
ARG VITE_PREVIEW_HOST=https://builder-preview.giobadillo.dev
ENV VITE_SANDBOX_URL=${VITE_SANDBOX_URL}
ENV VITE_PREVIEW_HOST=${VITE_PREVIEW_HOST}

RUN npm run build:all

FROM nginx:1.28-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/ /usr/share/nginx/html/editor/
COPY --from=build /app/dist/sandbox/ /usr/share/nginx/html/sandbox/
COPY --from=build /app/dist/preview-sandbox/ /usr/share/nginx/html/preview/

EXPOSE 3333 5174 5175
