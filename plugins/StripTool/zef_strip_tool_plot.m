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
%   tags 'additional: strip' / 'strip contact' / 'strip encapsulation'.
%   Deletes previous tagged meshes. Does not write zef compartments.
%
%   See also zef_create_strip.

strip_struct = zef.([zef.current_sensors '_strip_cell']){zef.strip_tool.current_strip};
[strip_struct] = zef_create_strip(strip_struct);
points = zef_strip_coordinate_transform(strip_struct,'forward');

axes(zef.h_axes1)
h_strip = findobj(zef.h_axes1.Children,'Tag','additional: strip');
h_strip_contact = findobj(zef.h_axes1.Children,'Tag','additional: strip contact');
h_strip_encapsulation = findobj(zef.h_axes1.Children,'Tag','additional: strip encapsulation');
h_strip_burr = findobj(zef.h_axes1.Children,'Tag','additional: strip burr');

if not(isempty(h_strip))
    delete(h_strip)
end

if not(isempty(h_strip_contact))
    delete(h_strip_contact)
end

if not(isempty(h_strip_encapsulation))
    delete(h_strip_encapsulation)
end

if not(isempty(h_strip_burr))
    delete(h_strip_burr)
end

hold on

triangle_ind = [1:size(strip_struct.triangles{1},1)];


if strip_struct.encapsulation_on

h_strip_encapsulation = trimesh(strip_struct.triangles{2},points{2}(:,1),points{2}(:,2),points{2}(:,3));
h_strip_encapsulation.FaceColor = [0 1 0];
h_strip_encapsulation.EdgeColor = 'none';
h_strip_encapsulation.Tag = 'additional: strip encapsulation';

end

for i = 1 : strip_struct.strip_n_contacts

[contacts, ~, triangle_ind_aux] = zef_get_strip_contacts(i,strip_struct,zef);
h_strip_contact = trimesh(contacts(:,1:3),points{1}(:,1),points{1}(:,2),points{1}(:,3));
h_strip_contact.FaceColor = [0 0 0];
h_strip_contact.EdgeColor = 'none';
h_strip_contact.Tag = 'additional: strip contact';
triangle_ind = setdiff(triangle_ind, triangle_ind_aux);

end

h_strip = trimesh(strip_struct.triangles{1}(triangle_ind,:),points{1}(:,1),points{1}(:,2),points{1}(:,3));
h_strip.FaceColor = [0 1 1];
h_strip.EdgeColor = 'none';
h_strip.Tag = 'additional: strip';

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
    end
end

hold off

end
