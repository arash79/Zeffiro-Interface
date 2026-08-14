function zef = zef_postprocess_fem_mesh(zef)
%ZEF_POSTPROCESS_FEM_MESH  Smooth, optionally re-refine, and index a volume mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Runs after zef_create_fem_mesh. It does not rebuild the lattice. It
%   (1) Laplacian-smooths nodes if zef.mesh_smoothing_on (script
%   zef_smoothing_step, which may also inflate FEM surfaces toward the
%   segmentation), (2) optional second-pass surface/volume refinement
%   using the *_2 Mesh-tool flags, (3) flips inverted tets then
%   zef_tetra_turn, (4) maps subdomain labels back to compartment
%   indices, (5) optionally strips the outer box, (6) extracts per-
%   compartment surface triangles, and (7) writes source-region index
%   lists and zef.sigma (and other Segmentation/Scalar parameters).
%
%   Callers
%     zef_create_finite_element_mesh (always, after create_fem_mesh)
%     zef_postprocess_finite_element_mesh (Mesh tool **Postprocess FEM mesh**)
%
%   GUI: Mesh tool **Postprocess FEM mesh** → zef_postprocess_finite_element_mesh
%   then zef_update (verified ButtonPushedFcn on zef.h_pushbutton34).
%   The same window's **Mesh smoothing** checkbox is zef.mesh_smoothing_on.
%   Second-pass refinement uses zef.refinement_surface_on_2 /
%   refinement_volume_on_2, not the flags create_fem_mesh already used.
%
%   zef = zef_postprocess_fem_mesh(zef)
%
%   Input
%     zef  - session with nodes (V×3), tetra (T×4), domain_labels_with_subdomains
%            (T×1 subdomain IDs), reuna_p, reuna_submesh_ind, reuna_distance_vec,
%            compartment_tags, parameter_profile. If omitted or empty, read
%            from base.
%
%   Fields written
%     nodes, tetra                     - possibly smoothed / reindexed (V×3, T×4)
%     domain_labels                    - T×1 compartment index (not subdomain)
%     domain_labels_with_subdomains    - T×1 finer IDs used during refinement
%     brain_ind, active_compartment_ind
%         - indices of tets in source-capable compartments (_sources in {1,2})
%     non_source_ind  - tets that touch the outer surface in more than 2 vertices
%     surface_triangles - cell, one triangle list per unique domain label:
%                         faces of the union of tets with domain_labels <= that id
%     submesh_ind     - subdomain index of each active tet
%     condition_number - from zef_condition_number (quality diagnostic)
%     reuna_distance_vec
%     zef.<param>     - for each parameter_profile row that is Segmentation /
%                       Scalar / On: [value_at_tet, domain_label] (includes
%                       sigma when that profile row is enabled)
%
%   Side effects
%     Waitbar. If nargout==0, assignin('base','zef',zef).
%
%   See also zef_create_fem_mesh, zef_tetra_turn, zef_mesh_refinement,
%            zef_smoothing_step, zef_postprocess_finite_element_mesh.

if nargin==0
    zef = evalin('base','zef');
end

if isempty(zef)
    zef = evalin('base','zef');
end

h = zef_waitbar(0,1,'Mesh post-processing');

% Profile rows that are Segmentation / Scalar / On become per-compartment vectors.
parameter_profile = eval('zef.parameter_profile');

for zef_j = 1 : size(parameter_profile,1)
    if isequal(parameter_profile{zef_j,8},'Segmentation') && isequal(parameter_profile{zef_j,3},'Scalar') && isequal(parameter_profile{zef_j,6},'On')
        eval([parameter_profile{zef_j,2} '_vec = [];']);
    end
end

tetra = [];
prisms = [];
sigma_prisms = [];
non_source_ind = [];
optimizer_flag = 1;

thresh_val = eval('zef.mesh_optimization_parameter');
compartment_tags = eval('zef.compartment_tags');
aux_compartment_ind = zeros(1,length(compartment_tags));

sigma = [];
i = 0;
length_reuna = 0;
sigma_vec = [];
priority_vec = [];
pml_vec = [];
aux_active_compartment_ind = [];
submesh_cell = zef.reuna_submesh_ind;
distance_vec = zef.reuna_distance_vec;

