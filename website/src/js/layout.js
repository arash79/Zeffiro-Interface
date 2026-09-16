import {
  DISCUSSIONS,
  EMAIL,
  EXAMPLES,
  GITHUB,
  ISSUES,
  LICENSE,
  pages,
} from "./config.js";

const logoMark = () =>
  `<img class="logo-mark" src="favicon.svg" alt="" width="34" height="34" />`;

export function headerHTML(active) {
  const item = (id, href, label, external = false) => {
    const current = active === id ? ' aria-current="page"' : "";
    const extra = external
      ? ' target="_blank" rel="noopener noreferrer"'
      : "";
    return `<a class="nav-link" href="${href}"${current}${extra}>${label}</a>`;
  };

  return `
    <a class="skip-link" href="#main">Skip to content</a>
    <header class="site-header">
      <div class="header-inner">
        <a class="brand" href="${pages.overview}" aria-label="Zeffiro Interface home">
          ${logoMark()}
          <span class="brand-text">
            <span class="brand-name">ZEFFIRO</span>
            <span class="brand-sub">INTERFACE</span>
          </span>
        </a>
        <nav class="site-nav" aria-label="Primary">
          ${item("overview", pages.overview, "Overview")}
          ${item("features", pages.features, "Features")}
          ${item("docs", pages.docs, "Docs")}
          ${item("community", pages.community, "Community")}
        </nav>
        <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="mobile-nav" aria-label="Open menu">
          <span></span><span></span>
        </button>
      </div>
      <div class="mobile-nav" id="mobile-nav" hidden>
        ${item("overview", pages.overview, "Overview")}
        ${item("features", pages.features, "Features")}
        ${item("docs", pages.docs, "Docs")}
        ${item("community", pages.community, "Community")}
      </div>
    </header>
  `;
}

export function footerHTML() {
  return `
    <footer class="site-footer">
      <div class="container footer-grid">
        <div class="footer-brand">
          <a class="brand" href="${pages.overview}" aria-label="Zeffiro Interface home">
            ${logoMark()}
            <span class="brand-text">
              <span class="brand-name">ZEFFIRO</span>
              <span class="brand-sub">INTERFACE</span>
            </span>
          </a>
          <p>Open-source finite-element modeling and inverse imaging for EEG/MEG, and beyond.</p>
          <div class="social-row" aria-label="Project links">
            <a href="${GITHUB}" target="_blank" rel="noopener noreferrer" aria-label="GitHub repository">
              ${iconGithub()}
            </a>
            <a href="${DISCUSSIONS}" target="_blank" rel="noopener noreferrer" aria-label="GitHub Discussions">
              ${iconChat()}
            </a>
            <a href="${ISSUES}" target="_blank" rel="noopener noreferrer" aria-label="GitHub Issues">
              ${iconIssues()}
            </a>
            <a href="${EMAIL}" aria-label="Email Sampsa Pursiainen">
              ${iconMail()}
            </a>
          </div>
        </div>
        <div>
          <h2 class="footer-heading">Project</h2>
          <ul class="footer-links">
            <li><a href="${GITHUB}" target="_blank" rel="noopener noreferrer">GitHub</a></li>
            <li><a href="${LICENSE}" target="_blank" rel="noopener noreferrer">License</a></li>
          </ul>
        </div>
        <div>
          <h2 class="footer-heading">Learn</h2>
          <ul class="footer-links">
            <li><a href="${pages.docs}">Documentation</a></li>
            <li><a href="${pages.tutorials}">Tutorials</a></li>
            <li><a href="${EXAMPLES}" target="_blank" rel="noopener noreferrer">Examples</a></li>
            <li><a href="${pages.api}">API Reference</a></li>
          </ul>
        </div>
        <div>
          <h2 class="footer-heading">Community</h2>
          <ul class="footer-links">
            <li><a href="${DISCUSSIONS}" target="_blank" rel="noopener noreferrer">Discussions</a></li>
            <li><a href="${ISSUES}" target="_blank" rel="noopener noreferrer">Issues</a></li>
          </ul>
        </div>
      </div>
      <p class="copyright">© 2018–2026 Zeffiro Interface. GNU GPL v3.</p>
    </footer>
  `;
}

