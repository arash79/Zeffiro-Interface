# assets/fig/ui/Zeffiro_Modern_Icons/svg_masters

## Folder purpose

**SVG masters** for Zeffiro’s shared line-icon set. Regenerated PNGs are written to `assets/fig/ui/*.png` for `zef_ui_icons`. Not on the product runtime path for UI drawing.

## Main contents

SVG files named after icon stems, for example: `annotate`, `bell`, `colormap`, `cube`, `edges`, `edit`, `ellipsis`, `export`, `forward`, `gizmo`, `help`, `import`, `inverse`, `mark`, `measure`, `moon`, `multi`, `pan`, `profile`, `project`, `reset`, `rotate`, `screenshot`, `sensors`, `settings`, `sliders`, `sun`, `window`, `zoom`.

## Code functionality

Vector assets only. No MATLAB functions.

## Workflow context

Parent: `Zeffiro_Modern_Icons/`. Consumer of rasters: `src/gui/chrome/zef_ui_icons.m`.

## Usage instructions

Open in a vector editor; export square PNG with transparency to `../../<stem>.png`. Keep viewBox/padding consistent across the family so toolbar sizes look even.

## Important notes

- Stem names must match `zef_ui_icons` lookup keys (lowercase).
- Third-party icon licenses, if any, must remain attributed in commit messages / project NOTICE — do not strip license comments from SVG if present.

## Developer guidance

- Prefer geometric consistency (stroke width, corner radius) across the set.
- Pitfall: committing only SVG without updating the matching PNG (UI will show the old raster).
