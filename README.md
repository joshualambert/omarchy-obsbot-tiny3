# OBSBOT Tiny 3 — Omarchy bar widget

A native [Omarchy](https://omarchy.org/) / Quickshell bar widget to control an
**OBSBOT Tiny 3 series** webcam: a camera icon in the bar that opens a popup with
sleep/wake, AI tracking, HDR, white balance, a preview-resolution picker, and a
live video preview.

<p align="center">
  <img src="preview.png" alt="OBSBOT Tiny 3 bar widget" width="360">
</p>

- **Bar icon** — pulses while the camera is in use; left-click opens the popup,
  right-click toggles sleep, middle-click opens the live preview.
- **Popup** — toggle switches for sleep/wake, AI tracking, HDR, and auto white
  balance; a preview-resolution dropdown (720p/1080p/2160p); recenter; and a
  **Live preview** button.

The widget respects the camera's ability to sleep: it reads only the cheap USB
power state in the background (nothing is opened), and only the live preview
streams the camera — which is released the moment the preview window closes.

## Requirements

This widget is a front-end for the **obsbot-tiny3-linux** CLI. Install that
project **first** from one of its
[tagged releases](https://github.com/joshualambert/obsbot-tiny3-linux/releases)
— every release ships checksummed, provenance-attested binaries and `.deb` /
`.rpm` / Arch packages, so you can verify what you install rather than building
whatever is on `main`:

```bash
VER=0.1.0
REL=https://github.com/joshualambert/obsbot-tiny3-linux/releases/download/v$VER

curl -fLO "$REL/obsbot-tiny3-linux-$VER-x86_64-linux-musl.tar.gz"
curl -fLO "$REL/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS      # must print: OK

tar xzf "obsbot-tiny3-linux-$VER-x86_64-linux-musl.tar.gz"
cd "obsbot-tiny3-linux-$VER-x86_64-linux-musl" && ./install.sh
```

Afterwards the `t3ctl` and `t3-preview` commands it provides must be on your
`PATH`. See that project's README for the `.deb`/`.rpm`/Arch package routes and
for `gh attestation verify`.

The live preview additionally uses [`mpv`](https://mpv.io/) (install it with your
distribution's package manager). This widget itself installs nothing, runs no
privileged commands, and writes no configuration of its own — it only invokes the
`t3ctl` / `t3-preview` commands you installed above.

## Install

From the Omarchy plugin marketplace:

```
omarchy plugin install io.github.joshualambert.obsbot-tiny3
```

### Or install a pinned release by hand

Every `v*` tag publishes an archive plus a `SHA256SUMS` file and a
[Sigstore build-provenance attestation](https://docs.github.com/actions/security-guides/using-artifact-attestations)
— see [**Releases**](https://github.com/joshualambert/omarchy-obsbot-tiny3/releases).
The archive's root directory is the plugin id, so it extracts straight into your
plugins folder:

```bash
VER=1.0.0
REL=https://github.com/joshualambert/omarchy-obsbot-tiny3/releases/download/v$VER

curl -fLO "$REL/omarchy-obsbot-tiny3-$VER.tar.gz"
curl -fLO "$REL/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS      # must print: OK

# optional: prove the archive came from this repo's release workflow
gh attestation verify "omarchy-obsbot-tiny3-$VER.tar.gz" \
  --repo joshualambert/omarchy-obsbot-tiny3

mkdir -p ~/.config/omarchy/plugins
tar xzf "omarchy-obsbot-tiny3-$VER.tar.gz" -C ~/.config/omarchy/plugins/
omarchy plugin enable io.github.joshualambert.obsbot-tiny3
```

### Add it to your bar

Put this entry in the `right` (or `left` / `center`) list under `bar.layout` in
`~/.config/omarchy/shell.json`:

```json
{ "id": "io.github.joshualambert.obsbot-tiny3" }
```

and reload the shell:

```
omarchy restart shell
```

## Removal

Remove the `{ "id": "io.github.joshualambert.obsbot-tiny3" }` entry from
`~/.config/omarchy/shell.json`, then:

```
omarchy plugin disable io.github.joshualambert.obsbot-tiny3
omarchy plugin remove io.github.joshualambert.obsbot-tiny3
omarchy restart shell
```

The widget writes no configuration of its own and never modifies your files.

## Development

`./scripts/validate-plugin.sh .` runs the same manifest checks the Omarchy shell
enforces before it will load a plugin; CI runs it on every push, and the release
workflow runs it again before publishing. Releasing is documented in
[`RELEASING.md`](RELEASING.md).

## License

MIT — see [`LICENSE`](LICENSE). Part of the **obsbot-tiny3-linux** project:
<https://github.com/joshualambert/obsbot-tiny3-linux>
