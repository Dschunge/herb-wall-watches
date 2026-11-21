# Serves the HERB wall-watch showcase (site/index.html + assets) with a tiny
# static Nginx. Same shape as the business-card image.
FROM nginx:1.27-alpine

# Container-side Nginx config: caching, gzip, byte-range video, no directory listing.
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Only the deployable files.
COPY site/ /usr/share/nginx/html/

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
