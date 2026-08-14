# `multicompartment_head_nse`

Head profile with extra **Navier–Stokes / microvessel** parameter rows. Plugin list matches `multicompartment_head_legacy` (including EXP IAS RAMUS). Segmentation INI is an empty template like the default head — import anatomy separately.

Switch: segmentation tool **Profile:** dropdown, then apply INIs. Parent: [`profile/README.md`](../README.md). NSE solvers: `src/forward/nse`.

## Extra parameter rows

`zeffiro_parameters.ini` adds (On) relative to the default head:

- `mvd_length` — microvessel density, default 200 Count/mm³
- `nse_sigma` — NSE conductivity field, default 0 S/m (On, not written from segmentation)

`sigma` stays On. Forward-simulation INI is the same EEG/MEG/EIT/tES table as the other head profiles (NSE itself is started from the NSE tool, not from those rows).
