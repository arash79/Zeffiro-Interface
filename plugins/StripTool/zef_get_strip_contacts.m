function [contacts, sensor_info, triangle_ind] = zef_get_strip_contacts(contact_index,strip_struct,zef,domain_type,global_index)
%ZEF_GET_STRIP_CONTACTS  Contact triangles or points for one strip_model index.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [contacts, sensor_info, triangle_ind] = zef_get_strip_contacts(...)
%       contact_index, strip_struct, zef, domain_type, global_index)
%
%   domain_type default 'model_geometry'. 'points'/'model_points': the
%   active-channel center. 'sensor_info': empty contacts plus strip_id.
%   Models 1/2/3 keep their layouts. Models 4/5 use the lithographic
%   disk from zef_strip_disc_patch. On a volume mesh that contains no
%   vertex inside that disk, a tetrahedron that contains the contact
%   centre (at most 250000 tetrahedra are searched) returns four
%   barycentric rows [node, lambda, 0] and
%   sensor_info.electrode_representation is 'point_barycentric'.
%   Without such a tetrahedron the row is [node, 1, 0] and the
%   representation is 'point_unresolved'. A disk that the mesh does
%   resolve is 'finite_area'. Called from plot, add_contacts, and
%   sensor get_functions. Does not write zef.
%
%   See also zef_get_strip_parameters, zef_strip_disc_site.

if nargin < 4
    domain_type = 'model_geometry';
end

if nargin < 5
    global_index = [];
end

contacts = [];
sensor_info = struct;
triangle_ind = [];
sensor_info.strip_id = strip_struct.strip_id;
sensor_info.compartment_index = [];
if isfield(strip_struct,'compartment_tag')
sensor_info.compartment_index = find(ismember(zef.compartment_tags,strip_struct.compartment_tag(1)),1);
end

if not(isequal(domain_type,'sensor_info'))

if ismember(domain_type,{'model_points','points'})

    contacts = zeros(1,3);

if isequal(strip_struct.strip_model,1)
contacts(3) = 2.25+2.0*(contact_index-1);
end

if isequal(strip_struct.strip_model,2)
    if contact_index == 1
        contact_index_aux = 1;
contacts(3) = 2.25+2.0*(contact_index_aux-1);
    elseif contact_index == 8
            contact_index_aux = 4;
contacts(3)=2.25+2.0*(contact_index_aux-1);
    elseif ismember(contact_index,[2:7])   
    if ismember(contact_index,[2 3 4])
            contact_index_aux = 2;
            direction_index_aux = contact_index - 1;
      elseif ismember(contact_index,[5 6 7])
            contact_index_aux = 3;
            direction_index_aux = contact_index - 4;
    end
contacts(3) = 2.25+2.0*(contact_index_aux-1);
[contacts(1), contacts(2)] = pol2cart(-pi/2 + + 2*pi/3*(direction_index_aux - 1), strip_struct.strip_radius);

if isequal(domain_type,{'points'})
compartment_ind = find(ismember(zef.compartment_tags,strip_struct.compartment_tag{1}),1);
I = find(zef.domain_labels <= compartment_ind);
triangles = zef_surface_mesh(tetra, nodes, I, gpu_mode);
[points_aux,triangles_aux] = zef_get_submesh(zef.nodes,triangles);
contacts = knnsearch(points_aux , contacts);
end

        end
end

if isequal(strip_struct.strip_model,3)
row_ind_aux = ceil(contact_index/4);
contacts(3) = 0.75+0.75*(row_ind_aux-1);
angle_aux = (2*pi/4)*mod(contact_index,4) + (pi/4)*mod(row_ind_aux,2);
[contacts(1), contacts(2)] = pol2cart(angle_aux,strip_struct.strip_radius);
end

if ismember(strip_struct.strip_model,[4 5])
% Active channel center. Roll is strip_angle in the transform below.
[angle_aux, z_center_aux] = zef_strip_disc_site(contact_index, strip_struct.strip_model, strip_struct.strip_radius);
contacts(3) = z_center_aux;
[contacts(1), contacts(2)] = pol2cart(angle_aux,strip_struct.strip_radius);
sensor_info.electrode_representation = 'center';
end

