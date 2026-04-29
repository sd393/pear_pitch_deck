# Giftly pitch deck

Static HTML deck. Each slide is a standalone page sized 1920×1080. A shared
stylesheet (`_shared.css`) defines the design tokens — colors, type scale,
the underlined-italic accent device — that every slide pulls from.

## Layout

```
slide-1.html  …  slide-10.html      main deck (10 slides)
slide-a1.html …  slide-a4.html      appendix (4 slides)
onepager.html                       letter-size leave-behind
_shared.css                         design tokens + base styles
giftly_logo.png                     coral price-tag mark
giftly-pitch.pdf                    rendered deck (rebuild with build.sh)
giftly-onepager.pdf                 rendered one-pager
slide-N.png / slide-aN.png          thumbnails for the gallery
index.html                          gallery + entry point
present.html                        keyboard-driven presenter
build.sh                            regen thumbnails + PDF
```

## Run the live preview

```bash
npx --yes live-server --port=8000 --no-browser --quiet
```

Then open `http://localhost:8000/`. Edits to any HTML or CSS file hot-reload
the open tab automatically. The gallery at `/` links to every slide, the
one-pager, the rendered PDF, and the presenter.

## Present

Click **▶ Present** in the gallery (or open `/present.html`).

| Key | Action |
|---|---|
| `→` `Space` `PgDn` `n` `j` | Next slide |
| `←` `PgUp` `p` `k` | Previous slide |
| `1`–`9` | Jump to slide N (main deck) |
| `0` | Jump to slide 10 |
| `A` | Jump to first appendix slide |
| `Home` / `End` | First / last slide |
| `F` | Toggle fullscreen |
| `H` | Toggle the page-counter HUD |
| `G` | Back to gallery |
| `Esc` | Exit fullscreen, then exit to gallery |

You can also click the right half of the screen to advance and the left half
to go back. The slide auto-scales to any viewport while preserving the
1920×1080 aspect ratio, so it works on a laptop, projector, or external
display without setup. Press `F` once and present.

The URL hash mirrors the current slide (`#3` = slide 3) — share a deep link or
reload back to where you were.

## Edit a slide

Each slide is its own HTML file with an inline `<style>` block on top of
`_shared.css`. Common patterns:

- Display text → `font-family: 'Fraunces'`, weight 300–400.
- Eyebrows, page counters, role labels → `'Instrument Sans'`, uppercase, tracked.
- Accent words → wrap in `<span class="accent">`. That's italic, coral,
  underlined — the deck's signature device.
- Background tone → set `html, body { background: var(--cream-warm); }` and
  the matching `.slide { background: ...; }`. Tones available: `--cream`,
  `--cream-warm`, `--cream-deep`, `--coral`.
- Page-counter footer → `<div class="footer">`. Update the second `<span>` to
  match the slide's position (e.g. `08 · 10`).

When you add or remove a slide, search the deck for the page count
(`grep -l "0X · 0Y" *.html`) and bump every footer to the new total.

## Rebuild the PDF and thumbnails

```bash
./build.sh           # both
./build.sh pdf       # just giftly-pitch.pdf
./build.sh thumbs    # just slide-*.png
```

The script uses headless Chromium to render each slide, then `pdfunite`
(poppler-utils) to merge them. The `@page` rule in `_shared.css` keeps every
page at the native 1920×1080 (20in × 11.25in at 96dpi).

Dependencies: `chromium` (or `chromium-browser` / `google-chrome`) and
`pdfunite` from `poppler-utils`.

## Design system at a glance

```
cream         #f6eee3       primary background
cream-warm    #f1e6d4       data slides
cream-deep    #eadbc3       reserved
coral         #e55a4e       accent + emotional-peak slides
coral-deep    #c84538       appendix eyebrow
ink           #2a1a12       primary text (warm brown-black)
ink-soft      #4d3828       secondary text
muted-warm    #8a7566       eyebrows, footers, labels
line          #d9c9b3       hairline dividers
```

Two fonts: **Fraunces** (variable serif) carries every display size; **Instrument Sans** carries every label, eyebrow, and footer. No icons, no charts — hierarchy is type and color.
