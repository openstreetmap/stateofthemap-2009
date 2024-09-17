FROM docker.io/debian:12 AS build

COPY . /app/_site

RUN find /app/_site/ -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.xml" -o -name "*.json" -o -name "*.svg" -o -name "*.ttf" -o -name "*.woff2" -o -name "*.woff" -o -name "*.eot" -o -name "*.otf" \) -print0 | xargs -0 -P4 --no-run-if-empty gzip -9k

# https://github.com/nginxinc/docker-nginx-unprivileged
FROM ghcr.io/nginxinc/nginx-unprivileged:stable-alpine AS webserver

RUN echo "absolute_redirect off;" >/etc/nginx/conf.d/no-absolute_redirect.conf
RUN echo "gzip_static on; gzip_proxied any;" >/etc/nginx/conf.d/gzip_static.conf
# brotli_static not yet available in standard nginx distribution
# RUN echo "brotli_static on; brotli_proxied any;" >/etc/nginx/conf.d/brotli_static.conf

# Copy built site from build stage
COPY --from=build /app/_site /usr/share/nginx/html

# Test configuration during docker build
RUN nginx -t

# Port the container will listen on
EXPOSE 8080
