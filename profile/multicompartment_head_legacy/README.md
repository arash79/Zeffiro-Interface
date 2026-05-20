# Profile: Multicompartment Head (Legacy)

This profile provides a **fixed, legacy head compartment structure** for Zeffiro Interface. It uses the same EEG/MEG/EIT/tES lead fields as the main multicompartment_head profile but predefines **30 compartments**: skin, skull, CSF, grey matter, white matter, and 22 “detail” compartments (d1–d22). It is intended for compatibility with older projects and workflows that rely on this specific compartment naming and ordering.

## Use Case

- Legacy EEG/MEG/EIT/tES projects that assume the standard 30-compartment layout.
- Reproducibility of older studies using the fixed tag set (sc, sk, c, g, w, d1–d22).
- Predefined conductivity (sigma) and colors for each compartment.

## Files in This Profile

| File | Purpose |
|------|--------|
| **zeffiro_init.ini** | Richer than the main head profile: default plot size; modalities EEG, MEG magnetometer, MEG gradiometers; CEM electrode creation; **compartment structure** (full list of tags); **sensor structure** (`s`); imaging method name and index; sensors on/visible; current sensors, names, and colors. |
| **zeffiro_parameters.ini** | Same as multicompartment_head: sigma, rho, epsilon, mu, filtered_tetra, electrode impedance/radii, kappa, condition number. |
| **zeffiro_forward_simulation.ini** | Same as multicompartment_head: EEG, MEG (magnetometers, gradiometers), EIT, tES; isotropic and anisotropic. |
| **zeffiro_plugins.ini** | Same as multicompartment_head except: no DTI conductivity tool, no synthetic extended source patch; includes Kalman and NSE tool. Slight naming (e.g. “Github” vs “GitHub”) and “ReconstructionTool”/“LeadFieldProcessingTool” style. |
| **zeffiro_segmentation.ini** | **Full 30-compartment definition:** tags `sc, sk, c, g, w, d1–d22`; names (Skin, Skull, Cerebrospinal fluid, Grey matter, White matter, Detail 1–22); RGB colors; activity (sources) per compartment; **Parameter setting** row for **sigma** with default conductivities (e.g. skin 0.43 S/m, skull 0.0064 S/m, CSF 1.79 S/m, grey 0.33 S/m, white 0.14 S/m, details 0.33 S/m). |

## Compartment Layout (Order)

1. **sc** — Skin  
2. **sk** — Skull  
3. **c** — Cerebrospinal fluid  
4. **g** — Grey matter  
5. **w** — White matter  
6. **d1–d22** — Detail 1 through Detail 22  

Parameter setting (sigma) and activity are aligned with this order. Changing the number or order of compartments in this file would break compatibility with legacy projects that expect this exact layout.

For the overall profile system and INI format, see the parent [../README.md](../README.md).
