function nodes = zef_inflate_surfaces(zef, nodes, tetra, domain_labels)
%ZEF_INFLATE_SURFACES  Snap interior FEM boundary nodes toward segmentation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each non-PML compartment, takes the skin of the union of tets with
%   domain_labels ≤ that compartment (zef_surface_mesh node_pair output)
%   and moves those FEM nodes along the interior edge toward the nearest
%   segmentation triangle. The intersection is a 3×3 barycentric solve
%   (zef_3by3_solver) against 25 k-nearest triangle centroids. The step
%   length is zef.fem_mesh_inflation_strength times the smallest |λ1|
%   among hits with λ1 in (−1,0) and λ2,λ3 in (0,1).
%
%   Called from zef_smoothing_step when that script inflates the volume
%   mesh, not from zef_downsample_surfaces (that uses zef_inflate_surface).
%
%   nodes = zef_inflate_surfaces(zef, nodes, tetra, domain_labels)
%
%   Inputs
%     zef            - session: fem_mesh_inflation_strength, reuna_p/t/type,
%                      parallel_processes, parallel_vectors. Empty → base.
%     nodes          - V×3 FEM vertices (updated in place).
%     tetra          - T×4.
%     domain_labels  - T×1 compartment (or subdomain) IDs aligned with tetra.
%
%   Output
%     nodes  - V×3. Vertices with no accepted intersection are unchanged.
%
%   Notes
%     The last reuna surface is skipped when it is a PML box (_sources==-1).
%     The loop over nodes is serial (nodes_cell is filled then written back);
%     parallel_processes only sizes the blocks. Waitbar is opened unless the
%     caller already has a valid h.
%
%   See also zef_inflate_surface, zef_surface_mesh, zef_3by3_solver.

if isempty(zef)
    zef = evalin('base','zef');
end

waitbar_opened = 0;
if evalin('caller','exist(''h'')')
    if evalin('caller','isvalid(h)')
        h = evalin('caller','h');
    else
        h = zef_waitbar([0 0], [1 1],'Inflating.');
        waitbar_opened = 1;
    end
else
    h = zef_waitbar([0 0], [1 1],'Inflating.');
    waitbar_opened = 1;
end

inflation_strength = eval('zef.fem_mesh_inflation_strength');
reuna_t = eval('zef.reuna_t');
reuna_p = eval('zef.reuna_p');
reuna_type = eval('zef.reuna_type');

if isequal(reuna_type{end,1},-1)
    compartment_length = length(reuna_p)-1;
else
    compartment_length = length(reuna_p);
end

