# Glossary

Terms as this repository uses them. Nearby words in the EEG/MEG literature are noted when they mean the same thing here.

## If you are new to this field

**EEG.** Electroencephalography: voltages measured by electrodes on the scalp (or sometimes on the cortical surface). Each time sample is a vector whose length is the number of electrodes.

**MEG.** Magnetoencephalography: magnetic field measured by coils outside the head. The pipeline is the same idea as EEG — build a lead field, then invert — but the FEM uses Biot–Savart instead of electrode potentials.

**EIT / TES (tES).** Electrical impedance tomography and transcranial electrical stimulation. Same volume conductor, different questions: EIT estimates conductivity changes; TES maps injected current. Zeffiro reuses the mesh and much of the EEG FEM for both.

**Finite-element method (FEM).** Approximate the physics on a mesh of small tetrahedra. Each tetrahedron has a conductivity. Solving a sparse linear system gives the potential (or magnetic field) at the vertices.

**Forward vs inverse.** Forward: given sources, predict sensors (`y ≈ L x`). Inverse: given sensors, estimate sources. The inverse is ill-posed because there are far more candidate sources than sensors.

**Lead field `L`.** The matrix of the forward map. Rows are sensors; columns are source degrees of freedom. Inverse methods consume `L`; they do not assemble it.

The rest of this page is the project’s own vocabulary for anatomy, sensors, solvers, and the GUI.

## Anatomy and mesh

**Compartment.** One closed tissue surface plus flags (on/off, conductivity, whether it may contain sources). Identified by a short tag such as `d1` or `w`. Fields look like `zef.d1_points`, `zef.d1_sigma`.

**Segmentation.** The collection of compartments (scalp, skull, CSF, grey matter, …), usually imported from a `.zef` manifest that lists `.asc` / STL files.

**Surface mesh.** Triangle vertices and faces for one compartment (`_points`, `_triangles`). Not the volume mesh.

**Volume mesh / FEM mesh.** Tetrahedra filling the interior: `zef.nodes`, `zef.tetra`, `zef.domain_labels`. Built by **Create FEM mesh**.

**Domain label.** Integer tissue id on each tetrahedron, used to look up conductivity and “is this brain?”.

**Source tissue / active compartment.** Tetrahedra whose compartment has `_sources` in `{1, 2}` (Constrained field / Unconstrained field). Inverse sources are placed only there (after a depth peel). `_sources == 0` is Inactive. `_sources == 3` is Active surface (on in the mesh, not a source tissue). `_sources == -1` is Bounding box / perfectly matched layer (PML). The Segmentation-tool labels come from `zef.compartment_activity{_sources+2}`.

**PML.** Outer absorbing layer for some wave/NSE setups; lattice from `zef_pml_mesh`.

**Parcellation.** Atlas regions or user spheres painted onto the source space so reconstructions can be summarized per ROI. Not the same as compartments.

## Sensors and forward model

**Sensor set.** One EEG cap, MEG helmet, or EIT array: positions, optional orientations, names. Default tag `s` (`zef.s_points`). `zef.current_sensors` selects the active tag.

**PEM.** Point electrode model: `N×3` positions, coupled to the nearest scalp node.

**CEM.** Complete electrode model: a contact with inner/outer radius and impedance. See [conventions.md](conventions.md) for column order.

**Forward problem.** Given a source (and tissue conductivities), what do the sensors measure?

**Lead field.** The linear map from candidate sources to sensors, stored as `zef.L`. Entry `L(i,j)` is sensor `i`’s reading from unit source component `j`. Inverse methods consume `L`; they do not assemble it.

**DUNEuro project.** A MATLAB dump from the DUNEuro FEM bindings (lead field `eegL`, optional transfer matrix `eegT`, electrodes, optional mesh). Open project converts it with `utilities.duneuro2zef`. `eegT` is a DUNEuro FEM internal and is not loaded into `zef`; inverse code uses `zef.L`.

