# Feed cache format

`data/items.json` shape:

- `updated_at`: ISO 8601 UTC timestamp of the last write that changed this file
- `newest_id`: highest post id already seen (used as `since_id` on the next check)
- `hash`: SHA-256 hex digest of the UTF-8 JSON array of item `id` values, sorted lexicographically (empty list is `[]`)
- `items`: the current batch, newest first, at most 50, deduped by `id`

Each item:

- `id`: post id
- `url`: `https://x.com/<handle>/status/<id>`
- `handle`: account username, no `@`
- `text`: post text, trimmed to 280 characters
- `created_at`: ISO 8601 UTC
- `media_type`: optional; present when the post has attached media. One or more of `photo`, `video`, `animated_gif`, comma-separated

If a check finds no new posts, this file is left unchanged.
