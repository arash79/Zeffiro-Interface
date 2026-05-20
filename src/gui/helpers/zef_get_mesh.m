%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [mesh_data_1,mesh_data_2,submesh_data] = zef_get_mesh(zef,file_str,field_id,file_type,varargin)

output_mode = 1;
if not(isempty(varargin))
    output_mode = varargin{1};
end

mesh_data_1 = [];
mesh_data_2 = [];
submesh_data = [];

file_str = fullfile(file_str);

if isequal(output_mode,'full');
    mesh_data_1 = eval(['zef.' field_id '_points;']);
    mesh_data_2 = eval(['zef.' field_id '_triangles;']);
    submesh_data = eval(['zef.' field_id '_submesh_ind;']);
end

eval(['zef.' field_id '_triangles_original_surface_mesh = [];']);
eval(['zef.' field_id '_points_original_surface_mesh = [];']);
eval(['zef.' field_id '_submesh_ind_original_surface_mesh = [];']);

merge_on = eval(['zef.' field_id '_merge']);
invert_on = eval(['zef.' field_id '_invert']);

if isequal(file_type,'points')

    if merge_on
        l1_points = eval(['zef.' field_id '_points']);
        l2_points = load(file_str);
        mesh_data_1 = [l1_points; l2_points];
    else
        mesh_data_1 = load(file_str);
    end

end

if isequal(file_type,'triangles')

    if merge_on
        l1_triangles = eval(['zef.' field_id '_triangles']);
        l2_triangles = load(file_str);
        if invert_on
            l2_triangles = l2_triangles(:,[2 1 3]);
        end
        if isempty(l1_triangles)
            max_val = 0;
        else
            max_val = max(l1_triangles(:));
        end

        if isequal(output_mode,'full')
            mesh_data_2 = [l1_triangles; l2_triangles+max_val];
        else
            mesh_data_1 = [l1_triangles; l2_triangles+max_val];
        end
    else
        if isequal(output_mode,'full')
            mesh_data_2 = load(file_str);
            if invert_on
                mesh_data_2 = mesh_data_2(:,[2 1 3]);
            end
        else
            mesh_data_1 = load(file_str);
            if invert_on
                mesh_data_1 = mesh_data_1(:,[2 1 3]);
            end
        end
    end

    if merge_on
        submesh_data = [submesh_data size(mesh_data_2,1)];
    else
        submesh_data = [size(mesh_data_2,1)];
    end

end

if isequal(file_type,'stl')

    warning_state = warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    warning_cleanup = onCleanup(@() warning(warning_state));
    stl_data = stlread(file_str);
    clear warning_cleanup;

    [stl_points, stl_triangles] = zef_compact_mesh(stl_data.Points, stl_data.ConnectivityList);

    if merge_on
        l1_points = eval(['zef.' field_id '_points']);
        l2_points = stl_points;
        mesh_data_1 = [l1_points; l2_points];
    else
        mesh_data_1 = stl_points;
    end

    if merge_on
        l1_triangles = eval(['zef.' field_id '_triangles']);
        l2_triangles = stl_triangles;
        if invert_on
            l2_triangles = l2_triangles(:,[2 1 3]);
        end
        if isempty(l1_triangles)
            max_val = 0;
        else
            max_val = max(l1_triangles(:));
        end

        mesh_data_2 = [l1_triangles; l2_triangles+max_val];

    else

        mesh_data_2 = stl_triangles;

        if invert_on
            mesh_data_2 = mesh_data_2(:,[2 1 3]);
        end
    end

    if merge_on
        submesh_data = [submesh_data size(mesh_data_2,1)];
    else
        submesh_data = [size(mesh_data_2,1)];
    end

end

if isequal(file_type,'asc')

    file_name_1 = file_str;

    fid = fopen(file_name_1);
    aux_dim = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',1);
    aux_dim = str2num(aux_dim{1}{1});
    if numel(aux_dim) < 2
        error('zef_get_mesh:InvalidSurfaceAsc', ...
            'File "%s" is not a FreeSurfer surface .asc file. Label .asc files should be imported through atlas_points_filename, not as segmentation meshes.', ...
            file_str);
    end
    aux_dim = aux_dim(1:2);

    point_data = zeros(aux_dim(1),3);
    triangle_data = zeros(aux_dim(2),3);

    fid = fopen(file_name_1);
    aux_data = textscan(fid,'%s',aux_dim(1),'delimiter','\n', 'headerlines',2);

    point_data = cellfun(@(v) zef_import_asc(v),aux_data{1},'uniformoutput',false);
    point_data = cell2mat(point_data);

    fid = fopen(file_name_1);
    aux_data = textscan(fid,'%s',aux_dim(2),'delimiter','\n', 'headerlines',2+aux_dim(1));

    triangle_data = cellfun(@(v) zef_import_asc(v),aux_data{1},'uniformoutput',false);
    triangle_data = cell2mat(triangle_data)+1;

    if merge_on
        l1_points = eval(['zef.' field_id '_points']);
        l2_points = point_data;
        mesh_data_1 = [l1_points; l2_points];
    else
        mesh_data_1 = point_data;
    end

    if merge_on
        l1_triangles = eval(['zef.' field_id '_triangles']);
        l2_triangles = triangle_data;
        if invert_on
            l2_triangles = l2_triangles(:,[2 1 3]);
        end
        if isempty(l1_triangles)
            max_val = 0;
        else
            max_val = max(l1_triangles(:));
        end

        mesh_data_2 = [l1_triangles; l2_triangles+max_val];

    else

        mesh_data_2 = triangle_data;

        if invert_on
            mesh_data_2 = mesh_data_2(:,[2 1 3]);
        end
    end

    if merge_on
        submesh_data = [submesh_data size(mesh_data_2,1)];
    else
        submesh_data = [size(mesh_data_2,1)];
    end

end

end

function [points, triangles] = zef_compact_mesh(points, triangles)

if isempty(points) || isempty(triangles)
    return;
end

used_point_ind = unique(triangles(:));
point_map = zeros(size(points,1),1);
point_map(used_point_ind) = 1:numel(used_point_ind);

points = points(used_point_ind,:);
triangles = reshape(point_map(triangles), size(triangles));

end % function
