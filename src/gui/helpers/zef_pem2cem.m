function sensors_attached_volume = zef_pem2cem(sensors_attached_volume,tetra);
% --- Zeffiro documentation header ---
% zef_pem2cem — Zef pem2cem.
%
% Purpose:
%   Zef pem2cem.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   sensors_attached_volume
%   tetra
%
% Outputs:
%   sensors_attached_volume
%
% Calls (project):
%   zef_pem2cem
%   zef_surface_mesh
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[sensors_attached_volume] = zef_pem2cem(sensors_attached_volume, tetra)` with project root and `src` on the path.
% --- End Zeffiro documentation header


n_electrodes = max(sensors_attached_volume(:,1),[],1);
sensors_aux = [];

for i = 1 : n_electrodes

    ele_ind_aux = find(sensors_attached_volume(:,1)==i);
    [I, ~] = find(sensors_attached_volume(ele_ind_aux,:)==0);

    if isempty(I)

        sensors_aux = [sensors_aux ; sensors_attached_volume(ele_ind_aux,:)];

    else

        [J,~] = find(tetra==sensors_attached_volume(ele_ind_aux,2));
        ele_tri = zef_surface_mesh(tetra,[],J);

        sensors_aux = [sensors_aux ; i(ones(size(ele_tri,1),1),1) ele_tri];

    end
end

sensors_attached_volume = sensors_aux;

end