function strokeIcon(inner) {
  return `<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">${inner}</svg>`;
}

function iconGithub() {
  return `<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 2C6.48 2 2 6.58 2 12.26c0 4.52 2.87 8.36 6.84 9.72.5.1.68-.22.68-.49 0-.24-.01-.87-.01-1.71-2.78.62-3.37-1.37-3.37-1.37-.45-1.18-1.11-1.5-1.11-1.5-.91-.64.07-.63.07-.63 1 .07 1.53 1.06 1.53 1.06.9 1.57 2.36 1.12 2.94.86.09-.67.35-1.12.63-1.38-2.22-.26-4.56-1.14-4.56-5.07 0-1.12.39-2.03 1.03-2.75-.1-.26-.45-1.31.1-2.73 0 0 .84-.27 2.75 1.05A9.3 9.3 0 0 1 12 6.84c.85 0 1.71.12 2.51.34 1.9-1.32 2.74-1.05 2.74-1.05.55 1.42.2 2.47.1 2.73.64.72 1.03 1.63 1.03 2.75 0 3.94-2.34 4.8-4.58 5.06.36.32.68.94.68 1.9 0 1.37-.01 2.47-.01 2.81 0 .27.18.6.69.49A10.03 10.03 0 0 0 22 12.26C22 6.58 17.52 2 12 2Z"/></svg>`;
}

function iconChat() {
  return strokeIcon(`<path d="M5 6.5h14a1.5 1.5 0 0 1 1.5 1.5v7A1.5 1.5 0 0 1 19 16.5H11l-4 3v-3H5A1.5 1.5 0 0 1 3.5 15V8A1.5 1.5 0 0 1 5 6.5Z"/>`);
}

function iconIssues() {
  return strokeIcon(`<circle cx="12" cy="12" r="7.2"/><circle cx="12" cy="12" r="2.05" fill="currentColor" stroke="none"/>`);
}

function iconMail() {
  return strokeIcon(`<rect x="3.5" y="6.5" width="17" height="11" rx="1.6"/><path d="M4 7.4 12 13l8-5.6"/>`);
}

const ATMOSPHERE = `
  <div class="atmosphere" aria-hidden="true">
    <div class="atmosphere-glow"></div>
    <svg class="atmosphere-field" viewBox="0 0 1600 900" preserveAspectRatio="xMidYMid slice">
      <defs>
        <radialGradient id="atmFadeShared" cx="50%" cy="42%" r="58%">
          <stop offset="0" stop-color="#27A8AA" stop-opacity="0.16"/>
          <stop offset="1" stop-color="#27A8AA" stop-opacity="0"/>
        </radialGradient>
      </defs>
      <ellipse cx="1180" cy="210" rx="420" ry="260" fill="url(#atmFadeShared)"/>
      <g fill="none" stroke="#155F60" stroke-width="0.6" opacity="0.22">
        <path d="M120 760 L310 430 L540 520 L470 780 Z"/>
        <path d="M310 430 L540 520 L610 300 Z"/>
        <path d="M120 760 L310 430 L80 520 Z"/>
        <path d="M1320 640 L1480 410 L1560 700 Z"/>
      </g>
      <g fill="#50CCC9" opacity="0.35">
        <circle cx="310" cy="430" r="2.2"/>
        <circle cx="540" cy="520" r="2.2"/>
        <circle cx="1480" cy="410" r="2"/>
      </g>
    </svg>
  </div>
`;

export function mountChrome(active) {
  if (!document.querySelector(".atmosphere")) {
    document.body.insertAdjacentHTML("afterbegin", ATMOSPHERE);
  }
  const headerHost = document.querySelector("[data-header]");
  const footerHost = document.querySelector("[data-footer]");
  if (headerHost) headerHost.innerHTML = headerHTML(active);
  if (footerHost) footerHost.innerHTML = footerHTML();

  const toggle = document.querySelector(".nav-toggle");
  const panel = document.getElementById("mobile-nav");
  if (toggle && panel) {
    toggle.addEventListener("click", () => {
      const open = toggle.getAttribute("aria-expanded") === "true";
      toggle.setAttribute("aria-expanded", String(!open));
      toggle.setAttribute("aria-label", open ? "Open menu" : "Close menu");
      panel.hidden = open;
    });
  }
}
