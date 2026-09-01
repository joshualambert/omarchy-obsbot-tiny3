# Releasing

Releases are produced entirely by
[`.github/workflows/release.yml`](.github/workflows/release.yml) — nothing is
uploaded by hand.

## Cutting a release

1. Bump `version` in `manifest.json`.
2. Update the `VER=` example in the README install section.
3. Run `./scripts/validate-plugin.sh .` locally (CI runs it too).
4. Commit, then tag and push:

   ```bash
   git tag -a v1.0.0 -m "OBSBOT Tiny 3 widget v1.0.0"
   git push origin main --follow-tags
   ```

The workflow refuses to publish if the tag and the `manifest.json` version
disagree, or if the plugin fails validation.

## What a release contains

| Asset | Notes |
|---|---|
| `omarchy-obsbot-tiny3-<ver>.tar.gz` | Plugin archive, rooted at the plugin id |
| `omarchy-obsbot-tiny3-<ver>.zip` | Same contents, zip |
| `SHA256SUMS` | Covers both archives |

Both archives also get a [Sigstore build-provenance
attestation](https://docs.github.com/actions/security-guides/using-artifact-attestations),
so a consumer can prove an artifact came from this repo's workflow at that tag:

```bash
gh attestation verify omarchy-obsbot-tiny3-<ver>.tar.gz \
  --repo joshualambert/omarchy-obsbot-tiny3
```

The archive root is the plugin id (`io.github.joshualambert.obsbot-tiny3`), so
`tar xzf … -C ~/.config/omarchy/plugins/` installs it in place.

## Relationship to the CLI

This widget is a front end for
[obsbot-tiny3-linux](https://github.com/joshualambert/obsbot-tiny3-linux), which
has its own release pipeline with the same guarantees (checksums, provenance,
and a PKGBUILD that pins its source tarball by `sha256`). The two version
independently; the widget only requires that `t3ctl` and `t3-preview` are on
`PATH`.
