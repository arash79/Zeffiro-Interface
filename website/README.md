# Zeffiro Interface website

Optional static homepage. It is **not** on the MATLAB path and is not required to run Zeffiro.

Docs pages are copied from [`docs/`](../docs/) when you run the Vite dev server or production build. Edit the repository guides, not the generated copies under `website/content/docs/` (that directory is gitignored).

```bash
cd website
npm install
npm run dev
```

Open http://127.0.0.1:5173/

Production build (`npm run build`) writes `website/dist/`, including `docs.html`, the copied markdown, and image assets. Preview with `npm run preview`.

A plain `python3 -m http.server` from this folder can serve the HTML, but module scripts and the Docs viewer expect the Vite dev server or the production `dist/` output.

Hero and feature images in `assets/img/` are project-rendered illustrations of Zeffiro workflows, not third-party stock. Docs, GitHub, Discussions, Issues, license, examples, and wiki tutorial links point at the official `sampsapursiainen/zeffiro_interface` project. Worked MATLAB examples in this tree live under [`+examples/`](../+examples/).
