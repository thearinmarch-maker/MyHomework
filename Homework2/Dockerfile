FROM nginx:stable-alpine
ARG APP_VERSION=local
ARG GIT_SHA=local
LABEL org.opencontainers.image.revision="$GIT_SHA"
LABEL org.opencontainers.image.version="$APP_VERSION"
COPY index.html /usr/share/nginx/html/index.html
RUN printf '%s\n' "$APP_VERSION" > /usr/share/nginx/html/version.txt \
    && printf 'ok\n' > /usr/share/nginx/html/health
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/health || exit 1
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
