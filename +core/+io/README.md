# `core.io` — parsers that do not need a `zef` session

Package functions that turn files into MATLAB arrays. They take a path (and optional name-value arguments) and return numeric data. They do **not** read or write the session struct `zef`.

Today the only child is **`+electrodes/`**: `from_csv` and `from_dat`. Those are the parsers behind **Import → Import electrodes**. The GUI callback that *does* write `zef.sensors` is `core.gui.menu_tool.import_electrodes_callback`.

```matlab
[pos, names] = core.io.electrodes.from_csv("electrodes.csv");
[pos, names] = core.io.electrodes.from_dat("electrodes.dat");
```

Formats, CEM columns (inner/outer radius, impedance), and DAT vs CSV differences: [+electrodes/README.md](+electrodes/README.md).

This package is not a general I/O layer. Project `.mat` save/load, STL import, and `.zef` scripts live under `src/io`. FreeSurfer / SimNIBS converters live under `+utilities`.
