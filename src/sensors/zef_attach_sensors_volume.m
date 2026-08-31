function  [sensors_attached_volume] = zef_attach_sensors_volume(zef,sensors,varargin)
%ZEF_ATTACH_SENSORS_VOLUME  Attach EEG/ECoG sensors to volume or surface geometry.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For imaging_method in {1, 4, 5} (EEG / EIT / TES), snaps contacts onto
%   the FEM mesh or the compartment surface so the lead-field builders can
%   couple them. MEG (2, 3) returns [] — coils stay at zef.sensors xyz.
%
%   Callers: every EEG/EIT/TES *_make_all / *_lead_field path, plotters
%   (Visualize volume/surfaces and Frame/Movie), zef_smoothing_step,
%   LF-bank recompute. The Mesh-vis checkbox Attach electrodes is only a
%   *plot* flag; the forward path always attaches.
%
%   Column layout of the input sensors matrix (this is what the body
%   actually tests, not the CSV header names):
%     N×3  → electrode_model 1 (PEM). Snap xyz to nearest surface node
%            (or nearest volume node when zef.use_depth_electrodes is 1).
%     N×6  → electrode_model 2 (CEM). Columns 4 and 5 are radii in the
%            same length unit as xyz:
%              col4 == 0 and col5 == 0 → buried contact: barycentric
%                coordinates in the enclosing tetra (mesh) or a dummy
%                geometry row.
%              col4 == 0 and col5 == 1 → nearest surface node (one row).
%              otherwise annular patch: triangles whose centroid distance
%                d from the (snapped) centre satisfies col5 ≤ d < col4,
%                i.e. col4 is the outer radius and col5 the inner radius.
%            That [outer, inner] order matches zef_cem_electrode (called
%            from zef_process_meshes as create_patch_sensor for EEG) and
%            the Import parsers (DAT/CSV files list inner then outer;
%            from_dat / from_csv swap those two columns). process_meshes
%            may overwrite those columns from the Segmentation-tool radius
%            widgets before a typical lead-field run.
%
%   attach_type (varargin{1}, default 'mesh')
%     'mesh'     – FEM nodes / tetra / surface_triangles{end-k+1}.
%     'geometry' – compartment surface reuna_p / reuna_t (plotters use
%                  this for Visualize surfaces).
%     'points'   – PEM-style xyz snap even when sensors are 6-column;
%                  used to place CEM name labels.
%
%   Which surface: zef.<current_sensors>_electrode_surface_index (default
%   1). If the outermost reuna_type is Bounding box (_sources == -1),
%   the index is counted from the last non-box surface.
%
%   Output table (consumed by zef_pem2cem / zef_build_electrodes and by
%   the CEM trisurf plot path):
%     PEM / 'points': N×(same width as input), xyz replaced by the snap.
%     CEM tetra: 4 rows per contact [id, tet_node, barycentric λ, 0].
%     CEM nearest node: 1 row [id, node_or_triangle_index, 1, 0].
%     CEM annulus: one row per triangle [id, n1, n2, n3].
%   Empty when imaging_method is not 1, 4, or 5.
%
%   sensors_attached_volume = zef_attach_sensors_volume(zef, sensors)
%   sensors_attached_volume = zef_attach_sensors_volume(zef, sensors, attach_type, ...)
%
%   Inputs
%     zef     - session struct (read from base when empty). Must contain
%               nodes, tetra, surface_triangles or reuna_p/t, imaging_method,
%               current_sensors, use_depth_electrodes.
%     sensors - N-by-3 (PEM) or N-by-6 (CEM) as above.
%     varargin:
%       {1} attach_type       - 'mesh' | 'geometry' | 'points'
%       {2} get_functions     - cell of per-contact MATLAB strings
%       {3} nodes             - override zef.nodes
%       {4} tetra             - override zef.tetra
%       {5} surface_triangles - override zef.surface_triangles
%       {6} bypass_functions  - 1 skips get_function eval
%
%   Output
%     sensors_attached_volume - attachment table; assign to
%       zef.sensors_attached_volume. Does not return a modified zef.
%
%   See also zef_sensor_get_function_eval, zef_fix_sensors_get_functions_array_size,
%            zef_cem_electrode, zef_build_electrodes.

if isempty(zef)
    zef = evalin('base','zef');
end

attach_type = 'mesh';
bypass_functions = 0;
I_get_functions = [];

 if isfield(zef,[zef.current_sensors '_electrode_surface_index'])
 electrode_surface_index = zef.([zef.current_sensors '_electrode_surface_index']);
 else
 electrode_surface_index = 1;
 end

if not(bypass_functions)
zef = zef_fix_sensors_get_functions_array_size(zef);
sensors_get_functions = zef.([zef.current_sensors '_get_functions']);
sensors_attached_get_functions = cell(0);
end

