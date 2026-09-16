# Architecture decision records

Short records of layout and API choices that the rest of the documentation assumes. These are not a changelog.

| ADR | Decision |
|-----|----------|
| [ADR-001](ADR-001-hybrid-layout.md) | Procedural `src/` + MATLAB packages + INI plugins |
| [ADR-002](ADR-002-dual-inverse-tracks.md) | Legacy Inverse-tools plugins and class `inverse.*Inverter` stay separate |
| [ADR-003](ADR-003-plugins-vs-kernels.md) | Shared GMM / Kalman kernels live in `+inverse`, not only in plugins |
| [ADR-004](ADR-004-utilities-package-name.md) | Public converters and cluster dispatch are `utilities.*` |

Add a new ADR when a lasting layout or public-name choice changes. Folder READMEs and MATLAB `help` remain the day-to-day manuals.
