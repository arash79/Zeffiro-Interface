# Zeffiro Interface website

Optional static homepage. It is **not** on the MATLAB path and is not required to run Zeffiro.

Docs pages are copied from [`docs/`](../docs/) when you run the Vite dev server or production build. Edit the repository guides, not the generated copies under `website/content/docs/`.

`website/dist/` and `website/content/docs/` are committed so Cloudflare Pages can publish without a Node build. After changing `docs/` or `website/*.html`, run `npm run build` here and commit the updated `dist/`. **Do not commit `website/node_modules/`.**

```bash
cd website
npm install
npm run dev
```

Open http://127.0.0.1:5173/

Production build (`npm run build`) writes `website/dist/`, including `docs.html`, the copied markdown, and image assets. Preview with `npm run preview`.

A plain `python3 -m http.server` from this folder can serve the HTML, but module scripts and the Docs viewer expect the Vite dev server or the production `dist/` output.

Hero, pipeline, method, and feature images in `assets/img/` are original illustrations produced for this site, not MATLAB GUI screenshots and not third-party stock. The page typeface is Inter, loaded from Google Fonts (SIL OFL 1.1; see [`THIRD_PARTY.md`](../THIRD_PARTY.md)). Docs, GitHub, Discussions, Issues, license, examples, and wiki tutorial links point at the official `sampsapursiainen/zeffiro_interface` project. Worked MATLAB examples in this tree live under [`+examples/`](../+examples/).
