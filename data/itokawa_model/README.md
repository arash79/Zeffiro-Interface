# `data/itokawa_model`

STL surfaces for asteroid 25143 Itokawa, used by `asteroid_gravity_project.mat` and `asteroid_radar_project.mat`.

| File | Layer |
|------|--------|
| `itokawa_exterior.stl` | Outer shape (working resolution) |
| `itokawa_exterior_highres.stl` | Denser outer shape |
| `mantle.stl` | Interior mantle shell |
| `void.stl` | Ellipsoidal void |
| `README.txt` | Same three-layer description |

Import as compartment surfaces (segmentation **Import surface mesh**), not at startup. Manifold check: `python3 scripts/validate_stl_manifold.py path/to/mesh.stl`.
