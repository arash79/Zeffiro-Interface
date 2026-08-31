function [tetra, flag_val, nodes_ind] = zef_tetra_turn(zef, nodes, tetra, thresh_val)
%ZEF_TETRA_TURN  Face-swap poorly shaped tets with a neighbour.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Quality pass used by zef_postprocess_fem_mesh (and zef_smoothing_step).
%   Tets whose zef_condition_number is below thresh_val * max(condition)
%   are candidates. For each candidate the code looks at neighbours that
%   share exactly three vertices (a face), tries the three possible 2–2
%   reconnections of the two-tet polyhedron, and keeps the reconnection
%   with the smallest |1 − V1/V2| among those that produce two negative
%   volumes (the stored orientation convention). Loops up to
%   zef.mesh_optimization_repetitions times.
%
%   [tetra, flag_val, nodes_ind] = zef_tetra_turn(zef, nodes, tetra, thresh_val)
%
%   Inputs
%     zef         - session. Empty → evalin('base','zef'). Uses
%                   mesh_optimization_repetitions.
%     nodes       - V×3 (unchanged).
%     tetra       - T×4 1-based indices.
%     thresh_val  - fraction of max(condition_number). Postprocess passes
%                   zef.mesh_optimization_parameter.
%
%   Outputs
%     tetra      - T×4, possibly with swapped faces (same T).
%     flag_val   - 1 if every tet now meets the threshold, -1 otherwise.
%     nodes_ind  - unique vertices of tets that still fail the threshold.
%
%   See also zef_condition_number, zef_postprocess_fem_mesh, zef_fix_negatives.

if isempty(zef)
    zef = evalin('base','zef');
end

flag_val = 1;

h = zef_waitbar(0,1,'Mesh optimization.');

ind_m = [1 4 7; 2 5 8 ; 3 6 9];

tetra_ind = 0;
iter_ind_aux_0 = 0;

[condition_number, tilavuus] = zef_condition_number(nodes,tetra);

