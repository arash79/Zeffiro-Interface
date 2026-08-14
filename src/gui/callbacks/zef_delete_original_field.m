%ZEF_DELETE_ORIGINAL_FIELD  Clear cached original lead-field / source arrays.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from current menus (Mesh-tool wiring to this name is commented
%   out). Real callers: zef_init at startup, and every lead-field builder
%   in src/forward/lead_field (EEG/MEG/EIT/tES/gravity) plus
%   tools/plugins/LFBankTool zef_combine_lead_fields.
%
%   Script (not a function). Sets these zef fields to []:
%     source_positions_original_field
%     source_directions_original_field
%     L_original_field
%     L_source_interpolation_ind_original_field
%
%   See also zef_delete_original_surface_meshes, zef_init.

zef.source_positions_original_field =[];
zef.source_directions_original_field = [];
zef.L_original_field = [];
zef.L_source_interpolation_ind_original_field = [];
