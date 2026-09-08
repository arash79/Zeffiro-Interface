import { GITHUB_BLOB, pathToSlug } from "./docs-catalog.js";

export function slugify(text) {
  return String(text)
    .toLowerCase()
    .replace(/[`*_]/g, "")
    .replace(/[^\w\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-");
}

function escapeHtml(text) {
  return String(text)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function encodeRepoPath(path) {
  return path
    .split("/")
    .filter(Boolean)
    .map((segment) => encodeURIComponent(segment))
    .join("/");
}

function rewriteHref(raw, currentSlug) {
  if (!raw) return { href: "#", external: false };
  const [pathPart, frag] = raw.split("#");
  const href = (pathPart || "").trim();
  if (/^(https?:|mailto:)/i.test(href)) {
    return { href: raw, external: !href.startsWith("mailto:") };
  }
  if (!href && frag) {
    const local = slugify(decodeURIComponent(frag));
    return {
      href: currentSlug ? `#${currentSlug}/${local}` : `#${local}`,
      external: false,
    };
  }
  const normalized = href.replace(/^\.\//, "");
  const file = normalized.split("/").pop();
  const adrKey = normalized.replace(/^(\.\.\/)*(docs\/)?/, "");
  const slug = pathToSlug[normalized] || pathToSlug[file] || pathToSlug[adrKey];
  if (slug) {
    const hash = frag ? `/${slugify(decodeURIComponent(frag))}` : "";
    return { href: `#${slug}${hash}`, external: false };
  }
  const repoPath = normalized.replace(/^(\.\.\/)+/, "").replace(/^docs\//, "");
  return {
    href: `${GITHUB_BLOB}${encodeRepoPath(repoPath)}${frag ? "#" + frag : ""}`,
    external: true,
  };
}

function renderInline(text, currentSlug) {
  let src = text;
  const stash = [];
  const park = (html) => {
    const key = `\u0000${stash.length}\u0000`;
    stash.push(html);
    return key;
  };

  src = src.replace(/`([^`]+)`/g, (_, code) => park(`<code>${escapeHtml(code)}</code>`));
  src = src.replace(/\\\((.+?)\\\)/g, (_, math) =>
    park(`<span class="doc-math">${escapeHtml(math)}</span>`),
  );
  src = src.replace(/\$([^$\n]+)\$/g, (_, math) =>
    park(`<span class="doc-math">${escapeHtml(math)}</span>`),
  );
  src = src.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, (_, alt, url) => {
    const { href } = rewriteHref(url.trim(), currentSlug);
    return park(
      `<img class="doc-img" src="${escapeHtml(href)}" alt="${escapeHtml(alt)}" />`,
    );
  });
  src = src.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_, label, url) => {
    const { href, external } = rewriteHref(url.trim(), currentSlug);
    const extra = external ? ' target="_blank" rel="noopener noreferrer"' : "";
    const cls = external ? ' class="doc-ext"' : "";
    return park(`<a href="${escapeHtml(href)}"${cls}${extra}>${escapeHtml(label)}</a>`);
  });
  src = escapeHtml(src);
  src = src.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  src = src.replace(/(^|[^\*])\*([^*\n]+)\*/g, "$1<em>$2</em>");
  stash.forEach((html, i) => {
    src = src.replace(`\u0000${i}\u0000`, html);
  });
  return src;
}

function splitTableRow(line) {
  const trimmed = line.trim().replace(/^\|/, "").replace(/\|$/, "");
  return trimmed.split("|").map((cell) => cell.trim());
}

function isFence(line) {
  return /^```/.test(line);
}

function calloutKind(text) {
  const head = text.replace(/[*_`]/g, "").trim().toLowerCase();
  if (/^warning\b|^caution\b|^important\b/.test(head)) return "warn";
  if (/^tip\b|^hint\b/.test(head)) return "tip";
  if (/^note\b|^n\.b\b/.test(head)) return "note";
  return "note";
}

export function renderMarkdown(md, options = {}) {
  const currentSlug = options.slug || "";
  const lines = md.replace(/\r\n/g, "\n").split("\n");
  const html = [];
  const toc = [];
  const usedIds = new Set();
  let i = 0;
  let usedH1 = false;
  const inline = (text) => renderInline(text, currentSlug);

  const uniqueId = (base) => {
    let id = base || "section";
    let n = 2;
    while (usedIds.has(id)) {
      id = `${base}-${n++}`;
    }
    usedIds.add(id);
    return id;
  };

  while (i < lines.length) {
    const line = lines[i];

    if (!line.trim()) {
      i += 1;
      continue;
    }

    if (isFence(line)) {
      const lang = line.slice(3).trim();
      const body = [];
      i += 1;
      while (i < lines.length && !isFence(lines[i])) {
        body.push(lines[i]);
        i += 1;
      }
      i += 1;
      html.push(
        `<pre class="doc-pre" data-lang="${escapeHtml(lang || "text")}"><code>${escapeHtml(body.join("\n"))}</code></pre>`,
      );
      continue;
    }

    if (/^\\\[/.test(line.trim()) || line.trim() === "\\[") {
      const math = [];
      if (line.trim() !== "\\[") math.push(line.replace(/^\\\[\s*/, "").replace(/\s*\\\]$/, ""));
      if (!/\\\]\s*$/.test(line)) {
        i += 1;
        while (i < lines.length && !/\\\]\s*$/.test(lines[i])) {
          math.push(lines[i]);
          i += 1;
        }
        if (i < lines.length) {
          math.push(lines[i].replace(/\s*\\\]\s*$/, ""));
          i += 1;
        }
      } else {
        i += 1;
      }
      html.push(`<div class="doc-math-block">${escapeHtml(math.join("\n").trim())}</div>`);
      continue;
    }

    const heading = /^(#{1,6})\s+(.+)$/.exec(line);
    if (heading) {
      const level = heading[1].length;
      const raw = heading[2].replace(/\s+#+\s*$/, "");
      const id = uniqueId(slugify(raw));
      const tocLabel = raw
        .replace(/[`*]/g, "")
        .replace(/\\\((.+?)\\\)/g, "$1")
        .replace(/\\\[(.+?)\\\]/g, "$1")
        .replace(/\$([^$]+)\$/g, "$1");
      if (level === 1 && !usedH1) {
        usedH1 = true;
        html.push(`<h1 id="${id}">${inline(raw)}</h1>`);
      } else {
        const tag = Math.min(level, 4);
        html.push(`<h${tag} id="${id}">${inline(raw)}</h${tag}>`);
        if (level <= 3) toc.push({ id, text: tocLabel, level });
      }
      i += 1;
      continue;
    }

    if (/^\|/.test(line) && i + 1 < lines.length && /^\|?\s*:?-{3,}/.test(lines[i + 1])) {
      const headers = splitTableRow(line);
      i += 2;
      const rows = [];
      while (i < lines.length && /^\|/.test(lines[i])) {
        rows.push(splitTableRow(lines[i]));
        i += 1;
      }
      const head = headers.map((cell) => `<th>${inline(cell)}</th>`).join("");
      const body = rows
        .map((row) => `<tr>${row.map((cell) => `<td>${inline(cell)}</td>`).join("")}</tr>`)
        .join("");
      html.push(
        `<div class="doc-table-wrap"><table class="doc-table"><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>`,
      );
      continue;
    }

    if (/^[-*]\s+/.test(line) || /^\d+\.\s+/.test(line)) {
      const ordered = /^\d+\.\s+/.test(line);
      const items = [];
      while (i < lines.length && (/^[-*]\s+/.test(lines[i]) || /^\d+\.\s+/.test(lines[i]))) {
        items.push(lines[i].replace(/^([-*]|\d+\.)\s+/, ""));
        i += 1;
      }
      const tag = ordered ? "ol" : "ul";
      html.push(
        `<${tag} class="doc-list">${items.map((item) => `<li>${inline(item)}</li>`).join("")}</${tag}>`,
      );
      continue;
    }

    if (/^>\s?/.test(line)) {
      const quote = [];
      while (i < lines.length && /^>\s?/.test(lines[i])) {
        quote.push(lines[i].replace(/^>\s?/, ""));
        i += 1;
      }
      const kind = calloutKind(quote[0] || "");
      html.push(
        `<aside class="doc-callout is-${kind}">${quote.map((q) => `<p>${inline(q)}</p>`).join("")}</aside>`,
      );
      continue;
    }

    if (/^---+\s*$/.test(line)) {
      html.push('<hr class="doc-rule" />');
      i += 1;
      continue;
    }

    const para = [line];
    i += 1;
    while (
      i < lines.length &&
      lines[i].trim() &&
      !isFence(lines[i]) &&
      !/^#{1,6}\s/.test(lines[i]) &&
      !/^\|/.test(lines[i]) &&
      !/^[-*]\s+/.test(lines[i]) &&
      !/^\d+\.\s+/.test(lines[i]) &&
      !/^>\s?/.test(lines[i]) &&
      !/^\\\[/.test(lines[i].trim())
    ) {
      para.push(lines[i]);
      i += 1;
    }
    const joined = para.join(" ");
    if (/^!\[[^\]]*\]\([^)]+\)$/.test(joined.trim())) {
      html.push(`<figure class="doc-figure">${inline(joined.trim())}</figure>`);
    } else {
      html.push(`<p>${inline(joined)}</p>`);
    }
  }

  return { html: html.join("\n"), toc };
}

export function typesetMath(root) {
  const katex = window.katex;
  if (!katex) return;
  root.querySelectorAll(".doc-math").forEach((el) => {
    try {
      katex.render(el.textContent, el, { throwOnError: false });
    } catch {
      /* keep escaped text */
    }
  });
  root.querySelectorAll(".doc-math-block").forEach((el) => {
    try {
      katex.render(el.textContent, el, { throwOnError: false, displayMode: true });
    } catch {
      /* keep escaped text */
    }
  });
}
