# Zeffiro Interface

Zeffiro is MATLAB software for building a finite-element model of the head (or another piecewise-constant volume) and for solving the associated electromagnetic **forward** and **inverse** problems.

In plain language: you import tissue surfaces, fill them with tetrahedra, compute how candidate sources would look at the sensors, then reconstruct activity from measurements. The same machinery also covers electrical impedance tomography (EIT), transcranial electrical stimulation (TES / tES), and a few specialized pipelines (gravity, radar/wave, hemodynamics).

The project is aimed at researchers, students, and developers who need a scriptable FEM pipeline with a working GUI. You do not need to already know EEG source localization to start, but you will meet that vocabulary quickly; [docs/glossary.md](docs/glossary.md) introduces it.

Session state is a single MATLAB struct named `zef`, usually in the base workspace. Almost every window and script reads and writes fields of that struct.

## What a typical session looks like

```text
import tissue surfaces
        ↓
create a labeled tetrahedral mesh
        ↓
attach sensors
        ↓
assemble a lead field  (zef.L)
        ↓
import or synthesize measurements
        ↓
run an inverse method  (zef.reconstruction)
        ↓
visualize / export
```

1. Import anatomy (a `.zef` segmentation, or **Import** in the GUI).
2. Import electrodes or another sensor set.
3. Mesh tool → **Create FEM mesh**.
4. Mesh tool forward-simulation table → **Run script** (or `zef_lead_field_matrix` / `zef_eeg_make_all`) so `zef.L` exists.
5. Invert: either an **Inverse tools** plugin, or the programmable path `zef_inverse_run`.
6. Draw the result in the Figure / mesh-visualization tools.

Those two inverse paths are **not** the same code. Inverse-tools items without **(class solver)** in the label still call legacy functions under `plugins/`. Entries labelled **(class solver)** open a dialog whose Start button calls `zef_inverse_run` and constructs `inverse.*Inverter`. Scripts and cluster jobs use that class path directly. See [docs/architecture.md](docs/architecture.md) and [ADR-002](docs/adr/ADR-002-dual-inverse-tracks.md).

## Major pieces of the repository

| Path | What lives there |
|------|------------------|
| `zeffiro_interface.m` | Launch and CLI name-value arguments |
| `zeffiro_setup.m` | Optional git submodules; writes `src/app/zef_start_config.m` |
| `src/` | Procedural `zef_*` runtime: session, GUI, mesh, forward, I/O |
| `+core/`, `+inverse/`, `+utilities/` | Packages `core.*`, `inverse.*`, `utilities.*` |
| `plugins/` | GUI Inverse / Forward / Multi tools (INI-discovered) |
| `profile/` | INI files for menus and default parameters |
| `data/` | Example segmentations, electrode caps, optional projects |
| `+examples/`, `+tests/` | Worked scripts and MATLAB unit tests |
| `docs/` | Architecture, getting started, conventions, methods |
| `documentation/` | Typeset scientific manual (LuaLaTeX) |
| `external/` | Optional third-party git submodules |
| `assets/` | GUI icons and figures |
| `website/` | Optional static project homepage (not on the MATLAB path) |
| `scripts/` | Maintainer tools (tests, STL QA; not on the MATLAB path) |

`src/app` (start, update, close) is not the `+core` package. Do not `addpath` a `+package` folder yourself; add the **project root** so MATLAB can resolve `core.*` / `inverse.*` / `utilities.*`.

## Requirements

- MATLAB **R2023a** or newer. `arguments` blocks and App Designer `uifigure` only need R2021a, but the inverse precompute paths call `pageeig` (R2023a) and `pagesvd` (R2021b), so R2023a is the real floor. MATLAB R2025a defaults new figures to docked windows; Zeffiro forces standalone windows through `zef_window_manager`.
- Optional: Parallel Computing Toolbox, a CUDA GPU (`zef.use_gpu`), Statistics Toolbox (GMM / UKFNMM k-means), Optimization / CVX (tES workbench).
- Git, if you want optional toolboxes under `external/` (`zeffiro_setup`).

