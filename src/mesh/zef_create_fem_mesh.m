function zef = zef_create_fem_mesh(zef)
%ZEF_CREATE_FEM_MESH  Build a labeled tetrahedral volume from compartment surfaces.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   This is the volume-mesh builder. It does not import surfaces: those
%   must already sit on zef.reuna_p / zef.reuna_t from zef_process_meshes.
%   The GUI button "Create FEM mesh" does not call this function directly;
%   it runs zef_create_finite_element_mesh, which optionally downsamples
%   surfaces, then process_meshes, then this function, then postprocess.
%
%   Pipeline
%     1. zef_segmentation_counter_step (script) injects mesh_res, reuna_type,
%        pml_ind_aux, submesh_cell, aux_active_compartment_ind, name_tags.
%        A compartment with <tag>_sources == -1 is treated as PML.
%     2. Axis-aligned bounding box of all non-PML surfaces. Regular grid
%        with spacing mesh_res, or zef_pml_mesh if a PML compartment exists.
%     3. Split each cube into 5 tets (initial_mesh_mode 1, parity-dependent
%        stencils so faces match) or 6 tets (mode 2, one stencil).
%     4. zef_mesh_labeling_step assigns tissue IDs by solid-angle tests
%        against the surfaces and drops exterior tetrahedra.
%     5. Optional surface, volume, and adaptive refinement, each followed
%        by relabeling when zef.mesh_relabeling is true.
%
%   GUI: Mesh tool → Create FEM mesh (wrapper) or Postprocess FEM mesh
%   (zef_postprocess_finite_element_mesh). Mesh resolution, refinement,
%   and smoothing checkboxes are on the same window.
%
%   zef = zef_create_fem_mesh(zef)
%
%   Input / output
%     zef  - session struct. If omitted, read from the base workspace.
%            If nargout is 0, assigned back to base.
%
%   Fields written
%     nodes, tetra, domain_labels, name_tags, domain_labels_with_subdomains,
%     reuna_distance_vec.
%
%   See also zef_create_finite_element_mesh, zef_process_meshes,
%            zef_postprocess_fem_mesh, zef_mesh_refinement, zef_pml_mesh.

if nargin == 0
    zef = evalin('base','zef');
end

% Script: writes mesh_res, reuna_type, pml_ind_aux, submesh_cell, name_tags,
% aux_active_compartment_ind into this workspace (not as zef fields).
zef_segmentation_counter_step;

% Bounding box of non-PML surfaces (reuna_type == -1 is skipped).
x_lim = [0 0];
y_lim = [0 0];
z_lim = [0 0];
n_compartments = 0;
for k = 1 : length(zef.reuna_p)
    n_compartments = n_compartments + max(1,length(submesh_cell{k}));

    if not(isequal(reuna_type{k},-1))
        x_lim = [min(x_lim(1),min(zef.reuna_p{k}(:,1))) max(x_lim(2),max(zef.reuna_p{k}(:,1)))];
        y_lim = [min(y_lim(1),min(zef.reuna_p{k}(:,2))) max(y_lim(2),max(zef.reuna_p{k}(:,2)))];
        z_lim = [min(z_lim(1),min(zef.reuna_p{k}(:,3))) max(z_lim(2),max(zef.reuna_p{k}(:,3)))];
    end
end

if isempty(pml_ind_aux)
    % Uniform Cartesian lattice with spacing mesh_res (Mesh tool "Mesh resolution").
    x_vec = [x_lim(1):mesh_res:x_lim(2)];
    y_vec = [y_lim(1):mesh_res:y_lim(2)];
    z_vec = [z_lim(1):mesh_res:z_lim(2)];
    [X, Y, Z] = meshgrid(x_vec,y_vec,z_vec);
    n_cubes = (length(x_vec)-1)*(length(y_vec)-1)*(length(z_vec)-1);
