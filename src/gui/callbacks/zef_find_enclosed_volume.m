function volume_val = zef_find_enclosed_volume(nodes, triangles)
% --- Zeffiro documentation header ---
% zef_find_enclosed_volume — Zef find enclosed volume.
%
% Purpose:
%   Zef find enclosed volume.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   nodes
%   triangles
%
% Outputs:
%   volume_val
%
% Calls (project):
%   zef_find_enclosed_volume
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[volume_val] = zef_find_enclosed_volume(nodes, triangles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


c_t = (1/3)*(nodes(triangles(:,1),:) + nodes(triangles(:,2),:) + nodes(triangles(:,3),:));
n_t = cross(nodes(triangles(:,3),:)'-nodes(triangles(:,1),:)', nodes(triangles(:,2),:)'-nodes(triangles(:,1),:)');
ala = sqrt(sum(n_t.^2))/2;
volume_val = abs((1/3)*sum(dot(c_t',n_t).*ala));

end
