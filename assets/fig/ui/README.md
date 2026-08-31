# assets/fig/ui

## Folder purpose

Runtime **line-icon PNGs** for the unified GUI shell and themed toolbars. Loaded by `zef_ui_icons` (composites PNG alpha onto theme background and tints ink with theme foreground so the same assets work in light and dark themes).

## Main contents

| Item | Role |
|------|------|
| `*.png` | Runtime icons: `project`, `import`, `export`, `edit`, `forward`, `inverse`, `multi`, `settings`, `sensors`, `profile`, `help`, `colormap`, `edges`, `sliders`, `pan`, `rotate`, `zoom`, `reset`, `screenshot`, `annotate`, `mark`, `measure`, `gizmo`, `cube`, `window`, `bell`, `ellipsis`, `sun`, `moon`, … |
| `Zeffiro_Modern_Icons/` | SVG masters + notes (not loaded at runtime) |

Exact set grows with the shell; unresolved names make `zef_ui_icons` return empty CData.

## Code functionality

No executable code. Consumers:

```matlab
cdata = zef_ui_icons('forward', 20);           % themed CData
folder = zef_ui_icons('folder');               % absolute ui/ path
```

`zeffiro_interface` adds `genpath(assets/fig)` so files resolve by name via `which`/`imread`.

## Workflow context

```
zef_ui_theme → zef_ui_icons → zef_ui_shell / toolbars / secondary windows
```

Brand logos remain in parent `assets/fig/` (`zeffiro_small_logo.png`, compass marks). Plugin-specific art stays under `plugins`.

## Usage instructions

Prefer `zef_ui_icons(name)` over hard-coded paths. When authoring UI, use stable lowercase names matching the PNG stems.

## Important notes

- **Filenames are an API** — renaming breaks toolbars until call sites update.
- Do not load SVGs at runtime; rasterize to PNG here first.
- Keep icon ink on transparent backgrounds for correct tinting.

## Developer guidance

- Add a PNG here and an SVG under `Zeffiro_Modern_Icons/svg_masters/` together.
- Document new names in the shell/nav wiring that references them.
- Pitfall: embedding absolute filesystem paths in `.mlapp` instead of `zef_ui_icons`.
