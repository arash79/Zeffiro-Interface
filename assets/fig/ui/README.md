# assets/fig/ui

## Folder purpose

Runtime **SVG line icons** for the unified GUI shell and themed toolbars. Loaded by `zef_ui_icons`, which rasterizes each file, maps dark ink to the theme foreground, keeps chromatic SVG paint, and composites onto the theme background.

## Main contents

| Item | Role |
|------|------|
| `*.svg` | Runtime icons: `project`, `import`, `export`, `edit`, `forward`, `inverse`, `multi`, `settings`, `sensors`, `profile`, `help`, `colormap`, `edges`, `sliders`, `pan`, `rotate`, `zoom`, `zoomout`, `reset`, `screenshot`, `annotate`, `mark`, `measure`, `gizmo`, `cube`, `window`, `bell`, `ellipsis`, … |

Exact set grows with the shell; unresolved names make `zef_ui_icons` return empty CData.

## Code functionality

No executable code. Consumers:

```matlab
cdata = zef_ui_icons('forward', 20);           % themed CData
folder = zef_ui_icons('folder');               % absolute ui/ path
```

`zeffiro_interface` adds `genpath(assets/fig)` so files resolve by name via `which`.

## Workflow context

```
zef_ui_theme → zef_ui_icons → zef_ui_shell / toolbars / secondary windows
```

Brand logos remain in parent `assets/fig/` (`zeffiro_small_logo.png`, compass marks). Plugin-specific art stays under `plugins`.

## Usage instructions

Prefer `zef_ui_icons(name)` over hard-coded paths. When authoring UI, use stable lowercase names matching the SVG stems.

## Important notes

- **Filenames are an API** — renaming breaks toolbars until call sites update.
- Keep square `viewBox` icons (current family is `0 0 128 128`) with transparent backgrounds.
- Pale surface fills (`url(#g2)`, white) are not treated as ink, so interior strokes stay visible after theming.

## Developer guidance

- Add an SVG here and call `zef_ui_icons` with the stem name.
- Document new names in the shell/nav wiring that references them.
- Pitfall: embedding absolute filesystem paths in `.mlapp` instead of `zef_ui_icons`.