## Install and start

Clone the repository, `cd` into it, and from MATLAB:

```matlab
zef = zeffiro_interface;
```

That adds `src/`, `plugins/`, `profile/`, and `assets/` to the path, runs `zeffiro_setup` unless you skip it, opens the core tools, and loads `data/default_project.mat` **if that file exists**. Fresh clones often do not ship it; that is expected.

Headless / batch:

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', fullfile(pwd, 'data', 'segmentations', ...
    'multicompartment_head_project', 'import_segmentation.zef'));
```

`start_mode` is `"display"`, `"nodisplay"`, or `"default"`. Hidden figures may still be created in nodisplay mode. If `zef` already exists in the base workspace, close it with `zef_close_all` or pass `'zeffiro_restart', true`.

`help zeffiro_interface` lists every name-value argument.

A slower but more complete first walk-through is [docs/getting-started.md](docs/getting-started.md). Scripted mesh and lead-field demos live in [`+examples/`](+examples/README.md).

To clone from MATLAB into a new folder (shallow clone, then optional `zeffiro_setup`):

```matlab
zeffiro_downloader('install_directory', pwd, 'run_setup', true)
```

That helper is for a **fresh** install, not for updating an existing working tree. `help zeffiro_downloader` lists the name-value arguments (`branch_name`, `profile_name`, `submodules`, …). The default branch is `master` (the official GitHub default). Pass `'branch_name', 'main_development_branch'` to clone the live upstream development line. Git arguments are shell-quoted; `git_address` must be an `https`/`git@`/`ssh`/`file` URL.

## Documentation map

Start at the layer that matches the question:

| Question | Document |
|----------|----------|
| How do I run it once? | [docs/getting-started.md](docs/getting-started.md) |
| What does this word / field mean? | [docs/glossary.md](docs/glossary.md), [docs/zef-state.md](docs/zef-state.md) |
| mm vs m, `L` orientation, indexing | [docs/conventions.md](docs/conventions.md) |
| Where does the code live? | [docs/architecture.md](docs/architecture.md) |
| Why is the inverse ill-posed? Which solver? | [docs/methods.md](docs/methods.md) |
| Something failed | [docs/troubleshooting.md](docs/troubleshooting.md) |
| Where do I put a new solver / plugin? | [docs/developer-guide.md](docs/developer-guide.md) |
| Why two inverse tracks? | [docs/adr/](docs/adr/) |
| Numbers vs upstream Zeffiro | [docs/upstream.md](docs/upstream.md) |
| Equations in print form | [`documentation/`](documentation/README.md) |
| How to contribute | [CONTRIBUTING.md](CONTRIBUTING.md) |

Folder-level `README.md` files under `src/`, `+inverse`, `plugins/`, and so on describe that directory’s implementation. MATLAB `help` on a function is the comment block immediately after `function` / `classdef`.

## Tests

From the project root, after `zeffiro_interface` has put packages on the path:

```matlab
import matlab.unittest.TestSuite
run(TestSuite.fromPackage('tests', 'IncludingSubpackages', true))
```

`runtests('+tests')` does **not** discover the nested `tests.unit` / `tests.integration` / `tests.smoke` packages. Details: [`+tests/README.md`](+tests/README.md).

This tree does not ship GitHub Actions or other hosted CI. Run the suite locally after path setup.

## Cite, license, issues

Method-specific papers (eLORETA, RAMUS, Kalman, HALpR, …) are listed in [CITATION.md](CITATION.md). This repository does not currently ship a single official `CITATION.cff` for the software as a whole.

Zeffiro is licensed under the [GNU GPL v3](LICENSE). Bundled fonts, optional submodules, and other third-party notices: [THIRD_PARTY.md](THIRD_PARTY.md).

Upstream project: [github.com/sampsapursiainen/zeffiro_interface](https://github.com/sampsapursiainen/zeffiro_interface). Report issues there (or on the fork you are working from).

Default GUI profile is `multicompartment_head` (`profile/zeffiro_interface.ini`).
