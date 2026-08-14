function [nodes, nodes_b, tetra, johtavuus_ind, surface_triangles,name_tags] = zef_fem_mesh(void)
%ZEF_FEM_MESH  Legacy 6-tet lattice builder (not on the current Mesh-tool path).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef from the *base* workspace (the dummy argument void is ignored
%   and immediately set to []). Fills the bounding box of the last reuna_p
%   surface with a uniform meshgrid at zef.mesh_resolution, splits every
%   cube into six tetrahedra (one stencil, no parity flip), labels nodes
%   with zef_tetra_in_compartment, keeps tets whose eight cube corners all
%   sit inside some compartment, and resolves overlapping labels by
%   minimum compartment priority.
%
%   The live pipeline is zef_create_fem_mesh (5- or 6-tet mode, PML,
%   solid-angle labeling). This function is still in the tree but has no
%   first-party callers.
%
%   [nodes, nodes_b, tetra, johtavuus_ind, surface_triangles, name_tags] = zef_fem_mesh()
%
%   Inputs (from base zef, not function arguments)
%     mesh_resolution, reuna_p, reuna_t, sensors, compartment_tags, and
%     per-tag _on / _sigma / _priority / _submesh_ind / _name.
%     zef.mesh_labeling_approach == 2 uses the 4-node tet corners for the
%     label vote instead of the 8 cube corners.
%
%   Outputs
%     nodes              - V×3 lattice vertices that remain after dropping
%                          exterior tets, same frame/unit as reuna_p.
%     nodes_b            - copy of nodes (legacy alias).
%     tetra              - T×4 1-based indices, 6 tets per kept cube.
%     johtavuus_ind      - T×1 winning compartment index (priority min).
%     surface_triangles  - boundary faces of the tet mesh, winding [1 3 2].
%     name_tags          - 1×C cell of active compartment names.
%
%   See also zef_create_fem_mesh, zef_hexa_to_tetra, zef_tetra_in_compartment.

void = [];

h = zef_waitbar(0,1,'Initial mesh.');

mesh_res = evalin('base','zef.mesh_resolution');
reuna_p = evalin('base','zef.reuna_p');
reuna_t = evalin('base','zef.reuna_t');
sensors = evalin('base','zef.sensors');

i = 0;
sigma_vec = [];
priority_vec = [];
submesh_cell = cell(0);
compartment_tags = evalin('base','zef.compartment_tags');

for k = 1 : length(compartment_tags)

    var_0 = ['zef.' compartment_tags{k} '_on'];
    var_1 = ['zef.' compartment_tags{k} '_sigma'];
    var_2 = ['zef.' compartment_tags{k} '_priority'];
    var_3 = ['zef.' compartment_tags{k} '_submesh_ind'];
    var_4 = ['zef.' compartment_tags{k} '_name'];

    on_val = evalin('base',var_0);
    sigma_val = evalin('base',var_1);
    priority_val = evalin('base',var_2);

    if on_val
        i = i + 1;

        sigma_vec(i,1) = sigma_val;
        priority_vec(i,1) = priority_val;
        submesh_cell{i} = evalin('base',var_3);
        name_tags{i} = evalin('base',var_4);

    end
end

n_compartments = 0;
for k = 1 : length(reuna_p)
    n_compartments = n_compartments + max(1,length(submesh_cell{k}));
end

priority_vec_aux = zeros(n_compartments,1);
compartment_counter = 0;
submesh_ind_1 = ones(n_compartments,1);
submesh_ind_2 = ones(n_compartments,1);

for i = 1 :  length(reuna_p)

    for k = 1 : max(1,length(submesh_cell{i}))

        compartment_counter = compartment_counter + 1;
        priority_vec_aux(compartment_counter) = priority_vec(i);
        submesh_ind_1(compartment_counter) = i;
        submesh_ind_2(compartment_counter) = k;

    end
end

n_compartments = 0;
for k = 1 : length(reuna_p)
    n_compartments = n_compartments + max(1,length(submesh_cell{k}));
end

x_lim = [min(reuna_p{end}(:,1)) max(reuna_p{end}(:,1))];
y_lim = [min(reuna_p{end}(:,2)) max(reuna_p{end}(:,2))];
z_lim = [min(reuna_p{end}(:,3)) max(reuna_p{end}(:,3))];

% Uniform Cartesian lattice from the last (typically outermost) surface only.
x_vec = [x_lim(1):mesh_res:x_lim(2)];
y_vec = [y_lim(1):mesh_res:y_lim(2)];
z_vec = [z_lim(1):mesh_res:z_lim(2)];

[X, Y, Z] = meshgrid(x_vec,y_vec,z_vec);

size_xyz = size(X);

n_cubes = (length(x_vec)-1)*(length(y_vec)-1)*(length(z_vec)-1);

