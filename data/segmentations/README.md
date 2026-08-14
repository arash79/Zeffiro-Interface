# `data/segmentations`

These folders are **import assets**: closed tissue surfaces plus an `import_segmentation.zef` manifest. Zeffiro does not load them at startup. You import them (GUI or CLI), then mesh and compute a lead field as usual.

The only bundled tree is `multicompartment_head_project/`: FreeSurfer-style `.asc` surfaces (scalp, skull, CSF, brain, …), sample `electrodes.dat`, parcellation colortables, and the `.zef` that names those files. That subfolder’s README lists each surface and the offline regenerators (`create_colortable.m`, `fs2zef.sh`).

## How to import

**GUI:** **Import → Import data to a new project** (label assigned in `zef_menu_tool.m`), pick `import_segmentation.zef`. That resets the session (`zef_start_new_project` with `new_empty_project=1`), runs `zef_import_segmentation`, then `zef_build_compartment_table`.

**MATLAB:**

```matlab
zef = zeffiro_interface('import_to_new_project', ...
    fullfile(projectRoot,'data','segmentations','multicompartment_head_project','import_segmentation.zef'));
```

Coordinates are millimetres. The importer (`src/io/zef_import_segmentation`) resolves `filename` / `foldername` relative to the folder that contains the `.zef`. After import, Mesh tool **Create FEM mesh**.

To *produce* a new `.zef` from FreeSurfer, use `utilities.fs2zef.run` (writes `ascii/import_segmentation.zef` and/or `mesh/`). Do not confuse that with the tetrahedral importer `zef_import` under **Import → Import volume data**.

Parent data root: [`data/README.md`](../README.md). Manifest `type=` rows: [`src/io/README.md`](../../src/io/README.md).
