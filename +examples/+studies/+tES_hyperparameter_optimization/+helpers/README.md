# tES recursive-search helper

`zef_ES_centralize_recursive_search` is the only file here. `zef_ES_recursive_search` calls it each pass to shrink the alpha/epsilon lattice about the current best indices `(sr, sc)` and then `zef_ES_find_parameters` rebuilds the grid.

```matlab
[alpha_psi, epsilon_psi] = helpers.zef_ES_centralize_recursive_search( ...
    alpha, epsilon, sr, sc, original_window, s_alpha, s_epsilon, non_floating_flag)
```

Eighth argument `0`: allow the window to leave the original `[min,max]` range. Default (omitted or `1`) clamps. `s_alpha` / `s_epsilon` are shrinkage factors from the parent search. Not a GUI button. Parent: [../README.md](../README.md).
