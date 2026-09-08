import { GITHUB } from "./config.js";
import { mountChrome } from "./layout.js";
import { initHero } from "./hero.js";
import { initHome } from "./home.js";
import { initPapers } from "./papers-page.js";
import { initScenes } from "./scenes.js";
import { initDocs } from "./docs-page.js";
import { initFeatures } from "./features-page.js";

const page = document.body.dataset.page || "overview";
mountChrome(page);

if (page === "overview") {
  initHero();
  initHome();
  initScenes();
}

if (page === "papers") {
  initPapers();
}

if (page === "docs") {
  initDocs();
}

if (page === "features") {
  initFeatures();
}

document.querySelectorAll("[data-github]").forEach((el) => {
  el.setAttribute("href", GITHUB);
});
