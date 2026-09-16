# Tests (`+tests`)

MATLAB tests for inverse dispatch, UI chrome, and related APIs. Nested packages `tests.unit`, `tests.integration`, `tests.smoke`, plus fixtures in `tests.support`.

Do **not** `addpath('+tests')`. After `zeffiro_interface` path setup (or adding only the project root):

| Package | Role |
|---------|------|
| `tests.unit` | Solver kernels, types, theme/waitbar widgets |
| `tests.integration` | Dispatch, cluster, class vs legacy |
| `tests.smoke` | End-to-end synthetic, windows, architecture layout |
| `tests.support` | Synthetic `zef` fixtures (`createSyntheticInverseZef`) |

Child READMEs: [`+unit`](+unit/README.md), [`+integration`](+integration/README.md), [`+smoke`](+smoke/README.md), [`+support`](+support/README.md).

## Main contents

Fully qualified names are `tests.unit.ELORETAInverterTest`, `tests.integration.ELORETADispatchTest`, `tests.smoke.ArchitectureLayoutTest`, etc. The complete catalogs are the child READMEs:

| Package README | Catalog |
|----------------|---------|
| [`+unit/README.md`](+unit/README.md) | Kernel, mesh/FEM, types, chrome |
| [`+integration/README.md`](+integration/README.md) | Dispatch, cluster, class vs legacy |
| [`+smoke/README.md`](+smoke/README.md) | End-to-end, windows, architecture layout |
| [`+support/README.md`](+support/README.md) | Synthetic `zef` fixtures |

Do not copy those tables here; they drift. Fixtures: `tests.support.createSyntheticInverseZef`, `createSyntheticUKFNMMZef`, `createSyntheticMeshZef`.

## Code functionality

Tests construct synthetic `L` / measurements via helpers, call `utilities.cluster.dispatch_inverse` or `zef_inverse_run`, and assert shapes / nonempty reconstructions / error ids. Cluster profile tests skip cleanly when Parallel Computing Toolbox / CSC `parcluster` is absent.

## Workflow context

Protects the class inverse track (`src/inverse` + `+inverse` + `+utilities/+cluster`) and selected GUI chrome (`src/gui/chrome`).

## Usage instructions

```matlab
cd /path/to/zeffiro_interface
zef = zeffiro_interface('start_mode','nodisplay');  % path warmup
import matlab.unittest.TestSuite
suite = TestSuite.fromPackage('tests', 'IncludingSubpackages', true);
run(suite)
% or a nested package / class:
runtests('tests.unit')
runtests('tests.unit.ELORETAInverterTest')
runtests('tests.smoke.ArchitectureLayoutTest')
```

`runtests('+tests')` does **not** pick up nested `+unit` / `+integration` / `+smoke` classes.

## Important notes

- Synthetic `L` only — not a substitute for real head-project validation.
- `ClassVsLegacyTest` checks both paths run, not bit-exact parity.
- ClusterProfileTest / ParameterSweepGenerationTest skip when `parcluster` is missing, then again without CSC `ComputingProject`.

## Developer guidance

- New registry method → add a dispatch/smoke test here.
- Prefer `tests.support.createSyntheticInverseZef` over ad-hoc fixtures.
- Pitfall: `addpath('+tests')` breaks package resolution — add the **project root** only.