if not(isempty(varargin))
    if length(varargin) > 0
        attach_type = varargin{1};
        if length(varargin) > 1
            if not(isempty(varargin{2}))
            sensors_get_functions = varargin{2};
            end
        end
        if length(varargin) > 2
            if not(isempty(varargin{3}))
            zef.nodes = varargin{3};
            end
        end
        if length(varargin) > 3
            if not(isempty(varargin{4}))
            zef.tetra = varargin{4};
            end
        end
        if length(varargin) > 4
            if not(isempty(varargin{5}))
            zef.surface_triangles = varargin{5};
            end
        end
        if length(varargin) > 5
            if not(isempty(varargin{6}))
            bypass_functions = varargin{6};
            end
        end
    end
end

if not(iscell(zef.surface_triangles))
zef.surface_triangles = {zef.surface_triangles};
end

%*****************************
if not(bypass_functions)  
    I_get_functions = find(cellfun(@isempty,sensors_get_functions)==0);
    for i_ind = 1 : length(I_get_functions)
        sensors_attached_get_functions{i_ind} = zef_sensor_get_function_eval(sensors_get_functions{I_get_functions(i_ind)},zef,attach_type);
      sensors_attached_get_functions{i_ind} = [I_get_functions(i_ind)*ones(size(sensors_attached_get_functions{i_ind},1),1) sensors_attached_get_functions{i_ind}];
    end
end

if ismember(zef.imaging_method,[1,4,5])

    if not(isequal(zef.reuna_type{end,1},-1))
        geometry_triangles = zef.reuna_t{end-electrode_surface_index+1};
        geometry_nodes = zef.reuna_p{end-electrode_surface_index+1};
    else
        geometry_triangles = zef.reuna_t{end-electrode_surface_index};
        geometry_nodes = zef.reuna_p{end-electrode_surface_index};
    end

    if not(iscell(zef.surface_triangles))
        zef.surface_triangles = {zef.surface_triangles};
    end
    use_depth_electrodes =zef.use_depth_electrodes;

    % 6 columns → complete electrode model (radii + impedance). 3 columns
    % (or attach_type 'points') → point electrodes: only xyz is snapped.
    if size(sensors,2) == 6
        electrode_model = 2;
    else
        electrode_model = 1;
    end

    if electrode_model == 1 || isequal(attach_type,'points')

        % PEM / label-points: snap each contact to a single vertex.
        % Depth electrodes (use_depth_electrodes) search the volume nodes;
        % otherwise search the scalp/geometry surface.
        if electrode_model == 1 && use_depth_electrodes == 1
            surface_ind = [];
            deep_ind = [1:size(sensors,1)]';
        elseif electrode_model == 1 && use_depth_electrodes == 0
            surface_ind = [1:size(sensors,1)]';
            deep_ind = [];
        else
            surface_ind = find(not(ismember(sensors(:,5),0)));
            deep_ind = setdiff(find(ismember(sensors(:,4),0)),surface_ind);
        surface_ind = setdiff(surface_ind, I_get_functions);
         deep_ind = setdiff(deep_ind, I_get_functions);
        end
        sensors_attached_volume = sensors;
        for i = 1 : length(deep_ind)
            [min_val, min_ind] = min(sqrt(sum((zef.nodes - repmat(sensors(deep_ind(i),1:3),size(zef.nodes,1),1)).^2,2)));
            sensors_attached_volume(deep_ind(i),1:3) = zef.nodes(min_ind,:);
        end
        for i = 1 : length(surface_ind)
            [min_val, min_ind] = min(sqrt(sum((geometry_nodes - repmat(sensors(surface_ind(i),1:3),size(geometry_nodes,1),1)).^2,2)));
            sensors_attached_volume(surface_ind(i),1:3) = geometry_nodes(min_ind,:);
        end

    else

        if (isequal(attach_type,'geometry'))
            geometry_center_points_aux = (1/3)*(geometry_nodes(geometry_triangles(:,1),:) + ...
                geometry_nodes(geometry_triangles(:,2),:) + ...
                geometry_nodes(geometry_triangles(:,3),:));
        else
            center_points_aux = (1/3)*(zef.nodes(zef.surface_triangles{end-electrode_surface_index+1}(:,1),:) + ...
                zef.nodes(zef.surface_triangles{end-electrode_surface_index+1}(:,2),:) + ...
                zef.nodes(zef.surface_triangles{end-electrode_surface_index+1}(:,3),:));

            unique_surface_triangles = unique(zef.surface_triangles{end-electrode_surface_index+1});
            ele_nodes = zef.nodes(unique_surface_triangles,:);

            if not(isempty(find(sensors(:,4) == 0)))
                diff_vec_1 = (zef.nodes(zef.tetra(:,2),:) - zef.nodes(zef.tetra(:,1),:));
                diff_vec_2 = (zef.nodes(zef.tetra(:,3),:) - zef.nodes(zef.tetra(:,1),:));
                diff_vec_3 = (zef.nodes(zef.tetra(:,4),:) - zef.nodes(zef.tetra(:,1),:));
                det_system = zef_determinant(diff_vec_1,diff_vec_2,diff_vec_3);
            end

        end

        sensors_aux = [];