for compartment_counter = 1 : compartment_length

    interior_ind = find(domain_labels<=compartment_counter);
    if not(isempty(interior_ind))
    % node_list(:,1) = boundary node, (:,2) = interior neighbour on the dual edge.
    [~,~,~,~,~,~,node_list] = zef_surface_mesh(tetra,[],interior_ind);

    if not(isempty(node_list))

        tri_ref = reuna_t{compartment_counter};
        nodes_tri_ref = reuna_p{compartment_counter};

        n_nearest_neighbors = 25;
        ones_vec_nearest = ones(n_nearest_neighbors,1);
        center_points = (1/3)*(nodes_tri_ref(tri_ref(:,1),:)+nodes_tri_ref(tri_ref(:,2),:)+nodes_tri_ref(tri_ref(:,3),:));
        n_nearest_neighbors = min(n_nearest_neighbors,size(center_points,1));
        MdlKDT = KDTreeSearcher(center_points);
        nearest_neighbor_ind = knnsearch(MdlKDT,gather(nodes(node_list(:,1),:)),'K',n_nearest_neighbors);

        zef_waitbar([0 compartment_counter], [1 length(reuna_p)], h, 'Inflating.');

        length_node_list = size(node_list,1);
        par_num = eval('zef.parallel_processes');
        vec_num = eval('zef.parallel_vectors');
        n_restarts = ceil(length_node_list/(vec_num*par_num));
        bar_ind = ceil(length_node_list/(50*par_num));
        i_ind = 0;

        sub_ind_aux_1 = round(linspace(1,length_node_list,n_restarts+1));

        tic;
        nodes_cell = cell(0);
        nodes_ind_cell = cell(0);
        for restart_ind = 1 : n_restarts

            sub_length = sub_ind_aux_1(restart_ind+1)-sub_ind_aux_1(restart_ind);
            par_size = ceil(sub_length/par_num);
            sub_cell_aux_1 = cell(0);
            sub_ind_aux_2 =  [1 : par_size : sub_length];
            nodes_cell_aux = cell(0);
            for j = 1 : length(sub_ind_aux_2)
                i = sub_ind_aux_2(j);
                block_ind = [i: min(i+par_size-1,sub_length)]+sub_ind_aux_1(restart_ind)-1;
                if isequal(block_ind(end),length_node_list-1)
                    block_ind = [block_ind block_ind(end)+1];
                end

                nodes_cell_aux{j} = zeros(length(block_ind),3);
                nodes_ind_cell_aux{j} = zeros(length(block_ind),1);

                for k = 1 : length(block_ind)

                    p_ind = node_list(block_ind(k),1);

                    I = [];
                    p = nodes(p_ind,:);

                    p_min = node_list(block_ind(k),2);
                    vec_1_aux = nodes(p_min,:) - p;

                    vec_1 = vec_1_aux(ones_vec_nearest,:);
                    d_vec = p(ones_vec_nearest,:)  - nodes_tri_ref(tri_ref(nearest_neighbor_ind(block_ind(k),:),1),:);
                    vec_2 = nodes_tri_ref(tri_ref(nearest_neighbor_ind(block_ind(k),:),2),:) - nodes_tri_ref(tri_ref(nearest_neighbor_ind(block_ind(k),:),1),:);
                    vec_3 = nodes_tri_ref(tri_ref(nearest_neighbor_ind(block_ind(k),:),3),:) - nodes_tri_ref(tri_ref(nearest_neighbor_ind(block_ind(k),:),1),:);

                    % Ray p + λ1*(p_min-p) vs triangle: λ1<0 means toward the interior neighbour.
                    [lambda_1, lambda_2, lambda_3] = zef_3by3_solver(vec_1,vec_2,vec_3,d_vec);
                    I = find(lambda_1<0 & lambda_1 > -1 & lambda_2 >0 & lambda_2<1 & lambda_3>0 & lambda_3 <1);

                    if not(isempty(I))

                        lambda_1 = inflation_strength*min(abs(lambda_1(I)));
                        nodes_cell_aux{j}(k,:) = p + lambda_1.*vec_1_aux;
                        nodes_ind_cell_aux{j}(k,:) = p_ind;

                    end
                end
            end

            nodes_cell{restart_ind} = nodes_cell_aux;
            nodes_ind_cell{restart_ind} = nodes_ind_cell_aux;

            time_val = toc;

            if isequal(mod(restart_ind,ceil(n_restarts/50)),0)
                zef_waitbar([restart_ind compartment_counter], [n_restarts length(reuna_p)],h,['Inflating compartment ' int2str(compartment_counter) ' of ' int2str(length(reuna_p)) '. Ready: ' datestr(datevec(now+(n_restarts/restart_ind - 1)*time_val/86400)) '.']);
            end

        end

        for restart_ind = 1 : n_restarts
            for i = 1 : length(nodes_cell{restart_ind})
                nodes_ind_aux = find(nodes_ind_cell{restart_ind}{i});
                nodes(nodes_ind_cell{restart_ind}{i}(nodes_ind_aux),:) = nodes_cell{restart_ind}{i}(nodes_ind_aux,:);
            end
        end

        %%%%%%%% CPU Version %%%%%%%%

    end
    end
end

if waitbar_opened
    close(h);
end

end
