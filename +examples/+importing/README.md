# +examples/+importing

## Folder purpose

Minimal example: import a multicompartment segmentation manifest into a **new** nodisplay project (no mesh/LF).

## Main contents

| File | Role |
|------|------|
| `zef_import_example.m` | `examples.importing.zef_import_example` — nodisplay import |

## Code functionality

Calls `zeffiro_interface` with `import_to_new_project` pointing at  
`scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef`  
(with fallback toward `data/segmentations/...` when documented in the script). Stops after import — user must mesh/forward separately.

## Workflow context

First step before `examples.meshing` / `examples.forward`. Data also mirrored under `data/segmentations/multicompartment_head_project/`.

## Usage instructions

```matlab
examples.importing.zef_import_example();
```

## Important notes

- No display session; no automatic Create FEM mesh.
- Paths inside the script may need adjustment if `scripts/scripts_for_importing` is absent.

## Developer guidance

- Keep the example short; point to `data/segmentations/README.md` for ASC inventory.
- Pitfall: expecting `zef.L` after import alone.