else

    % PML: grow a graded outer lattice beyond the inner bounding radius.
    % pml_outer_radius_unit / pml_max_size_unit == 1 means "relative to
    % inner radius / mesh_res"; otherwise the stored values are absolute.
    pml_inner_radius = max(abs([x_lim(:); y_lim(:); z_lim(:)]));
    pml_outer_radius_unit = eval('zef.pml_outer_radius_unit');
    pml_outer_radius = eval('zef.pml_outer_radius');
    pml_max_size_unit = eval('zef.pml_max_size_unit');
    pml_max_size = eval('zef.pml_max_size');

    if isequal(pml_outer_radius_unit,1)
        pml_outer_radius = pml_inner_radius*pml_outer_radius;
    end

    if isequal(pml_max_size_unit,1)
        pml_max_size = mesh_res*pml_max_size;
    end

    [X, Y, Z, pml_ind] = zef_pml_mesh(pml_inner_radius,pml_outer_radius,mesh_res,pml_max_size);
    n_cubes = prod(size(X)-1);
end

size_xyz = size(X);

h = zef_waitbar(0,1,'Initial mesh.');

%************************************************************

% Vectorized cube→tet fill. Loop order is i_x (slowest), i_y, i_z (fastest),
% matching the historical nested loops so tetra row order is unchanged.
% Corner numbering is 1–4 bottom, 5–8 top. ndgrid(1:n_z,1:n_y,1:n_x)
% produces that same linear cube order.

nodes = [X(:) Y(:) Z(:)];
n_x = size_xyz(2) - 1;
n_y = size_xyz(1) - 1;
n_z = size_xyz(3) - 1;
[i_z, i_y, i_x] = ndgrid(1:n_z, 1:n_y, 1:n_x);
ix = i_x(:);
iy = i_y(:);
iz = i_z(:);
cx = [0 1 1 0 0 1 1 0];
cy = [0 0 1 1 0 0 1 1];
cz = [0 0 0 0 1 1 1 1];
ind_mat_2 = sub2ind(size_xyz, iy + cy, ix + cx, iz + cz);
mesh_labeling_approach = eval('zef.mesh_labeling_approach');

