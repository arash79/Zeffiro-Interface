# `+scripts` — `makeParcellation.sh`

This is the only file in the folder. `utilities.fs2zef.run` does not extract surfaces in MATLAB; it shells out to FreeSurfer:

```text
bash -lc "source $FREESURFER_HOME/SetUpFreeSurfer.sh && bash makeParcellation.sh <subject_id> <mgz_file> <output_dir>"
```

For each label in the volume (`mri_segstats` + LUT): `mri_mc` writes a marching-cubes surface as ASCII under `output_dir/ascii/` and/or STL under `output_dir/mesh/`. Optional `--lut PATH`. Requires `SUBJECTS_DIR` and `FREESURFER_HOME` in the **shell** environment (MATLAB `run` sources FreeSurfer first via `+environment`).

After the script returns, `+generators` writes `import_segmentation.zef` from those files. Parent: [`../README.md`](../README.md).
