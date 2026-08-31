function relative_resolution_vec = zef_find_relative_resolution(zef)
%ZEF_FIND_RELATIVE_RESOLUTION  Per-active-compartment 4^n face-count multiplier.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Caller: zef_downsample_surfaces (Mesh tool
%   **Resample surfaces** / **Create FEM mesh** when Resample surf. is
%   on). Target triangle count is max_surface_face_count times this
%   vector. Each surface split multiplies faces by 4, so n refinement
%   passes contribute 4^n.
%
%   relative_resolution_vec = zef_find_relative_resolution(zef)
%
%   Input
%     zef  - session. Uses zef_get_active_compartments for On tags and
%            source compartments (*_sources in {1,2}).
%
%   Fields read (all no-ops unless zef.refinement_on)
%     refinement_surface_on, refinement_surface_number,
%       refinement_surface_compartments
%     refinement_surface_on_2, refinement_surface_number_2,
%       refinement_surface_compartments_2
%     refinement_volume_on, refinement_volume_number,
%       refinement_volume_compartments
%     refinement_volume_on_2, refinement_volume_number_2,
%       refinement_volume_compartments_2
%     (surface/volume *_3 blocks are not used)
%
%   Output
%     relative_resolution_vec  - 1 × n_active, default ones. Each listed
%       compartment index i is multiplied by 4.^refinement_*_number(i).
%       Index −1 means all source compartments (remapped to positions in
%       the active list). Indices otherwise address that active vector,
%       not compartment_tags.
%
%   See also zef_downsample_surfaces, zef_get_active_compartments.

[active_compartments, source_compartments] = zef_get_active_compartments(zef);

% Map source tag-indices to positions inside the active-compartment vector.
source_compartments = find(ismember(active_compartments,source_compartments));

relative_resolution_vec = ones(size(active_compartments));

if zef.refinement_on

if zef.refinement_surface_on

rel_num_vec_aux = zef.refinement_surface_number(:).*ones(length(zef.refinement_surface_compartments),1);

for i = 1 : length(zef.refinement_surface_compartments)

if isequal(zef.refinement_surface_compartments(i),-1)

relative_resolution_vec(source_compartments) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(source_compartments);

else

relative_resolution_vec(zef.refinement_surface_compartments(i)) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(zef.refinement_surface_compartments(i));

end

end

end

if zef.refinement_surface_on_2

rel_num_vec_aux = zef.refinement_surface_number_2(:).*ones(length(zef.refinement_surface_compartments_2),1);

for i = 1 : length(zef.refinement_surface_compartments_2)

if isequal(zef.refinement_surface_compartments_2(i),-1)

relative_resolution_vec(source_compartments) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(source_compartments);

else

relative_resolution_vec(zef.refinement_surface_compartments_2(i)) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(zef.refinement_surface_compartments_2(i));

end

end

end

if zef.refinement_volume_on

rel_num_vec_aux = zef.refinement_volume_number(:).*ones(length(zef.refinement_volume_compartments),1);

for i = 1 : length(zef.refinement_volume_compartments)

if isequal(zef.refinement_volume_compartments(i),-1)

relative_resolution_vec(source_compartments) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(source_compartments);

else

relative_resolution_vec(zef.refinement_volume_compartments(i)) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(zef.refinement_volume_compartments(i));

end

end

end

if zef.refinement_volume_on_2

rel_num_vec_aux = zef.refinement_volume_number_2(:).*ones(length(zef.refinement_volume_compartments_2),1);

for i = 1 : length(zef.refinement_volume_compartments_2)

if isequal(zef.refinement_volume_compartments_2(i),-1)

relative_resolution_vec(source_compartments) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(source_compartments);

else

relative_resolution_vec(zef.refinement_volume_compartments_2(i)) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(zef.refinement_volume_compartments_2(i));

end

end

end

end

end