contacts(1:3) = zef_strip_coordinate_transform(strip_struct,'forward',contacts(1:3));

end


if isequal(domain_type,'model_geometry')
triangles = strip_struct.triangles{1};
end

if isequal(domain_type,'geometry')
compartment_ind = find(ismember(zef.compartment_tags,strip_struct.compartment_tag{1}),1);
strip_struct.points{1} = zef.reuna_p{compartment_ind}; 
strip_struct.triangles{1} = zef.reuna_t{compartment_ind}; 
strip_struct.points = zef_strip_coordinate_transform(strip_struct,'reverse');
triangles = zef.reuna_t{compartment_ind};
end

mesh_node_map = [];
if isequal(domain_type,'mesh')

compartment_ind = find(ismember(zef.compartment_tags,strip_struct.compartment_tag{1}),1);
triangles_flag_aux = 0;
if iscell(zef.surface_triangles)
    if length(zef.surface_triangles) >= compartment_ind
triangles = zef.surface_triangles{compartment_ind};
triangles_flag_aux = 1;
    end
end
if not(triangles_flag_aux)
I_aux = find(zef.domain_labels <= compartment_ind);
triangles = zef_surface_mesh();
end    
[points_aux,triangles_aux,mesh_node_map] = zef_get_submesh(zef.nodes,triangles);
strip_struct.points{1} = points_aux; 
strip_struct.triangles{1} = triangles_aux; 
strip_struct.points = zef_strip_coordinate_transform(strip_struct,'reverse');

end

if ismember(domain_type, {'geometry','mesh','model_geometry'})

if isequal(strip_struct.strip_model,1)
point_ind = find(strip_struct.points{1}(:,3)>=1.5+2.0*(contact_index-1) & strip_struct.points{1}(:,3)<=3.0+2*(contact_index-1));
end

if isequal(strip_struct.strip_model,2)
    if contact_index == 1
        contact_index_aux = 1;
point_ind = find(strip_struct.points{1}(:,3)>=1.5+2.0*(contact_index_aux-1) & strip_struct.points{1}(:,3)<=3.0+2*(contact_index_aux-1));
    elseif contact_index == 8
            contact_index_aux = 4;
point_ind = find(strip_struct.points{1}(:,3)>=1.5+2.0*(contact_index_aux-1) & strip_struct.points{1}(:,3)<=3.0+2*(contact_index_aux-1));
    elseif ismember(contact_index,[2:7])   
    if ismember(contact_index,[2 3 4])
            contact_index_aux = 2;
            direction_index_aux = contact_index - 1;
      elseif ismember(contact_index,[5 6 7])
            contact_index_aux = 3;
            direction_index_aux = contact_index - 4;
    end
point_ind = find(strip_struct.points{1}(:,3)>=1.5+2.0*(contact_index_aux-1) & strip_struct.points{1}(:,3)<=3.0+2*(contact_index_aux-1));
angle_aux = cart2pol(strip_struct.points{1}(point_ind,1),strip_struct.points{1}(point_ind,2));
angle_ind = find(angle_aux >= -2*pi/3 + 2*pi/3*(direction_index_aux - 1) & angle_aux <= -pi/3 + 2*pi/3*(direction_index_aux - 1));
point_ind = point_ind(angle_ind);    
        end
end

