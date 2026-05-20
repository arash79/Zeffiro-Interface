function nse_field = zef_smooth_nse_field(nse_field, n_smoothing, s_mode)
% --- Zeffiro documentation header ---
% zef_smooth_nse_field — Zef smooth nse field.
%
% Purpose:
%   Zef smooth nse field.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   nse_field
%   n_smoothing
%   s_mode
%
% Outputs:
%   nse_field
%
% Calls (project):
%   zef_averaging_matrix
%   zef_smooth_nse_field
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[nse_field] = zef_smooth_nse_field(nse_field, n_smoothing, s_mode)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin < 3

    s_mode = 1;

end


if s_mode == 1

    M = zef_averaging_matrix(nse_field.nodes,nse_field.tetra,nse_field.i_node_ind);

    for i = 1 : n_smoothing

        nse_field.u_1_field = M*nse_field.u_1_field;
        nse_field.u_2_field = M*nse_field.u_2_field;
        nse_field.u_3_field = M*nse_field.u_3_field;
        nse_field.p_field = M*nse_field.p_field;

    end

elseif s_mode == 2

    MdlKDT = KDTreeSearcher(nse_field.nodes(nse_field.i_node_ind,:));
    nearest_nodes = knnsearch(MdlKDT,nse_field.nodes(nse_field.i_node_ind,:),'K',n_smoothing);




    for i = 1 : size(nse_field.u_1_field,2)

        aux_vec = nse_field.u_1_field(:,i);
        nse_field.u_1_field(:,i) = mean(aux_vec(nearest_nodes),2);

        aux_vec = nse_field.u_2_field(:,i);
        nse_field.u_2_field(:,i) = mean(aux_vec(nearest_nodes),2);

        aux_vec = nse_field.u_3_field(:,i);
        nse_field.u_3_field(:,i) = mean(aux_vec(nearest_nodes),2);

        aux_vec = nse_field.p_field(:,i);
        nse_field.p_field(:,i) = mean(aux_vec(nearest_nodes),2);

    end


end
