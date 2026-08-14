function nse_field = zef_smooth_nse_field(nse_field, n_smoothing, s_mode)



%ZEF_SMOOTH_NSE_FIELD  Laplacian-style smoothing of NSE nodal fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   s_mode 1 (default): apply zef_averaging_matrix n_smoothing times to
%   u_1/u_2/u_3_field and p_field. Other s_mode values use the vessel-cell
%   arrays. n_smoothing is the iteration count.
%
%   nse_field = zef_smooth_nse_field(nse_field, n_smoothing, s_mode)
%
%   See also zef_averaging_matrix.

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
