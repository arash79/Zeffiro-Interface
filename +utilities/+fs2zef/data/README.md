# `data/` — default electrodes for fs2zef

When `utilities.fs2zef.run` is not given `electrode_file`, it copies `electrodes.dat` from this folder into both `ascii/` and `mesh/` next to `import_segmentation.zef`. That file is then a `type,sensors` row in the manifest.

Format is the same as **Import → Import electrodes** (`core.io.electrodes.from_dat`): whitespace-separated XYZ, optional labels. Coordinates are **not** converted; they must already match the FreeSurfer tkr RAS millimetre frame of the surfaces. If they do not, Zeffiro will still import them and the electrodes will sit in the wrong place relative to the mesh.

`import_segmentation_template.zef` is a static example template. `run` never reads it; it always calls `generate_zef_import`. Parent: [`../README.md`](../README.md).