if isequal(eval('zef.initial_mesh_mode'),1)

    % Five tets per cube. Stencil depends on (i_x,i_y,i_z) parity so
    % neighbouring cubes share the same diagonal on a common face.
    ind_mat_1{1}{2}{1} = [2 5 6 7; 7 5 4 2;  2 3 4 7; 1 2 4 5 ; 4 7 8 5];
    ind_mat_1{1}{2}{2} = [6 2 1 3; 1 3 8 6; 8 7 6 3;  5 8 6 1; 3 8 4 1 ];
    ind_mat_1{2}{2}{2} = [5 2 1 4; 4 2 7 5; 5 8 7 4;  5 7 6 2;  3 7 4 2];
    ind_mat_1{2}{2}{1} = [1 5 6 8; 6 8 3 1; 3 4 1 8; 2 3 1 6 ; 3 7 8 6  ];
    ind_mat_1{1}{1}{2} = [4 3 7 2; 2 7 4 5;  5 7 6 2; 1 5 2 4;  8 7 5 4 ];
    ind_mat_1{2}{1}{2} = [3 6 8 1; 1 3 4 8; 5 8 6 1; 1 6 2 3  ; 8 7 6 3  ];
    ind_mat_1{1}{1}{1} = [7 8 3 6; 8 1 3 6; 2 3 1 6;  1 5 6 8 ; 1 3 4 8   ];
    ind_mat_1{2}{1}{1} = [ 7 8 4 5; 5 4 7 2;  2 4 1 5; 2 5 6 7   ;  2 3 4 7 ];

    S = zeros(5, 4, 2, 2, 2);
    for px = 1:2
        for py = 1:2
            for pz = 1:2
                S(:,:,px,py,pz) = ind_mat_1{px}{py}{pz};
            end
        end
    end
    px = 2 - mod(ix, 2);
    py = 2 - mod(iy, 2);
    pz = 2 - mod(iz, 2);
    lin_s = sub2ind([2 2 2], px, py, pz);
    Sflat = reshape(S, 5, 4, 8);
    col_idx = reshape(permute(Sflat(:,:,lin_s), [2 1 3]), 20, n_cubes)';
    gathered = ind_mat_2((1:n_cubes)' + (col_idx - 1) * n_cubes);
    tetra = reshape(gathered', 4, [])';
    if isequal(mesh_labeling_approach, 1)
        label_ind = repelem(ind_mat_2, 5, 1);
    elseif isequal(mesh_labeling_approach, 2)
        label_ind = tetra;
    end

    %************************************************************

elseif isequal(eval('zef.initial_mesh_mode'),2)

    % Six tets per cube; one stencil for every cube (no parity flip).
    ind_mat_1 = [     3     4     1     7 ;
        2     3     1     7 ;
        1     2     7     6 ;
        7     1     6     5 ;
        7     4     1     8 ;
        7     8     1     5  ];

    col_idx = repmat(reshape(ind_mat_1', 1, 24), n_cubes, 1);
    gathered = ind_mat_2((1:n_cubes)' + (col_idx - 1) * n_cubes);
    tetra = reshape(gathered', 4, [])';
    if isequal(mesh_labeling_approach, 1)
        label_ind = repelem(ind_mat_2, 6, 1);
    elseif isequal(mesh_labeling_approach, 2)
        label_ind = tetra;
    end

end

zef_waitbar(1,1,h,'Initial mesh.');

%************************************************************

clear X Y Z;

% Labeling and later refinement use parfor when GPU is off. Size a PCT
% pool to zef.parallel_processes when Parallel Computing Toolbox is present.
% Without it, parfor in zef_point_in_compartment runs sequentially.
if not(zef.use_gpu)
    zef_ensure_parpool(zef.parallel_processes);
end

refinement_surface_on = zef.refinement_surface_on;
n_surface_refinement = zef.refinement_surface_number;
refinement_surface_compartments = zef.refinement_surface_compartments;
refinement_volume_on = zef.refinement_volume_on;
n_volume_refinement = zef.refinement_volume_number;
refinement_volume_compartments = zef.refinement_volume_compartments;

refinement_flag = 1;

% labeling_flag 1 = initial solid-angle labeling (drops exterior tets).
labeling_flag = 1;
zef_mesh_labeling_step;

refinement_compartments_aux = refinement_surface_compartments;

refinement_compartments = [];
if ismember(-1,refinement_compartments_aux)
    refinement_compartments = aux_active_compartment_ind(:);
end

refinement_compartments_aux = setdiff(refinement_compartments_aux,-1);
refinement_compartments = [refinement_compartments ; refinement_compartments_aux(:)];

if eval('zef.refinement_on')

    % Surface refinement: zef_refinement_step (script) splits tets that
    % meet selected compartment surfaces. -1 means all source compartments.
    if refinement_surface_on
        if length(n_surface_refinement) == 1

            for i_surface_refinement = 1 : n_surface_refinement

                zef_refinement_step;

                if eval('zef.mesh_relabeling')

                    pml_ind = [];
                    label_ind = uint32(tetra);
                    labeling_flag = 2;
                    zef_mesh_labeling_step;

                end
            end

        else

            for j_surface_refinement = 1 : length(n_surface_refinement)
                for i_surface_refinement = 1 : n_surface_refinement(j_surface_refinement)

                    zef_refinement_step;

                    if eval('zef.mesh_relabeling')
                        pml_ind = [];
                        label_ind = uint32(tetra);
                        labeling_flag = 2;
                        zef_mesh_labeling_step;

                    end
                end
            end
        end

else

    if eval('zef.mesh_relabeling')
    pml_ind = [];
    label_ind = uint32(tetra);
    labeling_flag = 2;
    zef_mesh_labeling_step;

    end

end

if eval('zef.refinement_on')
    if refinement_volume_on

        % Uniform 4-to-1 splits of tets whose domain_labels match the
        % selected compartments (again -1 = all source compartments).
        n_refinement = n_volume_refinement;
        refinement_compartments_aux = refinement_volume_compartments;

        refinement_compartments = [];
        if ismember(-1,refinement_compartments_aux)
            refinement_compartments = aux_active_compartment_ind(:);
        end

        refinement_compartments_aux = setdiff(refinement_compartments_aux,-1);
        refinement_compartments = [refinement_compartments ; refinement_compartments_aux(:)];

        if length(n_refinement) == 1

            zef_waitbar(0,1,h,'Volume refinement.');

            for i = 1 : n_refinement

                [nodes,tetra,domain_labels,distance_vec] = zef_mesh_refinement(zef,nodes,tetra,domain_labels,distance_vec,zef_compartment_to_subcompartment(zef,refinement_compartments));
                zef_waitbar(i,n_refinement,h,'Volume refinement.');

                if eval('zef.mesh_relabeling')

                    pml_ind = [];
                    label_ind = uint32(tetra);
                    labeling_flag = 2;
                    zef_mesh_labeling_step;


                end
            end

        else

            zef_waitbar(0,length(n_refinement),h,'Volume refinement.');

            for j = 1 : length(n_refinement)
                for i = 1 : n_refinement(j)

                    [nodes,tetra,domain_labels,distance_vec] = zef_mesh_refinement(zef,nodes,tetra,domain_labels,distance_vec,zef_compartment_to_subcompartment(zef,refinement_compartments(j)));

                    if eval('zef.mesh_relabeling')

                        pml_ind = [];
                        label_ind = uint32(tetra);
                        labeling_flag = 2;
                        zef_mesh_labeling_step;

                    end

                    zef_waitbar(i,length(n_refinement(j)),h,'Volume refinement.');

                end
            end

        end

    end

end

    %*********************
    % Adaptive: only split tets that zef_get_tetra_to_refine marks as
    % too far from the compartment surfaces (thresh_val, k_param).
    if eval('zef.adaptive_refinement_on')

        n_refinement = eval('zef.adaptive_refinement_number');
        refinement_compartments_aux = sort(eval('zef.adaptive_refinement_compartments'));

        refinement_compartments = [];
        if ismember(-1,refinement_compartments_aux)
            refinement_compartments = aux_active_compartment_ind(:);
        end

        refinement_compartments_aux = setdiff(refinement_compartments_aux,-1);
        refinement_compartments = [refinement_compartments ; refinement_compartments_aux(:)];

        if length(n_refinement) == 1

            zef_waitbar(0,1,h,'Adaptive volume refinement.');

            for i = 1 : n_refinement
                k_param = eval('zef.adaptive_refinement_k_param');
                thresh_val  = eval('zef.adaptive_refinement_thresh_val');
                tetra_refine_ind = zef_get_tetra_to_refine(refinement_compartments, thresh_val, k_param, nodes, tetra,domain_labels,zef.reuna_p,zef.reuna_t);
                [nodes,tetra,domain_labels,distance_vec,tetra_interp_vec] = zef_mesh_refinement(zef,nodes,tetra,domain_labels,distance_vec,zef_compartment_to_subcompartment(zef,refinement_compartments), tetra_refine_ind);
                tetra_refine_ind = find(ismember(tetra_interp_vec,tetra_refine_ind));
                zef_waitbar(i,n_refinement,h,'Adaptive volume refinement.');
                if eval('zef.mesh_relabeling')

                    pml_ind = [];
                    label_ind = uint32(tetra);
                    labeling_flag = 2;
                    zef_mesh_labeling_step;

                end
            end

        else

            zef_waitbar(0,length(n_refinement),h,'Adaptive volume refinement.');

            for j = 1 : length(n_refinement)
                for i = 1 : n_refinement(j)

                    k_param = eval('zef.adaptive_refinement_k_param');
                    thresh_val  = eval('zef.adaptive_refinement_thresh_val');
                    tetra_refine_ind = zef_get_tetra_to_refine(refinement_compartments(j), thresh_val, k_param, nodes, tetra,domain_labels,zef.reuna_p,zef.reuna_t);
                    [nodes,tetra,domain_labels,distance_vec,tetra_interp_vec] = zef_mesh_refinement(zef,nodes,tetra,domain_labels,distance_vec,zef_compartment_to_subcompartment(zef,refinement_compartments(j)),tetra_refine_ind);
                    tetra_refine_ind = find(ismember(tetra_interp_vec,tetra_refine_ind));

                    if eval('zef.mesh_relabeling')

                        pml_ind = [];
                        label_ind = uint32(tetra);
                        labeling_flag = 2;
                        zef_mesh_labeling_step;

                    end

                    zef_waitbar(i,length(n_refinement(j)),h,'Adaptive volume refinement.');

                end
            end

        end

    end
    %*********************

end

if isequal(zef.priority_mode,3)
    if zef.mesh_relabeling
    pml_ind = [];
    label_ind = uint32(tetra);
    labeling_flag = 3;
    zef_mesh_labeling_step;
    end
end


% Volume mesh consumed by postprocess (smoothing, sigma) and lead fields.
zef.nodes = nodes;
zef.tetra = double(tetra);
zef.domain_labels = double(domain_labels);
zef.name_tags = name_tags;
zef.domain_labels_with_subdomains = double(domain_labels);
zef.reuna_distance_vec = distance_vec;

zef_close_waitbar(h);

if nargout == 0
    assignin('base','zef',zef);
end

end
