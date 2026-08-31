# assets/fig/tools

## Folder purpose

Holds the remaining GUIDE `.fig` for **Find synthetic EIT data**. Core tools use App Designer exports in `src/gui/apps/` and the programmatic Figure tool (`zef_figure_tool`).

## Main contents

| File | Tool |
|------|------|
| `zef_find_synthetic_eit_data.fig` | Find / generate synthetic EIT data (`zef_find_synthetic_eit_data`) |

## Code functionality

Binary GUIDE layout only. Opened by `zef_find_synthetic_eit_data`; callbacks resolve to `zef_*` scripts under `src/gui`.

## Workflow context

```
Forward tools → Generate synthetic EIT data
  → zef_find_synthetic_eit_data → this .fig
```

Plugin UIs stay under `plugins/*/fig` and `*/mlapp`.

## Usage instructions

Use the Forward-tools menu entry (or the documented `zef_find_synthetic_eit_data` callback). Do not hand-edit the `.fig` unless maintaining GUIDE mode.

## Important notes

- Filename is part of the compatibility contract.
- Most historical GUIDE tool figs have been retired in favor of App Designer.

## Developer guidance

- Do not add new GUIDE figs for core tools — use `src/gui/apps/` or programmatic layout helpers (`zef_layout_*`, `zef_figure_tool_layout`).
- Pitfall: updating only an `.mlapp` and assuming GUIDE users of this EIT fig see the change.
