import { cpSync, mkdirSync, readdirSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig } from "vite";

const root = dirname(fileURLToPath(import.meta.url));
const repoDocs = resolve(root, "../docs");

const DOC_FILES = [
  "getting-started.md",
  "glossary.md",
  "conventions.md",
  "zef-state.md",
  "architecture.md",
  "methods.md",
  "troubleshooting.md",
  "developer-guide.md",
  "upstream.md",
];

function copyMarkdownTree(fromDir, toDir) {
  mkdirSync(toDir, { recursive: true });
  for (const name of readdirSync(fromDir)) {
    const from = join(fromDir, name);
    const to = join(toDir, name);
    if (statSync(from).isDirectory()) {
      copyMarkdownTree(from, to);
    } else if (name.endsWith(".md")) {
      cpSync(from, to);
    }
  }
}

function syncDocsFromRepo() {
  const dest = join(root, "content", "docs");
  mkdirSync(join(dest, "adr"), { recursive: true });
  for (const file of DOC_FILES) {
    cpSync(join(repoDocs, file), join(dest, file));
  }
  copyMarkdownTree(join(repoDocs, "adr"), join(dest, "adr"));
}

function copyPublicStatics(outDir) {
  for (const dir of ["assets", "content"]) {
    cpSync(join(root, dir), join(outDir, dir), { recursive: true });
  }
  cpSync(join(root, "favicon.svg"), join(outDir, "favicon.svg"));
}

function repoDocsPlugin() {
  return {
    name: "sync-repo-docs",
    buildStart() {
      syncDocsFromRepo();
    },
    configureServer() {
      syncDocsFromRepo();
    },
    closeBundle() {
      copyPublicStatics(join(root, "dist"));
    },
  };
}

export default defineConfig({
  root: ".",
  base: "./",
  publicDir: false,
  plugins: [repoDocsPlugin()],
  server: {
    port: 5173,
    host: true,
  },
  build: {
    rollupOptions: {
      input: {
        main: resolve(root, "index.html"),
        features: resolve(root, "features.html"),
        papers: resolve(root, "papers.html"),
        community: resolve(root, "community.html"),
        tutorials: resolve(root, "tutorials.html"),
        api: resolve(root, "api.html"),
        docs: resolve(root, "docs.html"),
      },
    },
  },
});
