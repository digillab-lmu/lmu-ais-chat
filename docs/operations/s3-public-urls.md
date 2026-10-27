# Public S3 URLs behind the host nginx

How presigned S3 URLs (avatars, whitelabel logo, message attachments) reach browsers and LLM providers in the production deployment (`/srv/ais-chat`).

The host nginx configuration lives **outside this repository** (`/etc/nginx/sites-enabled/ais-chat` on the server). This document is its reference. Keep it in sync when the file on the server changes.

## URL flow

1. `getReadOnlySignedUrl` (`packages/shared/src/s3/index.ts`) signs with the S3 client. The client uses endpoint `https://${OTC_S3_HOSTNAME}` (production: `ais-s3-proxy`, set in `docker-compose.yml`) and `forcePathStyle: true`. The signed URL is therefore `https://ais-s3-proxy/ais-chat/<key>?X-Amz-...`, and the signature covers the host `ais-s3-proxy`.
2. If `OTC_PUBLIC_S3_URL` is set (production: `https://ais-chat.edpsych-ai.de/s3/`), protocol, host and path prefix are rewritten. The browser receives `https://ais-chat.edpsych-ai.de/s3/ais-chat/<key>?X-Amz-...`.
3. The host nginx strips `/s3/` and forwards to `127.0.0.1:19000`. This is the published port of the `ais-rustfs` container (`127.0.0.1:19000:9000` in `docker-compose.yml`), not of the `ais-s3-proxy` container.

**Rule:** the `Host` header that nginx sends to RustFS must equal the host the URL was signed for. Otherwise RustFS answers `403`. RustFS accepts the host `ais-s3-proxy` because of `RUSTFS_SERVER_DOMAINS: ais-s3-proxy`.

## nginx configuration (server `ais-chat.edpsych-ai.de`)

```nginx
    # Path-style URLs (since upstream sync 2026-10): /s3/ais-chat/<key>, signature is for Host ais-s3-proxy
    location /s3/ais-chat/ {
        rewrite ^/s3/(.*)$ /$1 break;
        proxy_pass http://127.0.0.1:19000;
        proxy_set_header Host ais-s3-proxy;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
    }

    # Legacy virtual-hosted URLs (before the sync): /s3/<key>, signature is for Host ais-chat.ais-s3-proxy
    location /s3/ {
        rewrite ^/s3/(.*)$ /$1 break;
        proxy_pass http://127.0.0.1:19000;
        proxy_set_header Host ais-chat.ais-s3-proxy;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
    }
```

nginx picks the longest matching prefix, so `/s3/ais-chat/...` always uses the first block. The second block only serves URLs that were signed before the sync. Presigned URLs expire after one day by default, so it is harmless to leave it in place and can be removed later.

## History

- Before the 2026-10 upstream sync (`16aa019e`) the S3 client used virtual-hosted style (no `forcePathStyle`). URLs looked like `/s3/<key>` and nginx sent `Host: ais-chat.ais-s3-proxy`.
- The sync brought upstream commit `ecb39cda` (`forcePathStyle: true`). From the rollout on (2026-10-27, about 18:18 CET) every signed URL became `/s3/ais-chat/<key>` with a signature for `ais-s3-proxy`. The old nginx block sent the wrong `Host`, so all avatars, the whitelabel logo and message attachments returned `403`.
- Fix on 2026-10-27, about 19:57: the `location /s3/ais-chat/` block above, added on the server only. nginx backup: `/root/backups/nginx-ais-chat-2026-10-27_195622.conf`.
- Not chosen: reverting `forcePathStyle` in the fork. It requires a rebuild, diverges from upstream, and the local RustFS development setup needs path style.

## Verifying

1. Reload a page with avatars (assistant overview) with a hard reload.
2. Check the status codes:

   ```bash
   grep '/s3/' /var/log/nginx/access.log | sed -E 's/\?[^ ]*//' | awk '{print $4, $9, $7}' | tail -15
   ```

   `/s3/ais-chat/...` must return `200`.

After changing the file on the server: `nginx -t && systemctl reload nginx`. Do not keep backups inside `sites-enabled/`, because nginx reads every file there.

## Related

`IMAGE_ATTACHMENT_MODE` (`apps/chat-bot/src/app/api/chat/utils.ts`, `determineImageAttachmentTypeForModel`) decides whether images are sent to the LLM as base64 or as a signed URL. In `url` mode the provider fetches the signed URL itself, so this document applies to that path as well.
