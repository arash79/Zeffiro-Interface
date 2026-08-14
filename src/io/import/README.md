# Brainstorm geometry adapters (`src/io/import`)

These three functions turn a **live Brainstorm MATLAB session** (subject surfaces, channel file, scouts) into millimetre arrays Zeffiro already understands. They are **not** on the Zeffiro menu bar and they do **not** open a `.zef` project by themselves.

The full converter a user actually runs is `utilities.brainstorm2zef.run` (`+utilities/+brainstorm2zef`). That pipeline calls these adapters after Brainstorm has a subject loaded, then writes a Zeffiro project / import script. If you only need one surface or one channel set while debugging, you can call the adapters directly from MATLAB **while Brainstorm is on the path**.

Project **Import → Import data to a new project** (`.zef` folders) is `src/io/zef_import_segmentation`, not this folder. Electrode CSV/DAT is `+core/+io/+electrodes`.

## Where this sits

```
Brainstorm subject (bst_get, Channel MAT, Surface MAT)
        │
        ▼
zef_bst_2_zef_surface / _sensors / _atlas     this folder
        │
        ▼
utilities.brainstorm2zef  (compartments, .zef, project .mat)
        │
        ▼
Zeffiro session: <tag>_points/_triangles, zef.sensors, parcellation_*
```

Coordinates: Brainstorm stores metres; these adapters multiply by **1000** so Zeffiro sees millimetres, matching typical segmentation surfaces.

## Functions

| File | Returns | Needs |
|------|---------|--------|
| `zef_bst_2_zef_surface` | `vertices`, `faces` (mm), optional surface metadata | Brainstorm `bst_get`; subject index; optional surface index and property names |
| `zef_bst_2_zef_sensors` | positions (mm), orientations, group index, Type tags | current or given study Channel MAT; optional Type filter (`'EEG'`, …) |
| `zef_bst_2_zef_atlas` | parcellation colortable cell + `p_points` (scout vertices, column 4 = scout index) | subject, surface index, atlas Name; `atlas_compartment > 0` enables export |

Without a surface index, `zef_bst_2_zef_surface` returns only the Surface struct array so you can browse names before loading a mesh.

## Scripting

```matlab
% Brainstorm already started and a subject selected:
[v, f] = zef_bst_2_zef_surface(iSubject, iSurf);
[pos, ori, ind, tags] = zef_bst_2_zef_sensors('EEG');
[ctable, pts] = zef_bst_2_zef_atlas(iSubject, iSurf, [], iCompartment, 'Desikan-Killiany');
```

For a complete import including FEM defaults, use `utilities.brainstorm2zef.run` and that package’s settings files instead of assembling `zef` by hand.

Parent I/O menus: [`../README.md`](../README.md). Converter options: [`../../../+utilities/+brainstorm2zef/README.md`](../../../+utilities/+brainstorm2zef/README.md).