i_ind = 0;
        for i = 1 : size(sensors,1)
            if ismember(i,I_get_functions)
                i_ind = i_ind + 1; 
                sensors_aux = [sensors_aux; sensors_attached_get_functions{i_ind}];
            else
            % Buried CEM contact: both radii zero. Mesh path finds the
            % enclosing tetra via barycentric λ_i ∈ [0,1] and stores four
            % (electrode, node, λ, 0) rows for zef_pem2cem.
            if sensors(i,4) == 0 && sensors(i,5) == 0

                if isequal(attach_type,'mesh')

                    diff_vec_sensor = (repmat(sensors(i,1:3),size(zef.tetra,1),1)- zef.nodes(zef.tetra(:,1),:));
                    lambda_2 = zef_determinant(diff_vec_sensor,diff_vec_2,diff_vec_3);
                    lambda_3 = zef_determinant(diff_vec_1,diff_vec_sensor,diff_vec_3);
                    lambda_4 = zef_determinant(diff_vec_1,diff_vec_2,diff_vec_sensor);
                    lambda_2 = lambda_2./det_system;
                    lambda_3 = lambda_3./det_system;
                    lambda_4 = lambda_4./det_system;
                    lambda_1 = 1 - lambda_2 - lambda_3 - lambda_4;
                    sensor_index = find(lambda_1 <= 1 & lambda_2 <= 1 & lambda_3 <= 1  & lambda_4 <= 1 ...
                        &  lambda_1 >= 0 & lambda_2 >= 0 & lambda_3 >= 0  & lambda_4 >= 0,1);
                    lambda_vec = [lambda_1(sensor_index) ; lambda_2(sensor_index) ; lambda_3(sensor_index) ; lambda_4(sensor_index)];
                    sensors_aux = [sensors_aux ; i*ones(4,1)  zef.tetra(sensor_index,:)' lambda_vec zeros(4,1)];

                end

                if isequal(attach_type,'geometry')

                    [min_val, min_ind] = min(sqrt(sum((geometry_nodes - repmat(sensors(i,1:3),size(geometry_nodes,1),1)).^2,2)));
                    sensors_aux = [sensors_aux ; i 0 1 0];

                end

            % Point-like CEM: outer radius 0, inner flag 1 → nearest
            % surface vertex (one row [id, node_index, 1, 0]).
            elseif sensors(i,4) == 0 && sensors(i,5) == 1

                if isequal(attach_type,'mesh')

                    [min_val, min_ind] = min(sqrt(sum((ele_nodes - repmat(sensors(i,1:3),size(ele_nodes,1),1)).^2,2)));
                    min_ind = unique_surface_triangles(min_ind);
                    sensors_aux = [sensors_aux ; i min_ind 1 0];

                end

                if isequal(attach_type,'geometry')

                    [min_val, min_ind] = min(sqrt(sum((geometry_nodes - repmat(sensors(i,1:3),size(geometry_nodes,1),1)).^2,2)));
                    sensors_aux = [sensors_aux ; i min_ind 1 0];

                end

            else

                % Annular CEM patch: snap the centre to the nearest surface
                % vertex, then keep triangles whose centroid distance d
                % satisfies inner (col5) ≤ d < outer (col4). Each kept
                % triangle becomes one [id n1 n2 n3] row.
                if isequal(attach_type,'mesh')

                    [min_val, min_ind] = min(sqrt(sum((ele_nodes - repmat(sensors(i,1:3),size(ele_nodes,1),1)).^2,2)));
                    sensors(i,1:3) = ele_nodes(min_ind,:);
                    [dist_val] = (sqrt(sum((center_points_aux - repmat(sensors(i,1:3),size(center_points_aux,1),1)).^2,2)));
                    dist_ind = find(dist_val < sensors(i,4) & dist_val >= sensors(i,5));
                    sensors_aux = [sensors_aux ; i*ones(length(dist_ind),1) zef.surface_triangles{end-electrode_surface_index+1}(dist_ind,:)];

                elseif isequal(attach_type,'geometry')

                    [min_val, min_ind] = min(sqrt(sum((geometry_nodes - repmat(sensors(i,1:3),size(geometry_nodes,1),1)).^2,2)));
                    sensors(i,1:3) = geometry_nodes(min_ind,:);
                    [dist_val] = (sqrt(sum((geometry_center_points_aux - repmat(sensors(i,1:3),size(geometry_center_points_aux,1),1)).^2,2)));
                    dist_ind = find(dist_val < sensors(i,4) & dist_val >= sensors(i,5));
                    sensors_aux = [sensors_aux ; i*ones(length(dist_ind),1) geometry_triangles(dist_ind,:)];

                end
            end
            end
        end

        sensors_attached_volume = sensors_aux;

    end

else
    sensors_attached_volume = [];
end

sensors_attached_volume = gather(sensors_attached_volume);

if nargout == 0
    assignin('base','zef_data',struct('sensors_attached_volume',sensors_attached_volume));
    eval('zef_assign_data;');
end

end
