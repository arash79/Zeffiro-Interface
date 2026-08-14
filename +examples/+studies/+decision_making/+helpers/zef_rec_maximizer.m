function max_point = zef_rec_maximizer(rec_arr, s_pos)
%ZEF_REC_MAXIMIZER  Source position of the largest 3-component |moment|.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   max_point = zef_rec_maximizer(rec_arr, s_pos)
%
%   Reshapes rec_arr to 3-by-N (column-major xyz per source), takes
%   max of sqrt(sum(q.^2)) over sources, returns s_pos(max_ind,:).
%   s_pos is N-by-3 (zef.source_positions).
%
%   See also zef_cluster_reconstructions_focal_epilepsy.

    [~, max_ind] = max(sqrt(sum(reshape(rec_arr, 3, length(rec_arr(:))/3).^2)), [], 2);
    max_point = s_pos(max_ind, :);
end
