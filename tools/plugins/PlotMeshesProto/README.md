# PlotMeshesProto

Prototype of the main 3-D mesh / reconstruction movie plotter. The file `plot_meshes_proto.m` defines **`zef_plot_meshes`** and draws on `zef.h_axes1` from `zef.reuna_p` / `zef.reuna_t`, sensors, and (for visualization types 3–5) `zef.reconstruction` or `zef.top_reconstruction`. `zef_3D_plot_specs` sets camera, ticks, and axis limits.

**Not a menu plugin** (no INI row). The live GUI uses `src/` `zef_plot_meshes`, not this folder, unless you call this file explicitly (MATLAB will bind the **filename** `plot_meshes_proto` unless this copy shadows the real function). Treat it as a reference / experimental duplicate.

## How to open it

Call from MATLAB only. There is no start window and no `ButtonPushedFcn`.

```matlab
plot_meshes_proto;   % filename; draws into zef.h_axes1
zef_3D_plot_specs(zef.h_axes1);
```

Needs processed surfaces (`zef.reuna_*`), `zef.sensors`, and for type 3/5 a reconstruction cell or `zef.top_reconstruction`. Honors clip planes, parcellation, inflated surfaces, movie frames (`zef.frame_start/stop/step`, `zef.stop_movie`).
