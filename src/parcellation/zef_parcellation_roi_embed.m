%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [c_table,c_points] = zef_parcellation_roi_embed(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_roi_embed — Zef parcellation roi embed.
%
% Purpose:
%   Zef parcellation roi embed.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   c_table
%   c_points
%
% Zef fields (observed):
%   zef.parcellation_colortable (read)
%   zef.parcellation_merge (read)
%   zef.parcellation_points (read)
%   zef.parcellation_roi_center (read)
%   zef.parcellation_roi_color (read)
%   zef.parcellation_roi_name (read)
%   zef.parcellation_roi_radius (read)
%   zef.parcellation_selected (read, write)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_parcellation_roi_embed
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[c_table, c_points]] = zef_parcellation_roi_embed(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


c_table = cell(0);
c_points = cell(0);

if eval('zef.parcellation_merge')
    c_table = eval('zef.parcellation_colortable');
    c_points = eval('zef.parcellation_points');
else
    eval('zef.parcellation_selected = [];');
end

t_ind = length(c_table);

t_ind = t_ind + 1;

c_table{t_ind}{1} = 'ROI';

c_points_aux = [];
c_table{t_ind}{4} = [];
start_index = 0;
for i = 1 : size(zef.parcellation_roi_center,1)
c_points_aux_0 = zef.source_positions;
c_points_aux_1 = c_points_aux_0(find(sqrt(sum((c_points_aux_0-zef.parcellation_roi_center(i,:)).^2,2))<= zef.parcellation_roi_radius(i)),:);
c_points_aux = [c_points_aux ; [[start_index:start_index + size(c_points_aux_1,1)-1]' c_points_aux_1]];
start_index = start_index + size(c_points_aux_1,1); 
c_table{t_ind}{4} = [c_table{t_ind}{4} ; i*ones(size(c_points_aux_1,1),1)];
c_table{t_ind}{2}{i,1} = zef.parcellation_roi_name{i};
c_table{t_ind}{3}(i,1:3) = zef.parcellation_roi_color(i,:);
c_table{t_ind}{3}(i,5) =  i;
end

c_points{t_ind} = c_points_aux;
c_table{t_ind}{3}(:,1:3) = round(255*c_table{t_ind}{3}(:,1:3));
c_table{t_ind}{4} = c_table{t_ind}{4}(:);

end