if isequal(strip_struct.strip_model,3)
row_ind_aux = ceil(contact_index/4);
point_ind = find(strip_struct.points{1}(:,3)>=0.75+0.75*(row_ind_aux-1) & strip_struct.points{1}(:,3)<=1.5+0.75*(row_ind_aux-1));
angle_aux = (2*pi/4)*mod(contact_index,4)+ (pi/4)*mod(row_ind_aux,2);
[center_point_x_aux, center_point_y_aux] = pol2cart(angle_aux,strip_struct.strip_radius);
center_point_aux = [center_point_x_aux; center_point_y_aux; 0.75 + 0.5*0.75 + 0.75*(row_ind_aux-1)];
point_ind_aux = find(sqrt(sum((strip_struct.points{1}(point_ind,:)'-center_point_aux).^2))<=0.5*0.75);
point_ind = point_ind(point_ind_aux);
end

if ismember(strip_struct.strip_model,[4 5])
lattice = zef_strip_disc_lattice(strip_struct.strip_model, strip_struct.strip_radius);
physical_index = lattice.active_physical(contact_index);
[triangle_ind, ~] = zef_strip_disc_patch(strip_struct, physical_index);
if isempty(triangle_ind) && isequal(domain_type,'mesh') && ~isempty(mesh_node_map)
    [~, z_center_aux] = zef_strip_disc_site(contact_index, strip_struct.strip_model, strip_struct.strip_radius);
    [x_aux, y_aux] = pol2cart(lattice.angle(physical_index), strip_struct.strip_radius);
    target = [x_aux, y_aux, z_center_aux];
    [~, local_node] = min(sum((strip_struct.points{1} - target) .^ 2, 2));
    triangle_ind = zeros(0, 1);
    target_world = zef_strip_coordinate_transform(strip_struct, 'forward', target);
    barycentric = local_barycentric_rows(zef, target_world);
    if isempty(barycentric)
        contacts = [mesh_node_map(local_node), 1, 0];
        sensor_info.electrode_representation = 'point_unresolved';
    else
        contacts = barycentric;
        sensor_info.electrode_representation = 'point_barycentric';
    end
else
    contacts = triangles(triangle_ind,:);
    if isempty(triangle_ind)
        sensor_info.electrode_representation = 'absent';
    else
        sensor_info.electrode_representation = 'finite_area';
    end
end
else
triangle_ind = find(sum(ismember(strip_struct.triangles{1},point_ind),2)==3);
contacts = triangles(triangle_ind,:);
end
if not(isempty(global_index))
contacts = [global_index(ones(size(contacts,1),1),1) contacts];
end

end
end

end

function rows = local_barycentric_rows(zef, target_world)

rows = zeros(0, 3);
if ~isstruct(zef) || ~isfield(zef, 'tetra') || ~isfield(zef, 'nodes')
    return
end
tetra = zef.tetra;
nodes = zef.nodes;
if isempty(tetra) || isempty(nodes) || size(tetra, 1) > 250000 || size(target_world, 2) ~= 3
    return
end
tetra = double(tetra);
nodes = double(nodes);
target_world = double(target_world(1, 1:3));
edge_1 = nodes(tetra(:, 2), :) - nodes(tetra(:, 1), :);
edge_2 = nodes(tetra(:, 3), :) - nodes(tetra(:, 1), :);
edge_3 = nodes(tetra(:, 4), :) - nodes(tetra(:, 1), :);
volume = zef_determinant(edge_1, edge_2, edge_3);
sensor = target_world - nodes(tetra(:, 1), :);
lambda_2 = zef_determinant(sensor, edge_2, edge_3) ./ volume;
lambda_3 = zef_determinant(edge_1, sensor, edge_3) ./ volume;
lambda_4 = zef_determinant(edge_1, edge_2, sensor) ./ volume;
lambda_1 = 1 - lambda_2 - lambda_3 - lambda_4;
tolerance = 1e-8;
inside = lambda_1 >= -tolerance & lambda_2 >= -tolerance & lambda_3 >= -tolerance & lambda_4 >= -tolerance ...
    & lambda_1 <= 1 + tolerance & lambda_2 <= 1 + tolerance & lambda_3 <= 1 + tolerance & lambda_4 <= 1 + tolerance ...
    & abs(volume) > 0;
tetra_index = find(inside, 1, 'first');
if isempty(tetra_index)
    return
end
lambda = [lambda_1(tetra_index); lambda_2(tetra_index); lambda_3(tetra_index); lambda_4(tetra_index)];
lambda = max(lambda, 0);
lambda = lambda / sum(lambda);
rows = [double(tetra(tetra_index, :)'), lambda, zeros(4, 1)];
end
