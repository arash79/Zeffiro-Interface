# Constants (`src/constants`)

Reserved for named numerical constants (FEM stencils, default tolerances) that should not live as magic numbers in mesh/forward code.

**There are no `.m` files here.** User-overridable defaults are in:

- `profile/zeffiro_interface.ini`
- `profile/<profile>/zeffiro_parameters.ini`
- `src/core/zef_init.m`

`zef_start_config.m` (generated warning/path toggles) is in `src/core`, not here.

When extracting a non-user constant from `zef_create_fem_mesh` or a barycentric operator, add a named function or script in this folder and document units in this README.