for k = 1 : length(compartment_tags)

    var_0 = ['zef.'  compartment_tags{k} '_on'];
    var_1 = ['zef.' compartment_tags{k} '_sigma'];
    var_2 = ['zef.' compartment_tags{k} '_priority'];
    var_3 = ['zef.' compartment_tags{k} '_submesh_ind'];
    var_4 = ['zef.' compartment_tags{k} '_sources'];

    on_val = eval(var_0);
    sigma_val = eval(var_1);
    priority_val = eval(var_2);
    if on_val
        i = i + 1;

        for zef_j = 1 : size(parameter_profile,1)
            if isequal(parameter_profile{zef_j,8},'Segmentation') && isequal(parameter_profile{zef_j,3},'Scalar') && isequal(parameter_profile{zef_j,6},'On')
                eval([parameter_profile{zef_j,2} '_vec(' num2str(i) ',1) =' num2str(eval(['zef.' compartment_tags{k} '_' parameter_profile{zef_j,2}])) ';']);
            end
        end

        sigma_vec(i,1) = sigma_val;
        priority_vec(i,1) = priority_val;
        aux_compartment_ind(k) = i;
        if not(isequal(eval(var_4),-1))
            pml_vec(i,1) = 0 ;
        else
            pml_vec(i,1) = 1;
        end
        if ismember(eval(var_4),[1 2])
            aux_active_compartment_ind(i,1) = 1 ;
        end

    end
end

pml_ind_aux = find(pml_vec,1);


n_compartments = 0;
for k = 1 : length(zef.reuna_p)
    n_compartments = n_compartments + max(1,length(submesh_cell{k}));
end

priority_vec_aux = zeros(n_compartments,1);
compartment_counter = 0;
submesh_ind_1 = ones(n_compartments,1);
submesh_ind_2 = ones(n_compartments,1);

for i = 1 : length(zef.reuna_p)
    for k = 1 : max(1,length(submesh_cell{i}))

        compartment_counter = compartment_counter + 1;
        priority_vec_aux(compartment_counter) = priority_vec(i);
        submesh_ind_1(compartment_counter) = i;
        submesh_ind_2(compartment_counter) = k;

    end
end

