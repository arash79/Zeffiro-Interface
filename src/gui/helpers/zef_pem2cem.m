function sensors_attached_volume = zef_pem2cem(sensors_attached_volume,tetra);
%ZEF_PEM2CEM  Turn point-like CEM rows into boundary triangles.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Only first-party caller: zef_lead_field_eeg_fem, after it has decided
%   electrode_model=='CEM' (electrodes have 4 columns). That path sets
%   ele_ind to the attachment table (typically zef.sensors_attached_volume
%   from zef_attach_sensors_volume) and then ele_ind = zef_pem2cem(ele_ind,
%   tetrahedra) before zef_build_electrodes. zef_lead_field_tes_fem has
%   the same call commented out. Not a menu item.
%
%   Per electrode id (column 1, 1:max):
%     - If that electrode's rows contain no zeros, they are copied as-is
%       (already [id, n1, n2, n3] surface triangles).
%     - If any entry is 0 (point / barycentric / geometry stubs such as
%       [id, node, 1, 0] or [id, 0, 1, 0]), column 2 is treated as a node
%       index: tets that contain that node are passed as I to
%       zef_surface_mesh, and the rows become [id, t1, t2, t3] for those
%       skin triangles.
%
%   sensors_attached_volume = zef_pem2cem(sensors_attached_volume, tetra)
%
%   Inputs
%     sensors_attached_volume - R×≥4. Column 1 is the 1-based electrode id.
%     tetra                   - T×4 tet connectivity (same indexing as the
%                               attachment table).
%
%   Output
%     sensors_attached_volume - stacked [id, n1, n2, n3] (or original rows
%                               when there were no zeros). Empty input of
%                               a given id contributes nothing.
%
%   See also zef_build_electrodes, zef_attach_sensors_volume, zef_surface_mesh.

n_electrodes = max(sensors_attached_volume(:,1),[],1);
sensors_aux = [];

for i = 1 : n_electrodes

    ele_ind_aux = find(sensors_attached_volume(:,1)==i);
    % Any 0 in this electrode's block → treat column 2 as a node, not a triangle.
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
