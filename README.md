# HERB Wanduhren — showcase website

Static one-pager for the HERB wall-watch collection (5:1 scale, printed and
hand-assembled). Exported from the Claude Design canvas artifact
"HERB Watch Showcase" on 2026-11-21.

- `site/` — the deployable site: `index.html` + `assets/` (hero scenes,
  dial faces, gallery, the scroll-scrubbed montage video, exploded view).
- `Dockerfile` + `docker/nginx.conf` — static Nginx image.
- `.github/workflows/publish.yml` — builds `ghcr.io/dschunge/herbworld-site:<sha>`.
- `deploy/` — Portainer stack + VPS deployment guide (`deploy/README.md`).

Local preview:

```
cd site && python3 -m http.server 8080
# http://localhost:8080
```