% Six tets per cube (same local stencil as zef_hexa_to_tetra).
ind_mat_1 = [     3     4     1     7 ;
    2     3     1     7 ;
    1     2     7     6 ;
    7     1     6     5 ;
    7     4     1     8 ;
    7     8     1     5  ];

tetra = zeros(6*n_cubes,4);
johtavuus_ind = zeros(6*n_cubes,8);
johtavuus_ind_2 = zeros(6*n_cubes,4);
i = 1;

for i_x = 1 : length(x_vec) - 1
    zef_waitbar(i_x,(length(x_vec)-1),h,'Initial mesh.');
    for i_y = 1 : length(y_vec) - 1
        for i_z = 1 : length(z_vec) - 1

            x_ind = [i_x i_x+1 i_x+1 i_x i_x i_x+1 i_x+1 i_x]';
            y_ind = [i_y i_y i_y+1 i_y+1 i_y i_y i_y+1 i_y+1]';
            z_ind = [i_z i_z i_z i_z i_z+1 i_z+1 i_z+1 i_z+1]';
            ind_mat_2 = sub2ind(size_xyz,y_ind,x_ind,z_ind);

            tetra(i:i+5,:) = ind_mat_2(ind_mat_1);
            johtavuus_ind(i:i+5,:) = ind_mat_2(:,ones(6,1))';
            johtavuus_ind_2(i:i+5,:) = ind_mat_2(ind_mat_1);
            i = i + 6;

        end
    end
end

johtavuus_ind = uint32(johtavuus_ind);
johtavuus_ind_2 = uint32(johtavuus_ind_2);
nodes = [X(:) Y(:) Z(:)];
clear X Y Z;

I = zeros(size(nodes,1), 1);
I_2 = [1 : length(I)]';

compartment_counter = 0;
sigma_counter = 0;

for i = 1 : length(reuna_p)

    for k = 1 : max(1,length(submesh_cell{i}))

        compartment_counter = compartment_counter + 1;

        if isempty(submesh_cell{i})
            reuna_t_aux = reuna_t{i};
        else
            if k == 1
                reuna_t_aux = reuna_t{i}(1:submesh_cell{i},:);
            else
                reuna_t_aux = reuna_t{i}(submesh_cell{i}(k-1)+1: submesh_cell{i}(k),:);
            end
        end

        I_1 = zef_tetra_in_compartment(reuna_p{i},reuna_t_aux,nodes(I_2,:),[compartment_counter n_compartments]);
        I(I_2(I_1)) = compartment_counter;
        I_2 = find(I==0);

    end
end

% Keep cubes whose eight corners all have a nonzero compartment label.
I_1 = find(sum(sign(I(johtavuus_ind)),2)==8);
tetra = tetra(I_1,:);
johtavuus_ind = johtavuus_ind(I_1,:);
johtavuus_ind = I(johtavuus_ind);

johtavuus_ind_2 = johtavuus_ind_2(I_1,:);
johtavuus_ind_2 = I(johtavuus_ind_2);

I_1 = unique(tetra);
nodes = nodes(I_1,:);
I_2 = zeros(size(nodes,1),1);
I_2(I_1) = [1 : length(I_1)];
tetra = I_2(tetra);

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

tetra_sort = [tetra(:,[2 4 3]) ones(size(tetra,1),1) [1:size(tetra,1)]';
    tetra(:,[1 3 4]) 2*ones(size(tetra,1),1) [1:size(tetra,1)]';
    tetra(:,[1 4 2]) 3*ones(size(tetra,1),1) [1:size(tetra,1)]';
    tetra(:,[1 2 3]) 4*ones(size(tetra,1),1) [1:size(tetra,1)]';];
tetra_sort(:,1:3) = sort(tetra_sort(:,1:3),2);
tetra_sort = sortrows(tetra_sort,[1 2 3]);
tetra_ind = zeros(size(tetra_sort,1),1);
I = find(sum(abs(tetra_sort(2:end,1:3)-tetra_sort(1:end-1,1:3)),2)==0);
tetra_ind(I) = 1;
tetra_ind(I+1) = 1;
I = find(tetra_ind == 0);
tetra_ind = sub2ind(size(tetra),repmat(tetra_sort(I,5),1,3),ind_m(tetra_sort(I,4),:));
surface_triangles = tetra(tetra_ind);
surface_triangles = surface_triangles(:,[1 3 2]);

nodes_b = nodes;

if isequal(evalin('base','zef.mesh_labeling_approach'),2)
    johtavuus_ind = johtavuus_ind_2;
end

[priority_val priority_ind] = min(priority_vec_aux(johtavuus_ind),[],2);
priority_ind = sub2ind(size(johtavuus_ind),[1:size(johtavuus_ind,1)]',priority_ind);
[johtavuus_ind] = johtavuus_ind(priority_ind);

close(h);

end
