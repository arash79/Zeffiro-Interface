%ZEF_EEG_MAKE_ALL  One-shot script: Create FEM mesh, EEG type 1 lead field, interpolate.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (base-workspace zef). Not a Mesh-tool button — the make_all
%   callback in zef_mesh_tool is commented out. Default INI Script cells call
%   zef_eeg_lead_field_isotropic instead, which assumes the mesh already exists.
%
%   Steps: lead_field_type=1; force source_interpolation_on and the Mesh-tool
%   checkbox; zef_create_finite_element_mesh; zef_postprocess_finite_element_mesh;
%   clear source_ind; zef_eeg_lead_field; zef_source_interpolation.
%
%   See also zef_create_finite_element_mesh, zef_eeg_lead_field, zef_run_forward_simulation.

warning('off');
zef.lead_field_type = 1;
zef.source_interpolation_on = 1;
set(zef.h_source_interpolation_on,'value',1);
zef_create_finite_element_mesh;
zef_postprocess_finite_element_mesh;
zef.n_sources_mod = 1;
zef.source_ind = [];
zef_update_fig_details;
zef_eeg_lead_field;
zef_source_interpolation;
