# OBSBOT Tiny 3 — Omarchy bar widget

A native [Omarchy](https://omarchy.org/) / Quickshell bar widget to control an
**OBSBOT Tiny 3 series** webcam: a camera icon in the bar that opens a popup with
sleep/wake, AI tracking, HDR, white balance, a preview-resolution picker, and a
live video preview.

<p align="center">
  <img src="preview.png" alt="OBSBOT Tiny 3 bar widget" width="360">
</p>

- **Bar icon** — pulses while the camera is in use (USB active); left-click opens
  the popup, right-click toggles sleep, middle-click opens the live preview.
- **Popup** — toggle switches for sleep/wake, AI tracking, HDR, and auto white
  balance; a preview-resolution dropdown (720p/1080p/2160p); recenter; and a
  **Live preview** button.

The widget respects the camera's ability to sleep: it reads only the cheap USB
power state in the background (nothing is opened), and only the live preview
streams the camera — which is released the moment the preview window closes.

## Dependencies

This widget is a front-end for the **[obsbot-tiny3-linux](https://github.com/joshualambert/obsbot-tiny3-linux)**
CLI. Install that first — it provides the `t3ctl` and `t3-preview` commands the
widget calls (both must be on your `PATH`):

```bash
git clone https://github.com/joshualambert/obsbot-tiny3-linux
cd obsbot-tiny3-linux && ./install.sh
```

`t3-preview` also needs **mpv** (`sudo pacman -S mpv`). The camera and its udev
access are set up by obsbot-tiny3-linux's installer.

## Install

Via the Omarchy plugin marketplace (once listed):

```bash
omarchy plugin install io.github.joshualambert.obsbot-tiny3
```

Or manually:

```bash
git clone https://github.com/joshualambert/omarchy-obsbot-tiny3 \
  ~/.config/omarchy/plugins/io.github.joshualambert.obsbot-tiny3
omarchy plugin enable io.github.joshualambert.obsbot-tiny3
```

Then add the widget to your bar — put this in the `right` (or `left`/`center`)
list under `bar.layout` in `~/.config/omarchy/shell.json`:

```json
{ "id": "io.github.joshualambert.obsbot-tiny3" }
```

and reload the shell:

```bash
omarchy restart shell
```

## Removal

```bash
# remove {"id": "io.github.joshualambert.obsbot-tiny3"} from ~/.config/omarchy/shell.json first, then:
omarchy plugin disable io.github.joshualambert.obsbot-tiny3
rm -rf ~/.config/omarchy/plugins/io.github.joshualambert.obsbot-tiny3
omarchy restart shell
```

The widget writes no configuration of its own and never modifies your files.

## License

MIT — see [`LICENSE`](LICENSE). Part of the
[obsbot-tiny3-linux](https://github.com/joshualambert/obsbot-tiny3-linux) project.
