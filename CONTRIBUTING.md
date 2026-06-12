# Contributing

Thanks for helping make server setups easier for everyone!

## Adding a new path or add-on

1. Create a folder under `paths/` (complete stack) or `addons/` (single building block).
2. Include a `README.md` that a newcomer can follow top-to-bottom: prerequisites, setup steps, "how do I know it works", and update/uninstall notes.
3. Ship working config files — `docker compose config` must pass, scripts must be `shellcheck`-clean.
4. Pin image versions where stability matters, and never commit secrets (use `.env.example`).

## Fixes & improvements

Small PRs are welcome. For larger changes, open an issue first so we can discuss direction.

## Style

- Write docs for someone setting this up for the first time.
- Prefer boring, proven defaults over clever configuration.
- Every exposed port, volume and env var should be explained or obvious.
