# Deploying the HERB showcase to the VPS

Same shape as business-card and the other apps on the box: GitHub Actions
builds the image and pushes it to GHCR, Portainer runs it as a stack from
`deploy/docker-compose.yml`, Nginx Proxy Manager terminates TLS and forwards
to the container by name. The site is static, so there is no database and no
environment beyond `TAG`.

```
browser ──▶ NPM (<your-host>) ──proxy network──▶ herbworld:80
```

The `website/` folder is repo-shaped (Dockerfile, `.github/`, `site/`). Push
it as its own GitHub repository (e.g. `dschunge/herbworld-site`), or copy the
folder contents into a new repo root — the workflow expects the Dockerfile at
the repo root.

## One-time setup

1. **DNS.** In Cloudflare, an A record for the chosen host (e.g.
   `herb.aigentik.org`) → `72.61.77.138`, **DNS-only (grey cloud)**, like the
   other hosts. Orange cloud breaks the Let's Encrypt HTTP challenge because
   the zone redirects HTTP to HTTPS at the edge.

2. **Image.** Push to `main` (or run "Publish image" from the Actions tab)
   and wait for `ghcr.io/dschunge/herbworld-site:<sha>` to exist.

   If the repository is private, the package starts private too, and
   Portainer cannot pull it anonymously. Either make the package public
   (GitHub → profile → Packages → `herbworld-site` → Package settings →
   Change visibility → Public), or add a registry in Portainer
   (Registries → Add → Custom, URL `ghcr.io`, username `dschunge`,
   password = a personal access token with `read:packages`) and pick it
   when creating the stack.

3. **Stack.** Portainer → Stacks → Add stack → Repository (compose path
   `deploy/docker-compose.yml`), or paste the file. One environment
   variable, **no quotes**:

   | Variable | Value |
   | --- | --- |
   | `TAG` | short commit SHA from the workflow summary |

   Check from a shell on the VPS: `curl -I http://127.0.0.1:3381/` → `200`.
   If `3381` is already taken by another stack, change it in the compose
   file; NPM does not use it.

4. **NPM proxy host**, Let's Encrypt certificate, Force SSL on, websockets
   off (nothing needs them):

   | Domain | Forward Hostname | Forward Port |
   | --- | --- | --- |
   | `herb.aigentik.org` (or your host) | `herbworld` | `80` |

   Forward to the **container name and internal port**, not to
   `127.0.0.1:3381`. NPM runs in a container, so `127.0.0.1` there is NPM
   itself and every request 502s behind a valid certificate.

## Redeploying

Edit `site/index.html` or swap assets → push to `main` → note the SHA in the
workflow summary → set `TAG` in the stack → Update the stack.

## Things that will bite you

**The page is served with `Cache-Control: no-cache`, the media for 30 days.**
A new `index.html` shows on the next visit, but browsers that have seen the
site keep images and the montage video for up to a month. When you REPLACE an
asset's content, either give it a new file name or add/bump a `?v=2` query on
its references in `index.html` — a new URL makes every browser fetch the new
file.

**The montage video must stay all-keyframe.** `site/assets/montage.mp4` was
encoded with `-g 1` so the scroll scrub can seek backwards smoothly. If you
ever re-encode it, keep that flag or scrubbing will stutter.

**Service names are global on the shared `proxy` network.** Keep it
`herbworld`.

**This folder is a copy, not the design source.** The site is designed in the
Claude Design canvas (artifact "HERB Watch Showcase"). After design changes
there, regenerate `site/` from it rather than editing both places.
