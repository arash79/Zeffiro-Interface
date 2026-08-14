# Import example (`examples.importing`)

Starts a **nodisplay** session and loads a bundled segmentation manifest. It does **not** mesh, assemble a lead field, or open the GUI. Use it to check that anatomy import works, or as the first step of a scripted pipeline (mesh and `zef_lead_field_matrix` come after).

```matlab
addpath(fileparts(which('zeffiro_interface')));
zef = examples.importing.zef_import_example();
```

That function calls:

```matlab
zeffiro_interface('start_mode','nodisplay', ...
    'import_to_existing_project', ...
    'scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef');
```

That path is **not** `data/segmentations/...`. `import_to_existing_project` runs `zef_import_segmentation` on the current (empty) session — same as **Import → Import data to project**, without the “new project” reset.

If `scripts/scripts_for_importing/` is absent in your clone, pass the data copy:

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_existing_project', ...
    fullfile('data', 'segmentations', 'multicompartment_head_project', 'import_segmentation.zef'));
```

`.zef` row types (`box`, `segmentation`, `sensors`, `struct`, `script`): [`src/io/README.md`](../../src/io/README.md). Meshing after import: [`../+meshing/README.md`](../+meshing/README.md).
