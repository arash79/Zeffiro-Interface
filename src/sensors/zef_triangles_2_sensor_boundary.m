function [triangles_out] = zef_triangles_2_sensor_boundary(zef,compartment_tag,triangles_in)
% --- Zeffiro documentation header ---
% zef_triangles_2_sensor_boundary — Zef triangles 2 sensor boundary.
%
% Purpose:
%   Zef triangles 2 sensor boundary.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%   compartment_tag
%   triangles_in
%
% Outputs:
%   triangles_out
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.current_sensors (read)
%   zef.reuna_p (read)
%
% Calls (project):
%   zef_triangles_2_sensor_boundary
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[triangles_out] = zef_triangles_2_sensor_boundary(zef, compartment_tag, triangles_in)` with project root and `src` on the path.
% --- End Zeffiro documentation header


triangles_out = [];
    points_ind = []; 

    if isfield(zef,[zef.current_sensors '_boundary_cell'])

    boundary_cell = zef.([zef.current_sensors '_boundary_cell']);    
    points_ind = zeros(length(boundary_cell)+1,1);
    points_ind(1) = size(zef.reuna_p{end},1);

    end

for i = 1 : length(boundary_cell)

    compartment_tag_aux = boundary_cell{i};
    I = find(ismember(zef.compartment_tags,compartment_tag_aux),1);
    points_ind(i) = size(zef.reuna_p{I},1);

end

points_ind = cumsum(points_ind);
I = find(ismember(boundary_cell,compartment_tag),1);

if not(isempty(I))
triangles_out = points_ind(I-1)+triangles_in;
end

end