**Transfer matrix.** Intermediate FEM solve for electrode (or equivalent) nodal potentials from the sparse stiffness system, before interpolation onto sources. EEG and TES call `zef_transfer_matrix`. MEG and EIT run the same PCG inside their FEM files. GPU uses Jacobi; CPU uses SSOR or no-fill incomplete Cholesky.

**Source model.** How a current dipole is discretized inside a tetrahedron: Whitney, H(div), or St. Venant (`core.types.ZefSourceModel`).

**Source interpolation.** Maps lead-field columns onto mesh nodes / surface triangles (`zef.source_interpolation_ind`). Inverse `zef_processLeadfields` requires `{1}` of that cell.

**Stiffness matrix.** Sparse P1 conductivity operator `A` on the volume mesh (`zef_stiffness_matrix`).

## Inverse problem

**Inverse problem.** Given measurements `y` and lead field `L`, find a source vector `x` such that `L x ≈ y`. There are far more candidate sources than sensors, so many `x` fit the data. Regularization (or a Bayesian prior) picks one.

**Reconstruction.** The estimated `x` (or a derived map: amplitude, GoF, …), stored as `zef.reconstruction`.

**Minimum-norm / MNE.** Among sources that fit the data, pick one with small weighted energy. Class: `inverse.MNEInverter`.

**dSPM / sLORETA.** Standardized maps on a minimum-norm backbone (noise-normalized or resolution-kernel normalized). Class: `inverse.CSMInverter`.

**eLORETA.** Iteratively reweighted minimum-norm aimed at zero localization error for single dipoles under its model. Class: `inverse.ELORETAInverter`.

**IAS.** Iterative alternating sequential MAP with hierarchical (gamma / inverse-gamma) hyperpriors. Class: `inverse.IASInverter`.

**RAMUS.** IAS averaged over random sparse source subsets at several resolutions. Class: `inverse.RAMUSInverter`.

**Kalman filter (here).** Time-recursive estimate of `x_t` with process noise `Q`. GUI plugin `zef_KF` and class `inverse.KalmanInverter` are **different implementations**. DTI-informed `Q` exists only on the plugin.

**UKFNMM.** Spatial Kalman on a modified lead field, then Jansen–Rit neural mass model with unscented Kalman parameter estimation. Class `inverse.UKFNMMInverter`. Inverse tools → **UKF-NMM (class solver)** is listed on every shipped profile, including the asteroid ones.

**GMM (here).** Gaussian-mixture clustering of an **already computed** reconstruction. Package `inverse.gmm`, not a registry inverse id.

**Regularization parameter.** A scalar (often `α` or a noise variance derived from SNR) that trades data fit against the prior. Larger noise / smaller SNR → smoother maps.

**SNR.** Signal-to-noise ratio in decibels, used to set noise covariance or hyperpriors when the user does not supply a matrix.

## Session and GUI

**`zef`.** The project struct. Paths, mesh, sensors, `L`, measurements, reconstructions, and GUI handles (`zef.h_*`).

**Profile.** A folder under `profile/` with INI files for menus, parameters, and forward-script tables. Not a MATLAB Parallel Computing Toolbox cluster profile.

**Plugin.** A GUI tool under `plugins/`, listed in `zeffiro_plugins.ini`. Ordinary functions on `genpath(plugins)`, not a MATLAB `+package`.

**Class inverter / registry id.** Programmable solver: `zef_inverse_run(zef, 'eloreta')` looks up `'eloreta'` in `utilities.cluster.inverse_method_registry` and constructs `inverse.ELORETAInverter`.

**Bundle.** Serializable struct (`L`, frames `F`, `procFile`, method id, …) extracted by `zef_inverse_extract_bundle` for local dispatch or cluster jobs. Schema: [`+utilities/+cluster/SCHEMA.md`](../+utilities/+cluster/SCHEMA.md).

**`zef_update`.** Copies Segmentation-tool tables and related widgets into `zef` fields. Call it after programmatic table edits.

## Related

- Field-level detail: [zef-state.md](zef-state.md)
- Algorithms: [methods.md](methods.md)
- Layout: [architecture.md](architecture.md)