domain_labels = double(zef.domain_labels_with_subdomains);
% [priority_val, priority_ind] = min(priority_vec_aux(domain_labels),[],2);
% priority_ind = sub2ind(size(domain_labels),[1:size(domain_labels,1)]',priority_ind);

nodes = zef.nodes;
tetra_aux = zef.tetra;
tetra = tetra_aux;
N = size(nodes, 1);

% Script: Laplacian smooth of surface/volume nodes when mesh_smoothing_on.
zef_smoothing_step;

% refinement_flag 2 is the convention zef_refinement_step uses in this pass.
refinement_flag = 2;

surface_refinement_on = eval('zef.refinement_surface_on_2');
n_surface_refinement = eval('zef.refinement_surface_number_2');

if surface_refinement_on

    if length(n_surface_refinement) == 1

        for i_surface_refinement = 1 : n_surface_refinement

            zef_refinement_step;

        end

    else

        for j_surface_refinement = 1 : length(n_surface_refinement)
            for i_surface_refinement = 1 : n_surface_refinement(j_surface_refinement)

                zef_refinement_step;


            end
        end

    end
end


if eval('zef.refinement_volume_on_2');
    zef_waitbar(0,1,h,'Volume refinement.');
    n_refinement = zef.refinement_volume_number_2;
    refinement_compartments_aux = zef.refinement_volume_compartments_2;

    refinement_compartments = [];
    if ismember(-1,refinement_compartments_aux)
    [~, refinement_compartments] = zef_find_active_compartment_ind(zef,submesh_ind_1(zef.domain_labels));
    refinement_compartments = zef_compartment_to_subcompartment(zef,refinement_compartments);
    refinement_compartments = refinement_compartments(:);
    end

    refinement_compartments_aux = zef_compartment_to_subcompartment(zef,setdiff(refinement_compartments_aux,-1));
    refinement_compartments = [refinement_compartments ; refinement_compartments_aux(:)];

    for i = 1 : n_refinement

        [nodes,tetra,domain_labels,distance_vec] = zef_mesh_refinement(zef,nodes,tetra,domain_labels,distance_vec,refinement_compartments);
        zef_waitbar(i,n_refinement,h,'Volume refinement.');

    end

    % Interior tets of the inner union that expose ≥3 faces are relabelled
    % to the outermost domain (fills holes left by the split).
    max_domain_labels = max(domain_labels);
    I_5 = 0;
    while not(isempty(I_5))
        I_3 = find(domain_labels<max_domain_labels);
        [~,~,I_4] = zef_surface_mesh(tetra(I_3,:));
        I_4 = accumarray(I_4,ones(size(I_4)),[size(I_3,1) 1]);
        I_4 = find(I_4 < 3);
        I_5 = setdiff([1:size(I_3,1)]',I_4);
        domain_labels(I_3(I_5)) = max_domain_labels;
    end

end

% Invert-then-flip: fix_negatives moves nodes; tetra_turn swaps shared faces.
[nodes,optimizer_flag] = zef_fix_negatives(zef,nodes, tetra);
if optimizer_flag == 1
    [tetra, optimizer_flag] = zef_tetra_turn(zef,nodes, tetra, thresh_val);
end

domain_labels_with_subdomains = domain_labels;
%[priority_val, priority_ind] = min(priority_vec_aux(domain_labels),[],2);
%priority_ind = sub2ind(size(domain_labels),[1:size(domain_labels,1)]',priority_ind);
%[domain_labels] = submesh_ind_1(domain_labels(priority_ind));
[domain_labels] = submesh_ind_1(domain_labels);
active_compartment_ind = zef_find_active_compartment_ind(zef,domain_labels);

if eval('zef.exclude_box')
    % Drop the outermost domain (largest label), usually the PML/air box.
   %I = find(not(ismember(domain_labels,find(pml_vec,1))));
I = find(not(ismember(domain_labels,max(domain_labels,[],'all'))));
    I_2 = zeros(size(tetra,1),1);
    I_2(I) = [1:length(I)];
    active_compartment_ind = I_2(active_compartment_ind);
    active_compartment_ind = active_compartment_ind(find(active_compartment_ind));
    domain_labels = domain_labels(I,:);
    domain_labels_with_subdomains = domain_labels_with_subdomains(I,:);
    [unique_vec_1, ~, unique_vec_3] = unique(tetra(I,:));
    tetra = reshape(unique_vec_3,length(I),4);
    nodes = nodes(unique_vec_1,:);
end

zef_waitbar(0,1,h,'Surface triangles.');
unique_domain_labels = unique(domain_labels);
n_unique_domain_labels = length(unique_domain_labels);
surface_triangles = cell(0);
for zef_j = 1 : n_unique_domain_labels
    zef_waitbar(zef_j,n_unique_domain_labels,h,'Surface triangles.');
I_aux = find(domain_labels <= unique_domain_labels(zef_j));
surface_triangles{unique_domain_labels(zef_j)} = double(zef_surface_mesh(tetra(I_aux,:)));
end

for zef_j = 1 : size(parameter_profile,1)
    if isequal(parameter_profile{zef_j,8},'Segmentation') && isequal(parameter_profile{zef_j,3},'Scalar') && isequal(parameter_profile{zef_j,6},'On')
        eval([parameter_profile{zef_j,2} '=[' parameter_profile{zef_j,2} '_vec(domain_labels) domain_labels];']);
    end
end

% Tets with more than two vertices on the global outer skin cannot hold sources.
J = unique(zef_surface_mesh(tetra));
tetra_vec = sum(ismember(tetra,J),2);
non_source_ind = find(tetra_vec > 2);
clear tetra_vec;

condition_number = zef_condition_number(nodes,tetra);
[submesh_ind] = zef_find_subdomain_ind(domain_labels, domain_labels_with_subdomains);
submesh_ind = submesh_ind(active_compartment_ind);

close(h);

zef.domain_labels_with_subdomains = double(domain_labels_with_subdomains);
zef.domain_labels = double(domain_labels);
zef.brain_ind = double(active_compartment_ind);
zef.active_compartment_ind = double(active_compartment_ind);
zef.non_source_ind = double(non_source_ind);
zef.nodes = nodes;
zef.tetra = double(tetra);
zef.surface_triangles = surface_triangles;
zef.submesh_ind = double(submesh_ind);
zef.condition_number = condition_number;
zef.reuna_distance_vec = distance_vec;

for zef_j = 1 : size(parameter_profile,1)
    if isequal(parameter_profile{zef_j,8},'Segmentation') && isequal(parameter_profile{zef_j,3},'Scalar') && isequal(parameter_profile{zef_j,6},'On')
        eval(['zef.' parameter_profile{zef_j,2} '=' parameter_profile{zef_j,2} ';']);
    end
end

if nargout == 0
    assignin('base','zef',zef);
end

end
