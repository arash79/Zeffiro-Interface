function relative_resolution_vec = zef_find_relative_resolution(zef)
% --- Zeffiro documentation header ---
% zef_find_relative_resolution — Zef find relative resolution.
%
% Purpose:
%   Zef find relative resolution.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   relative_resolution_vec
%
% Zef fields (observed):
%   zef.refinement_on (read)
%   zef.refinement_surface_compartments (read)
%   zef.refinement_surface_compartments_2 (read)
%   zef.refinement_surface_compartments_3 (read)
%   zef.refinement_surface_number (read)
%   zef.refinement_surface_number_2 (read)
%   zef.refinement_surface_number_3 (read)
%   zef.refinement_surface_on (read)
%   zef.refinement_surface_on_2 (read)
%   zef.refinement_surface_on_3 (read)
%   zef.refinement_volume_compartments (read)
%   zef.refinement_volume_compartments_2 (read)
%   zef.refinement_volume_compartments_3 (read)
%   zef.refinement_volume_number (read)
%   zef.refinement_volume_number_2 (read)
%   … (4 more)
%
% Calls (project):
%   zef_find_relative_resolution
%   zef_get_active_compartments
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[relative_resolution_vec] = zef_find_relative_resolution(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


[active_compartments, source_compartments] = zef_get_active_compartments(zef);

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

% if zef.refinement_surface_on_3
% 
% rel_num_vec_aux = zef.refinement_surface_number_3(:).*ones(length(zef.refinement_surface_compartments_3),1);
% 
% for i = 1 : length(zef.refinement_surface_compartments_3)
% 
% if isequal(zef.refinement_surface_compartments_3(i),-1)
% 
% relative_resolution_vec(source_compartments) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(source_compartments);
% 
% else
% 
% relative_resolution_vec(zef.refinement_surface_compartments_3(i)) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(zef.refinement_surface_compartments_3(i));
% 
% end
% 
% end
% 
% end

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

% if zef.refinement_volume_on_3
% 
% rel_num_vec_aux = zef.refinement_volume_number_3(:).*ones(length(zef.refinement_volume_compartments_3),1);
% 
% for i = 1 : length(zef.refinement_volume_compartments_3)
% 
% if isequal(zef.refinement_volume_compartments_3(i),-1)
% 
% relative_resolution_vec(source_compartments) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(source_compartments);
% 
% else
% 
% relative_resolution_vec(zef.refinement_volume_compartments_3(i)) = (4.^rel_num_vec_aux(i)).*relative_resolution_vec(zef.refinement_volume_compartments_3(i));
% 
% end
% 
% end
% 
% end

end

end
