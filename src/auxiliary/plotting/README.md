# Reconstruction indexing leftover (`src/auxiliary/plotting`)

The only file here is `zef_get_reconstruction_field.m`. It is an **unfinished extract**, not a supported API.

It reshapes a reconstruction into 3-by-N, then branches on a workspace variable `type` (1–7) using undeclared names (`I_1_rec`, `I_2_rec`, `n_vec_aux`, `zef.inv_scale`, …). `intersect_ind` is unused. Extra `end` statements follow the function. Nothing in `src/gui/plot` calls it.

Do not use this from new scripts. Live volume drawing is `src/gui/plot/zef_plot_volume.m`. Mesh-visualization histograms are `src/visualization/graph_bank`. Parent auxiliary overview: [../README.md](../README.md).
