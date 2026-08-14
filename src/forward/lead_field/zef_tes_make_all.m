%ZEF_TES_MAKE_ALL  One-shot script: Create FEM mesh, TES type 5 lead field, interpolate.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Same mesh+LF sequence as zef_eeg_make_all with lead_field_type=5
%   and zef_tes_lead_field. Not bound to a Mesh-tool button.
%
%   See also zef_tes_lead_field, zef_create_finite_element_mesh.

warning('off');
zef.lead_field_type = 5;
zef.source_interpolation_on = 1;
set(zef.h_source_interpolation_on,'value',1);
zef_create_finite_element_mesh;
zef_postprocess_finite_element_mesh;
zef.n_sources_mod = 1;
zef.source_ind = [];
zef_update_fig_details;
zef_tes_lead_field;
zef_source_interpolation;
