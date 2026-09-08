export const GITHUB_BLOB =
  "https://github.com/sampsapursiainen/zeffiro_interface/blob/master/";

export const docsNav = [
  {
    label: "Start",
    items: [
      { slug: "getting-started", title: "Getting started", file: "getting-started.md" },
      { slug: "glossary", title: "Glossary", file: "glossary.md" },
    ],
  },
  {
    label: "Session",
    items: [
      { slug: "conventions", title: "Conventions", file: "conventions.md" },
      { slug: "zef-state", title: "The zef struct", file: "zef-state.md" },
    ],
  },
  {
    label: "Methods",
    items: [{ slug: "methods", title: "Forward and inverse", file: "methods.md" }],
  },
  {
    label: "Help",
    items: [{ slug: "troubleshooting", title: "Troubleshooting", file: "troubleshooting.md" }],
  },
  {
    label: "Reference",
    items: [
      { slug: "architecture", title: "Architecture", file: "architecture.md" },
      { slug: "developer-guide", title: "Developer guide", file: "developer-guide.md" },
      { slug: "upstream", title: "Upstream differences", file: "upstream.md" },
    ],
  },
  {
    label: "Decisions",
    items: [
      { slug: "adr-001", title: "Hybrid layout", file: "adr/ADR-001-hybrid-layout.md" },
      { slug: "adr-002", title: "Dual inverse tracks", file: "adr/ADR-002-dual-inverse-tracks.md" },
      { slug: "adr-003", title: "Plugins vs kernels", file: "adr/ADR-003-plugins-vs-kernels.md" },
      { slug: "adr-004", title: "utilities.* name", file: "adr/ADR-004-utilities-package-name.md" },
    ],
  },
];

export const docsBySlug = Object.fromEntries(
  docsNav.flatMap((group) => group.items.map((item) => [item.slug, item])),
);

export const pathToSlug = {
  "getting-started.md": "getting-started",
  "glossary.md": "glossary",
  "conventions.md": "conventions",
  "zef-state.md": "zef-state",
  "architecture.md": "architecture",
  "methods.md": "methods",
  "troubleshooting.md": "troubleshooting",
  "developer-guide.md": "developer-guide",
  "upstream.md": "upstream",
  "adr/ADR-001-hybrid-layout.md": "adr-001",
  "adr/ADR-002-dual-inverse-tracks.md": "adr-002",
  "adr/ADR-003-plugins-vs-kernels.md": "adr-003",
  "adr/ADR-004-utilities-package-name.md": "adr-004",
  "ADR-001-hybrid-layout.md": "adr-001",
  "ADR-002-dual-inverse-tracks.md": "adr-002",
  "ADR-003-plugins-vs-kernels.md": "adr-003",
  "ADR-004-utilities-package-name.md": "adr-004",
  "adr/README.md": "architecture",
};

export const landing = {
  title: "Documentation",
  lede: "These pages are the repository guides in docs/: how to launch a session, what the zef struct holds, how the lead field is built, and how the two inverse tracks differ. They are not a dump of every folder README.",
  start: [
    {
      slug: "getting-started",
      kicker: "01",
      title: "Getting started",
      text: "Clone, launch, import the bundled head, create a mesh, optionally assemble L.",
    },
    {
      slug: "glossary",
      kicker: "02",
      title: "Glossary",
      text: "Lead field, CEM, reconstruction, compartments, and the rest of the project vocabulary.",
    },
    {
      slug: "methods",
      kicker: "03",
      title: "Forward and inverse",
      text: "y ≈ Lx, why regularization exists, class solvers versus Inverse-tools plugins.",
    },
  ],
  path: [
    { slug: "getting-started", hash: "4-load-the-bundled-head-segmentation", label: "Import" },
    { slug: "getting-started", hash: "5-create-a-tetrahedral-mesh", label: "Mesh" },
    { slug: "getting-started", hash: "6-sensors-and-a-lead-field", label: "Lead field" },
    { slug: "getting-started", hash: "7-a-first-inverse-programmatic", label: "Inverse" },
    { slug: "methods", label: "Methods map" },
  ],
  tasks: [
    { slug: "getting-started", title: "First FEM mesh", hash: "5-create-a-tetrahedral-mesh" },
    { slug: "getting-started", title: "Assemble a lead field", hash: "6-sensors-and-a-lead-field" },
    { slug: "troubleshooting", title: "Empty zef.L" },
    { slug: "conventions", title: "mm vs metres" },
    { slug: "methods", title: "Pick an inverse method" },
    { slug: "adr-002", title: "Class solver vs plugin" },
  ],
};
