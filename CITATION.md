# Citing Zeffiro and the methods it implements

This repository does **not** currently include a `CITATION.cff` or a single mandated “cite the software” paper. If you use a specific algorithm, cite the work that the **implementation comments and class headers** point at. Those DOIs are reproduced here so they are findable without opening MATLAB.

Do not invent a primary software citation beyond what the tree records. If the upstream project publishes an official citation later, prefer that.

## Method papers referenced from first-party code

| Method / class | Reference in the tree |
|----------------|------------------------|
| eLORETA (`inverse.ELORETAInverter`) | Pascual-Marqui, arXiv:0710.3341 (2007); Pascual-Marqui, *Phil. Trans. R. Soc. A* 369:3768–3784 (2011) |
| IAS hyperpriors (`inverse.IASInverter`) | Calvetti & Somersalo, [doi:10.1137/080723995](https://doi.org/10.1137/080723995) |
| RAMUS (`inverse.RAMUSInverter`) | Rezaei, Koulouri & Pursiainen, *Brain Topography* 33 (2020), [doi:10.1007/s10548-020-00755-8](https://doi.org/10.1007/s10548-020-00755-8) |
| Standardized Kalman lineage (`KalmanInverter`, UKFNMM comments) | Lahtinen et al., *Clin. Neurophysiol.* 168 (2024), [doi:10.1016/j.clinph.2024.09.021](https://doi.org/10.1016/j.clinph.2024.09.021) |
| HALpR (`inverse.HALpRInverter`) | [doi:10.1016/j.clinph.2023.12.001](https://doi.org/10.1016/j.clinph.2023.12.001) |
| CEM / FEM electrode coupling (comments in `zef_build_electrodes`, EEG FEM) | [Phys. Med. Biol. 57 999](https://iopscience.iop.org/article/10.1088/0031-9155/57/4/999) |
| FreeSurfer DKT parcellation (`utilities.fs2zef` config) | Klein & Tourville, 2012, *Frontiers in Neuroscience* |

UKFNMM (`inverse.UKFNMMInverter`) has **no dedicated DOI** in this repository. The spatial Kalman piece was branched from the standardized-Kalman paper above; the Jansen–Rit + UKF stage is documented in the class README as implementation-defined.

Vendor libraries under `external/` (CVX, FieldTrip, SPM, …) have their own citation requests. SimNIBS helper `meshLoadGmsh4.m` asks authors to cite SimNIBS.

## License

GNU GPL v3 — see [LICENSE](LICENSE). Third-party notices: [THIRD_PARTY.md](THIRD_PARTY.md).

## Software home

<https://github.com/sampsapursiainen/zeffiro_interface>