while not(isempty(tetra_ind)) & iter_ind_aux_0 < eval('zef.mesh_optimization_repetitions')

    iter_ind_aux_0 =  iter_ind_aux_0 + 1;

    condition_number_thresh = max(0,thresh_val*max(condition_number));

    tetra_ind = find(condition_number < condition_number_thresh);
    rejected_elements = length(tetra_ind);

    if not(isempty(tetra_ind))

        roi_ind = find(sum(ismember(tetra,tetra(tetra_ind,:)),2)==3);

        tetra_aux_1 = tetra(tetra_ind,:);

        for i = 1 : length(tetra_ind)

            % Already-positive volume: only accept a flip that also improves the ratio.
            flipped_tetra = 0;

            if tilavuus(tetra_ind(i)) > 0
                flipped_tetra = 1;
            end

            [tetra_aux_ind] = find(sum(ismember(tetra(roi_ind,:),tetra_aux_1(i,:)),2)==3);
            tetra_aux_ind = roi_ind(tetra_aux_ind);

            Aux_mat = [nodes(tetra(tetra_aux_ind,1),:)'; nodes(tetra(tetra_aux_ind,2),:)'; nodes(tetra(tetra_aux_ind,3),:)'] - repmat(nodes(tetra(tetra_aux_ind,4),:)',3,1);
            tilavuus_aux_1 = (Aux_mat(ind_m(1,1),:).*(Aux_mat(ind_m(2,2),:).*Aux_mat(ind_m(3,3),:)-Aux_mat(ind_m(2,3),:).*Aux_mat(ind_m(3,2),:)) ...
                - Aux_mat(ind_m(1,2),:).*(Aux_mat(ind_m(2,1),:).*Aux_mat(ind_m(3,3),:)-Aux_mat(ind_m(2,3),:).*Aux_mat(ind_m(3,1),:)) ...
                + Aux_mat(ind_m(1,3),:).*(Aux_mat(ind_m(2,1),:).*Aux_mat(ind_m(3,2),:)-Aux_mat(ind_m(2,2),:).*Aux_mat(ind_m(3,1),:)))/6;

            tetra_aux_ind = tetra_aux_ind(find(tilavuus_aux_1<0));

            tetra_aux_3 = zeros(2,4,3,length(tetra_aux_ind));
            tilavuus_ratio = zeros(3,length(tetra_aux_ind));
            tilavuus_ratio_old = zeros(length(tetra_aux_ind));

            for j = 1 : length(tetra_aux_ind)

                tetra_aux_2 = tetra(tetra_aux_ind(j),:);
                node_ind_3 = intersect(tetra_aux_1(i,:), tetra_aux_2);
                node_ind_1 = setdiff(tetra_aux_1(i,:), node_ind_3);
                node_ind_2 = setdiff(tetra_aux_2, node_ind_3);

                tilavuus_ratio_old(j) = abs(1 - tilavuus(tetra_ind(i))/tilavuus(tetra_aux_ind(j)));

                % Three ways to pair the two unique vertices with the shared face.
                for k = 1 : 3

                    tetra_aux_3(:,:,k,j) = [node_ind_1 node_ind_3(mod(k,3)+1) node_ind_2 node_ind_3(mod(k+1,3)+1); ...
                        node_ind_1 node_ind_2 node_ind_3(mod(k,3)+1) node_ind_3(mod(k+2,3)+1)];

                    Aux_mat = [nodes(tetra_aux_3(:,1,k,j),:)'; nodes(tetra_aux_3(:,2,k,j),:)'; nodes(tetra_aux_3(:,3,k,j),:)'] - repmat(nodes(tetra_aux_3(:,4,k,j),:)',3,1);
                    tilavuus_aux_2 = (Aux_mat(ind_m(1,1),:).*(Aux_mat(ind_m(2,2),:).*Aux_mat(ind_m(3,3),:)-Aux_mat(ind_m(2,3),:).*Aux_mat(ind_m(3,2),:)) ...
                        - Aux_mat(ind_m(1,2),:).*(Aux_mat(ind_m(2,1),:).*Aux_mat(ind_m(3,3),:)-Aux_mat(ind_m(2,3),:).*Aux_mat(ind_m(3,1),:)) ...
                        + Aux_mat(ind_m(1,3),:).*(Aux_mat(ind_m(2,1),:).*Aux_mat(ind_m(3,2),:)-Aux_mat(ind_m(2,2),:).*Aux_mat(ind_m(3,1),:)))/6;

                    if tilavuus_aux_2 > 0
                        tetra_aux_3(:,:,k,j) = tetra_aux_3(:,[1 3 2 4],k,j);
                        tilavuus_aux_2 = - tilavuus_aux_2;
                    end

                    if tilavuus_aux_2 < 0
                        tilavuus_ratio(k,j) = abs(1 - tilavuus_aux_2(1)/tilavuus_aux_2(2));
                        if not(flipped_tetra) & tilavuus_ratio(k,j) > tilavuus_ratio_old(j)
                            tilavuus_ratio(k,j) = Inf;
                        end
                    else
                        tilavuus_ratio(k,j) = Inf;
                    end

                end

            end

            k_min_1 = 0;
            k_min_2 = 0;

            [min_vec_aux, k_min_1] = min(tilavuus_ratio);
            [min_val, k_min_2] = min(min_vec_aux);

            if [k_min_1 k_min_2] > 0 & min_val < Inf

                tetra_1 = reshape(tetra_aux_3(1,:,k_min_1(k_min_2),k_min_2),1,4);
                tetra_2 = reshape(tetra_aux_3(2,:,k_min_1(k_min_2),k_min_2),1,4);
                tetra(tetra_ind(i),:) = tetra_1;
                tetra(tetra_aux_ind(k_min_2),:) = tetra_2;
                condition_number([tetra_ind(i); tetra_aux_ind(k_min_2)]) = zef_condition_number(nodes,[tetra_1 ; tetra_2]);

            end

            if mod(i,ceil(length(tetra_ind)/100)) == 0
                zef_waitbar(i,length(tetra_ind),h,['Mesh optimization. Rejected elements: ' num2str(rejected_elements)]);
            end

        end

    end

end

close(h)

if min(condition_number) < max(0,thresh_val*max(condition_number))
    flag_val = -1;
else
    flag_val = 1;
end

nodes_ind = unique(tetra(find(condition_number < max(0,thresh_val*max(condition_number))),:));

end
