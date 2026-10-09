function zef_strip_tool_plot(zef)
%ZEF_STRIP_TOOL_PLOT  Draw the current strip (and contacts/encapsulation) on h_axes1.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_strip_tool_plot(zef)
%
%   Plot button. zef_create_strip + forward transform; trimesh with
%   tags 'additional: strip' / 'strip contact' / 'strip contact inactive'
%   / 'strip encapsulation' / 'strip burr'. Each mesh is stamped with
%   the lead strip_id. Deletes every previous strip preview, including
%   unwired DiSC disks. Does not write zef compartments.
%
%   See also zef_create_strip.

strip_struct = zef.([zef.current_sensors '_strip_cell']){zef.strip_tool.current_strip};
[strip_struct] = zef_create_strip(strip_struct);
points = zef_strip_coordinate_transform(strip_struct,'forward');

axes(zef.h_axes1)
delete(findobj(zef.h_axes1, '-regexp', 'Tag', '^additional: strip'));

hold on

triangle_ind = [1:size(strip_struct.triangles{1},1)];


if strip_struct.encapsulation_on

h_strip_encapsulation = trimesh(strip_struct.triangles{2},points{2}(:,1),points{2}(:,2),points{2}(:,3));
h_strip_encapsulation.FaceColor = [0 1 0];
h_strip_encapsulation.EdgeColor = 'none';
h_strip_encapsulation.Tag = 'additional: strip encapsulation';
local_tag_strip(h_strip_encapsulation, strip_struct);

end

if ismember(strip_struct.strip_model, [4 5])
lattice = zef_strip_disc_lattice(strip_struct.strip_model, strip_struct.strip_radius);
for physical = 1:lattice.n_physical
    [triangle_ind_aux, ~] = zef_strip_disc_patch(strip_struct, physical);
    if isempty(triangle_ind_aux)
        continue
    end
    contacts = strip_struct.triangles{1}(triangle_ind_aux, :);
    h_strip_contact = trimesh(contacts, points{1}(:,1), points{1}(:,2), points{1}(:,3));
    if lattice.active(physical)
        h_strip_contact.FaceColor = [0 0 0];
        h_strip_contact.Tag = 'additional: strip contact';
    else
        h_strip_contact.FaceColor = [0.55 0.55 0.55];
        h_strip_contact.Tag = 'additional: strip contact inactive';
    end
    h_strip_contact.EdgeColor = 'none';
    local_tag_strip(h_strip_contact, strip_struct);
    triangle_ind = setdiff(triangle_ind, triangle_ind_aux);
end
else
for i = 1 : strip_struct.strip_n_contacts

[contacts, ~, triangle_ind_aux] = zef_get_strip_contacts(i,strip_struct,zef);
if isempty(contacts)
continue
end
h_strip_contact = trimesh(contacts(:,1:3),points{1}(:,1),points{1}(:,2),points{1}(:,3));
h_strip_contact.FaceColor = [0 0 0];
h_strip_contact.EdgeColor = 'none';
h_strip_contact.Tag = 'additional: strip contact';
local_tag_strip(h_strip_contact, strip_struct);
triangle_ind = setdiff(triangle_ind, triangle_ind_aux);

end
end

h_strip = trimesh(strip_struct.triangles{1}(triangle_ind,:),points{1}(:,1),points{1}(:,2),points{1}(:,3));
h_strip.FaceColor = [0 1 1];
h_strip.EdgeColor = 'none';
h_strip.Tag = 'additional: strip';
local_tag_strip(h_strip, strip_struct);

if isfield(strip_struct,'burr_hole_on') && ~isempty(strip_struct.burr_hole_on) ...
        && double(strip_struct.burr_hole_on(1)) ~= 0 ...
        && isfield(strip_struct,'burr_holes') && ~isempty(strip_struct.burr_holes)
    burr_colors = [0.90 0.32 0.12; 0.93 0.62 0.08; 0.55 0.22 0.72; 0.12 0.45 0.72];
    for burr_i = 1:numel(strip_struct.burr_holes)
        try
            [burr_tri, burr_pts] = zef_strip_burr_surface(strip_struct, ...
                strip_struct.burr_holes(burr_i).radius_mm);
        catch ME
            warning('zef:BurrHolePreview', '%s', ME.message);
            continue
        end
        if isempty(burr_tri)
            continue
        end
        h_burr = trimesh(burr_tri, burr_pts(:,1), burr_pts(:,2), burr_pts(:,3));
        h_burr.FaceColor = burr_colors(mod(burr_i - 1, size(burr_colors, 1)) + 1, :);
        h_burr.FaceAlpha = 0.28;
        h_burr.EdgeColor = 'none';
        h_burr.Tag = 'additional: strip burr';
        local_tag_strip(h_burr, strip_struct);
    end
end

hold off

end

function local_tag_strip(graphic, strip_struct)
if isstruct(strip_struct) && isfield(strip_struct, 'strip_id') && isgraphics(graphic)
    graphic.UserData = struct('strip_id', strip_struct.strip_id);
end
end
